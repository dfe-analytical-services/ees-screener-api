#* Check the screening progress for a particular set of data sets.
handle_check_progress <- function(req, res) {

  source(here::here("src/utils/request_utils.R"))
  source(here::here("src/services/screener_progress.R"))
  
  params <- get_request_parameters(req)

  data_set_ids = params$data_set_id

  if (is.null(data_set_ids) || length(data_set_ids) == 0) {
    res$status <- 400
    return(list(
      message = "Query parameter data_set_id must be specified."
    ))
  }

  Filter(Negate(is.null), lapply(data_set_ids, function(data_set_id) {
    progress = check_progress(data_set_id)

    if (is.null(progress)) {
      return();
    }
    
    res$status <- 200
    res$body <- list(
      data_set_id = data_set_id,
      percentage_complete = progress$progress,
      stage = progress$status[1],
      completed = progress$completed
    )
  }))
}