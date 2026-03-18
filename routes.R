source("function_healthcheck/handle.R")
source("function_screen/handle.R")
source("function_start_screening/handle.R")

#* @parser json
#* @serializer unboxedJSON
#* @get /api/healthcheck
healthcheck_route <- function() {
    handle_healthcheck()
}

#* @parser json
#* @serializer unboxedJSON
#* @post /api/screen
screen_route <- function(req, res) {
    handle_screen(req, res)
}

#* @parser json
#* @serializer unboxedJSON
#* @post /function_start_screening
start_screening_route <- function(req, res) {
    handle_start_screening(req, res)
}