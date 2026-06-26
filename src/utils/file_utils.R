read_json_file <- function(filepath, max_attempts = NULL, wait_seconds = NULL, retry_callback_function = NULL) {
  
  max_attempts <- max_attempts %||% Sys.getenv("JSON_FILES_MAX_READ_ATTEMPTS")
  wait_seconds <- wait_seconds %||% Sys.getenv("JSON_FILES_RETRY_WAIT_IN_SECONDS")

  attempt <- 1

  while (attempt <= max_attempts) {
    result <- tryCatch({

      jsonlite::fromJSON(filepath)

    }, error = function(e) {
      return(e)
    })
    
    if (!inherits(result, "error")) {
      return(result)
    }
    
    # If it is an error, wait and try again
    logger::log_warn("Attempt ", attempt, " to read ", filepath, " failed. Waiting ", wait_seconds, " seconds to retry...")

    if (!is.null(retry_callback_function)) {
      retry_callback_function(attempt)
    }

    Sys.sleep(wait_seconds)
    attempt <- attempt + 1
  }
  
  logger::log_error("Attempts to read ", filepath, " failed after ", max_attempts, " attempts. Last error: ", conditionMessage(result))
  stop("Failed to read JSON from after maximum attempts. Last error: ", conditionMessage(result))
}
