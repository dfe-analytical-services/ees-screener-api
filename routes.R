#* @parser json
#* @serializer unboxedJSON
#* @get /api/healthcheck
healthcheck_route <- function() {
  source(here::here("src/function_handlers/handle_healthcheck.R"))
  handle_healthcheck()
}

#* @parser json
#* @serializer unboxedJSON
#* @post /api/screen
screen_route <- function(req, res) {
  source(here::here("src/function_handlers/handle_screen.R"))
  handle_screen(req, res)
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