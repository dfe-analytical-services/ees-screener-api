#* Delete the screening progress file for a particular set of data sets.
handle_delete_progress_files <- function(req, res) {

  source(here::here("src/utils/request_utils.R"))
  source(here::here("src/services/screener_progress.R"))
  
  params <- get_request_parameters(req)

  data_set_ids <- params$data_set_id

  if (is.null(data_set_ids) || length(data_set_ids) == 0) {
    res$status <- 400
    return(list(
      message = "Query parameter data_set_id must be specified."
    ))
  }
  
  for(data_set_id in data_set_ids) {
    delete_progress_file(data_set_id)
  }

  res$status <- 204
}
