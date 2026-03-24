#* @parser json
#* @serializer unboxedJSON
#* @get /api/healthcheck
healthcheck_route <- function() {
  source(here::here("function_healthcheck/handle.R"))
  handle_healthcheck()
}

#* @parser json
#* @serializer unboxedJSON
#* @post /api/screen
screen_route <- function(req, res) {
  source(here::here("function_screen/handle.R"))
  handle_screen(req, res)
}

#* @parser json
#* @serializer unboxedJSON
#* @post /function_start_screening
start_screening_route <- function(req, res) {
  source(here::here("function_start_screening/handle.R"))
  handle_start_screening(req, res)
}

#* @parser json
#* @serializer unboxedJSON
#* @get /api/progress
check_progress_route <- function(req, res) {
  source(here::here("function_check_progress/handle.R"))
  handle_check_progress(req, res)
}