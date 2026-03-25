FORWARD_PORT <- Sys.getenv("FUNCTIONS_CUSTOMHANDLER_PORT", unset = 8000)

create_server <- function() {
  library(plumber)

  pr(here::here("routes.R")) %>%
    pr_hook("preroute", function(data, req, res) {
      message("Plumber handling HTTP request with method ", req$REQUEST_METHOD, " and path ", req$PATH_INFO)
    })
}