source("function_healthcheck/handle.R")
source("function_screen/screen_controller.R")
source("function_start_screening/handle.R")

#* @parser json
#* @serializer unboxedJSON
#* @get /api/healthcheck
healthcheck_route <- function() {
    healthcheck()
}

#* @parser json
#* @serializer unboxedJSON
#* @post /api/screen
screen_route <- function(req, res) {
    screen(req, res)
}

#* @parser json
#* @serializer unboxedJSON
#* @post /function_start_screening
screen_route <- function(req, res) {
    start_screening(req, res)
}