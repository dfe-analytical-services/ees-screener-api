library(jsonlite)
library(logger)

create_completion_report <- function(results, data_set_id) {
  
  report_filepath <- .get_completion_report_filepath(data_set_id)
  
  log_info("Creating screening completion report at", report_filepath)

  write_json(results, report_filepath)
}

get_completion_report <- function(data_set_id) {

  source(here::here("src/utils/file_utils.R"))
  
  report_filepath <- .get_completion_report_filepath(data_set_id)
  
  log_info("Looking for completion report file", report_filepath)

  if (!file.exists(report_filepath)) {
    log_info("Unable to find completion report file", report_filepath)
    return(NULL)
  }

  log_info("Found completion report file", report_filepath)
    
  read_json_file(report_filepath)
}

delete_completion_report_file <- function(data_set_id) {
  
  report_filepath <- .get_completion_report_filepath(data_set_id)
  
  log_info("Deleting completion report file", report_filepath)

  if (!file.exists(report_filepath)) {
    log_info("Completion report file", report_filepath, "not found to delete. Exiting gracefully.")
    return()
  }

  log_info("Found completion report file", report_filepath, "to delete.")

  file.remove(report_filepath)

  log_info("Completion report file", report_filepath, "deleted successfully.")
}

.get_completion_report_filepath <- function(data_set_id) {
  log_dir <- Sys.getenv("LOG_DIR")
  paste0(log_dir, "/", "eesyscreener_log_", data_set_id, "_completion_report.json")
}