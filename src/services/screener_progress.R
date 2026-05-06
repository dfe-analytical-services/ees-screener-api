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
    status = file_contents$status,
    completed = file_contents$completed
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

#* Manually create a progress JSON file to represent the current screening progress for a particular data set.
#* Used to override eesyscreener progress reports in situations where errors occur that prevent screening from
#* properly completing.
create_progress_file <- function(data_set_id, percentage_complete, status, completed, results = list()) {
  
  progress_filepath = .get_progress_filepath(data_set_id)

  file_content <- list(
    progress = percentage_complete,
    status = status,
    completed = completed,
    results = results
  )

  write_json(file_content, progress_filepath)

  return(progress_filepath)
}

.get_progress_filepath <- function(data_set_id) {
  log_dir <- Sys.getenv("LOG_DIR")
  paste0(log_dir, "/", "eesyscreener_log_", data_set_id, ".json")
}