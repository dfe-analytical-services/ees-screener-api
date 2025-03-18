FORWARD_PORT <- Sys.getenv("FUNCTIONS_CUSTOMHANDLER_PORT", unset = 8000)

library(plumber)
pr("screen_controller.R") %>%
    pr_run(host = "0.0.0.0", port = FORWARD_PORT)
