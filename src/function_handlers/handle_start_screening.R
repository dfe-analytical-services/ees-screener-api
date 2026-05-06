handle_start_screening <- function(req, res) {

  source(here::here("src/utils/queue_triggers.R"))
  source(here::here("src/services/screen_csvs.R"))
  source(here::here("src/services/screener_progress.R"))

  payload <- get_queue_message_payload(req)
  
  data_set_id <- payload$data_set_id

  message("Starting to screen data set: ", data_set_id, "\n")
  
  log_dir <- Sys.getenv("LOG_DIR")
  
  data_file_path <- payload$data_file_path
  data_file_name <- payload$data_file_name
  data_file_sas_token <- payload$data_file_sas_token
  meta_file_path <- payload$meta_file_path
  meta_file_name <- payload$meta_file_name
  meta_file_sas_token <- payload$meta_file_sas_token

  result <- tryCatch({

    result <- screen_csvs(data_file_path, data_file_name, data_file_sas_token, meta_file_path, meta_file_name, meta_file_sas_token, data_set_id, log_dir)
    
    create_completion_report(result, data_set_id)
    
    # Check for a special-case eesyscreener response where files are not found but it indicates success.
    if (length(result[[1]]$message == 1) && startsWith(result[[1]]$message[1], "No file found")) {
      message(result[[1]]$message[1])
      
      # Create a progress file that shows the screener failed to start due to missing files.
      create_progress_file(
        data_set_id = data_set_id,
        percentage_complete = 0,
        status = result[[1]]$message[1],
        completed = TRUE
      )
      
      res$status <- 404
      return()
    }
    
    res$status <- 200
    
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

    res$status <- 400
  }, finally = {
    # Intentionally blank
  })
}