library(jsonlite)

create_completion_report <- function(results, data_set_id) {
  
  report_filepath <- .get_completion_report_filepath(data_set_id)
  
  message(paste0("Creating screening completion report at ", report_filepath))

  write_json(results, report_filepath)
}

get_completion_report <- function(data_set_id) {
  
  report_filepath <- .get_completion_report_filepath(data_set_id)
  
  message(paste0("Looking for completion report file ", report_filepath))

  if (!file.exists(report_filepath)) {
    message(paste0("Unable to find completion report file ", report_filepath))
    return(NULL)
  }

  message(paste0("Found completion report file ", report_filepath))
    
  fromJSON(report_filepath)
}

delete_completion_report_file <- function(data_set_id) {
  
  report_filepath <- .get_completion_report_filepath(data_set_id)
  
  message(paste0("Deleting completion report file ", report_filepath))

  if (!file.exists(report_filepath)) {
    message(paste0("Completion report file ", report_filepath, " not found to delete. Exiting gracefully."))
    return()
  }

  message(paste0("Found completion report file ", report_filepath, " to delete."))

  file.remove(report_filepath)

  message(paste0("Completion report file ", report_filepath, " deleted successfully."))
}

.get_completion_report_filepath <- function(data_set_id) {
  log_dir <- Sys.getenv("LOG_DIR")
  paste0(log_dir, "/", "eesyscreener_log_", data_set_id, "_completion_report.json")
}