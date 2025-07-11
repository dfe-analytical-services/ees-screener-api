forward_port <- Sys.getenv("FUNCTIONS_CUSTOMHANDLER_PORT", unset = 8000)

library(plumber)
health_check <- pr("healthcheck/healthcheck_controller.R")
screen <- pr("screen/screen_controller.R")

pr() %>%
    pr_mount("/healthcheck", health_check) %>%
    pr_mount("/screen", screen) %>%
    pr_run(host = "0.0.0.0", port = forward_port)
