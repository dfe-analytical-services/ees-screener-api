#* Delete the screening progress file for a particular data set.
handle_delete_progress_file <- function(req, res) {

  source(here::here("src/services/screener_progress.R"))
  
  data_set_id <- req$args$dataSetId

  if (is.null(data_set_id)) {
    res$status <- 400
    return(list(
      message = "Query parameter dataSetId must be specified."
    ))
  }

  delete_progress_file(data_set_id)

  res$status <- 204
}
