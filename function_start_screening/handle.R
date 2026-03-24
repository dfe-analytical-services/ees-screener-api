handle_start_screening <- function(req, res) {

  source(here::here("utils/queue_triggers.R"))
  source(here::here("services/screen_csvs.R"))

  payload <- get_queue_message_payload(req)
  
  data_set_id <- payload$dataSetId

  message("Starting to screen data set: ", data_set_id, "\n")
  
  log_dir <- Sys.getenv("LOG_DIR")
  
  data_file_path <- payload$dataFilePath
  data_file_name <- payload$dataFileName
  data_file_sas_token <- payload$dataFileSasToken
  meta_file_path <- payload$metaFilePath
  meta_file_name <- payload$metaFileName
  meta_file_sas_token <- payload$metaFileSasToken

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