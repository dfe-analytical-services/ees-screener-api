FORWARD_PORT <- Sys.getenv("FUNCTIONS_CUSTOMHANDLER_PORT", unset = 8000)

library(plumber)

pr("routes.R") %>%
    pr_hook("preroute", function(data, req, res) {
      message("Plumber handling HTTP request with method ", req$REQUEST_METHOD, " and path ", req$PATH_INFO)
    }) %>%
    pr_run(host = "0.0.0.0", port = FORWARD_PORT)