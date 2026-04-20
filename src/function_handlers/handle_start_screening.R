handle_start_screening <- function(req, res) {

  source(here::here("src/utils/queue_triggers.R"))
  source(here::here("src/services/screen_csvs.R"))

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

    res$status <- 200
    res$body <- result
  }, error = function(e) {
    print(paste0("Error details: ", e))
    res$status <- 400
    res$body <- paste0("An unhandled exception occurred in eesyscreener: ", e)
    # TODO: Add logging
  }, finally = {
    # Intentionally blank
  })
}