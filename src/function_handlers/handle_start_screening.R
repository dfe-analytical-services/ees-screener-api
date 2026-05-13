library(future)

handle_start_screening <- function(req, res) {

  source(here::here("src/utils/queue_triggers.R"))

  payload <- get_queue_message_payload(req)

  future({

    .start_screening(payload)

    return(list(
      message = "Screening started." 
    ))
  },
  globals = list(
    payload = payload,
    .start_screening = .start_screening
  ),
  packages = c("jsonlite")) 
}

.start_screening <- function(payload) {

  source(here::here("src/utils/stdout_log_appender.R"))
  source(here::here("src/services/screen_csvs.R"))
  source(here::here("src/services/screener_progress.R"))
  source(here::here("src/services/screener_completion_reports.R"))

  library(logger)

  log_appender(stdout_log_appender)
  log_formatter(formatter_paste)

  data_set_id <- payload$data_set_id

  log_info("Starting to screen data set:", data_set_id)
  
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
      log_info(toJSON(result, pretty = TRUE))
    }
    
    # Check for a special-case eesyscreener response where files are not found but it indicates success.
    if (length(result[[1]]$message == 1) && startsWith(result[[1]]$message[1], "No file found")) {
      missing_file_message = result[[1]]$message[1]
      log_info(missing_file_message)
      
      # Create a progress file that shows the screener failed to start due to missing files.
      create_progress_file(
        data_set_id = data_set_id,
        percentage_complete = 0,
        status = missing_file_message,
        completed = TRUE
      )

      failed_result = list(
        overall_stage = missing_file_message,
        passed = FALSE,
        api_suitable = FALSE,
        results_table = list()
      )

      if (log_screening_results) {
        log_info(toJSON(failed_result, pretty = TRUE))
      }

      # Create a completion report file that shows the screener failed to complete due to missing files.
      create_completion_report(
        data_set_id = data_set_id,
        results = failed_result
      )
      
      return()
    }
    
    # Create a completion report file detailing the successful screening results.
    create_completion_report(result, data_set_id)

    if (log_screening_results) {
      log_info(toJSON(result, pretty = TRUE))
    }

    return()

  }, error = function(e) {
    log_info("An unhandled exception occurred in eesyscreener:", e)

    existing_progress_file = check_progress(data_set_id)

    # Create a progress file that shows the screener failed to complete due to an unexpected error.
    # Merge with existing progress file contents if available.
    create_progress_file(
      data_set_id = data_set_id,
      percentage_complete = existing_progress_file$progress %||% 0,
      status = existing_progress_file$status %||% "An unhandled exception occurred in eesyscreener",
      completed = TRUE,
      results = existing_progress_file$results %||% list()
    )

    failure_message = paste0("Screener finished with error ", e)

    failed_result = list(
      overall_stage = failure_message,
      passed = FALSE,
      api_suitable = FALSE,
      results_table = list()
    )

    if (log_screening_results) {
      log_info(toJSON(result, pretty = TRUE))
    }

    # Create a completion report file that shows the screener failed to complete due to an unexpected
    # error, with the overall result of failed.
    create_completion_report(
      data_set_id = data_set_id,
      results = failed_result
    )
  }, finally = {
    # Intentionally blank
  })
}
