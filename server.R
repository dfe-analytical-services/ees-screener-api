library(plumber)
pr("screen_controller.R") %>%
    pr_run(host = "0.0.0.0", port = 8000)
