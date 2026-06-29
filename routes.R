#* @parser json
#* @serializer unboxedJSON
#* @get /api/healthcheck
healthcheck_route <- function() {
  source(here::here("src/function_handlers/handle_healthcheck.R"))
  handle_healthcheck()
}

#* Note that routes for queue-triggered Functions are enforced by the
#* Azure Functions host and runtime, and always take the name of the
#* folder in which the function.json for the Function exists, hence
#* this route is not prefixed with /api or of the normal naming
#* conventions.
#*
#* @parser json
#* @serializer unboxedJSON
#* @post /function_start_screening
start_screening_route <- function(req, res) {
  source(here::here("src/function_handlers/handle_start_screening.R"))
  handle_start_screening(req, res)
}

#* @parser json
#* @serializer unboxedJSON
#* @get /api/progress
get_progress_route <- function(req, res) {
  source(here::here("src/function_handlers/handle_check_progress.R"))
  handle_check_progress(req, res)
}

#* @parser json
#* @serializer unboxedJSON
#* @get /api/completion-reports
get_completion_report_route <- function(req, res) {
  source(here::here("src/function_handlers/handle_get_completion_reports.R"))
  handle_get_completion_reports(req, res)
}

#* @parser json
#* @serializer unboxedJSON
#* @delete /api/progress-and-completion-files
delete_progress_and_completion_files_route <- function(req, res) {
  source(here::here("src/function_handlers/handle_delete_progress_and_completion_files.R"))
  handle_delete_progress_and_completion_files(req, res)
}