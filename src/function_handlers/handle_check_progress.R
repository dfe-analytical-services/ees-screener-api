#* Check the screening progress for a particular data set.
handle_check_progress <- function(req, res) {

  source(here::here("src/services/check_progress.R"))
  
  data_set_id <- req$args$dataSetId

  if (is.null(data_set_id)) {
    res$status <- 400
    return(list(
      message = "Query parameter dataSetId must be specified."
    ))
  }

  progress = check_progress(data_set_id)

  if (is.null(progress)) {
    res$status <- 404
    return(list(
      message = paste0("A progress file for dataSetId \"", data_set_id, "\" was not found.")
    ))
  }

  res$status <- 200
  res$body <- list(
    percentComplete = progress$progress,
    stage = progress$status[1]
  )
}
