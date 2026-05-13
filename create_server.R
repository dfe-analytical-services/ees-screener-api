FORWARD_PORT <- Sys.getenv("FUNCTIONS_CUSTOMHANDLER_PORT", unset = 8000)

create_server <- function() {
  library(plumber)

  pr(here::here("routes.R")) %>%
    pr_hook("preroute", function(data, req, res) {
      
      # Omit the simple "/" path from logging, as it is called excessively in an Azure environment.
      if (req$PATH_INFO != '/') {
        logger::log_info("Plumber handling HTTP request with method", req$REQUEST_METHOD, "and path", req$PATH_INFO)
      }
    })
}