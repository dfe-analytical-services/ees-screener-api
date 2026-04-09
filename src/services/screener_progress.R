library(jsonlite)

check_progress <- function(data_set_id) {
  
  progress_filepath <- .get_progress_filepath(data_set_id)
  
  message(paste0("Looking for progress file ", progress_filepath))

  if (!file.exists(progress_filepath)) {
    message(paste0("Unable to find progress file ", progress_filepath))
    return(NULL)
  }

  message(paste0("Found progress file ", progress_filepath))
    
  file_contents <- fromJSON(progress_filepath)

  list(
    progress = file_contents$progress,
    status = file_contents$status
  )
}

delete_progress_file <- function(data_set_id) {
  
  progress_filepath <- .get_progress_filepath(data_set_id)
  
  message(paste0("Deleting progress file ", progress_filepath))

  if (!file.exists(progress_filepath)) {
    message(paste0("Progress file ", progress_filepath, " not found to delete. Exiting gracefully."))
    return()
  }

  message(paste0("Found progress file ", progress_filepath, " to delete."))

  file.remove(progress_filepath)

  message(paste0("Progress file ", progress_filepath, " deleted successfully."))
}

.get_progress_filepath <- function(data_set_id) {
  log_dir <- Sys.getenv("LOG_DIR")
  paste0(log_dir, "/", "eesyscreener_log_", data_set_id, ".json")
}