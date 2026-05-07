handle_start_screening <- function(req, res) {

  source(here::here("src/utils/queue_triggers.R"))
  source(here::here("src/services/screen_csvs.R"))
  source(here::here("src/services/screener_progress.R"))
  source(here::here("src/services/screener_completion_reports.R"))

  payload <- get_queue_message_payload(req)
  
  data_set_id <- payload$data_set_id

  message("Starting to screen data set: ", data_set_id, "\n")
  
  log_dir <- Sys.getenv("LOG_DIR")
  log_screening_results <- as.logical(Sys.getenv("LOG_SCREENING_RESULTS", unset = "FALSE"))
  
  data_file_path <- payload$data_file_path
  data_file_name <- payload$data_file_name
  data_file_sas_token <- payload$data_file_sas_token
  meta_file_path <- payload$meta_file_path
  meta_file_name <- payload$meta_file_name
  meta_file_sas_token <- payload$meta_file_sas_token

  result <- tryCatch({

    result <- screen_csvs(data_file_path, data_file_name, data_file_sas_token, meta_file_path, meta_file_name, meta_file_sas_token, data_set_id, log_dir)
    
    if (log_screening_results) {
      message(result)
    }

    # Check for a special-case eesyscreener response where files are not found but it indicates success.
    if (length(result[[1]]$message == 1) && startsWith(result[[1]]$message[1], "No file found")) {
      missing_file_message = result[[1]]$message[1]
      message(missing_file_message)
      
      # Create a progress file that shows the screener failed to start due to missing files.
      create_progress_file(
        data_set_id = data_set_id,
        percentage_complete = 0,
        status = missing_file_message,
        completed = TRUE
      )

      # Create a completion report file that shows the screener failed to complete due to missing files.
      create_completion_report(
        data_set_id = data_set_id,
        results = list(
          overall_stage = missing_file_message,
          passed = FALSE,
          api_suitable = FALSE,
          results_table = list()
        )
      )
      
      res$status <- 404

      return(list(
        message = missing_file_message 
      ))
    }
    
    # Create a completion report file detailing the successful screening results.
    create_completion_report(result, data_set_id)
    
    res$status <- 200
    return(list(
      message = "Screener finished successfully." 
    ))

  }, error = function(e) {
    message("An unhandled exception occurred in eesyscreener: ", e)

    existing_progress_file = check_progress(data_set_id)

    # Create a progress file that shows the screener failed to complete due to an unexpected error.
    # Merge with existing progress file contents if available.
    create_progress_file(
      data_set_id = data_set_id,
      percentage_complete = existing_progress_file$percentage_complete %||% 0,
      status = existing_progress_file$status %||% "An unhandled exception occurred in eesyscreener",
      completed = TRUE,
      results = existing_progress_file$results %||% list()
    )

    failure_message = paste0("Screener finished with error ", e)

    # Create a completion report file that shows the screener failed to complete due to an unexpected
    # error, with the overall result of failed.
    create_completion_report(
      data_set_id = data_set_id,
      results = list(
        overall_stage = failure_message,
        passed = FALSE,
        api_suitable = FALSE,
        results_table = list()
      )
    )

    res$status <- 400
    return(list(
      message = "Screener finished successfully." 
    ))
  }, finally = {
    # Intentionally blank
  })
}