#* Get the final screening completion reports for a particular set of data sets.
handle_get_completion_reports <- function(req, res) {

  source(here::here("src/utils/request_utils.R"))
  source(here::here("src/services/screener_completion_reports.R"))
  
  params <- get_request_parameters(req)

  data_set_ids = params$data_set_id

  if (is.null(data_set_ids) || length(data_set_ids) == 0) {
    res$status <- 400
    return(list(
      message = "Query parameter data_set_id must be specified."
    ))
  }

  Filter(Negate(is.null), lapply(data_set_ids, function(data_set_id) {
    completion_report = get_completion_report(data_set_id)
    
    if (is.null(completion_report)) {
      return();
    }
    
    res$status <- 200
    res$body <- list(
      data_set_id = data_set_id,
      completion_report = completion_report
    )
  }))
}