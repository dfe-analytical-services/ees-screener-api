library(jsonlite)

check_progress <- function(data_set_id) {
  
  log_dir <- Sys.getenv("LOG_DIR")
  progress_filename <- paste0(log_dir, "/", "eesyscreener_log_", data_set_id, ".json")
  
  message(paste0("Looking for progress file ", progress_filename))

  if (!file.exists(progress_filename)) {
    message(paste0("Unable to find progress file ", progress_filename))
    return(NULL)
  }

  message(paste0("Found progress file ", progress_filename))
    
  file_contents <- fromJSON(progress_filename)

  list(
    progress = file_contents$progress,
    status = file_contents$status
  )
}