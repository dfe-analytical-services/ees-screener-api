library(future)
library(logger)

source(here::here("create_server.R"))
source(here::here("src/utils/stdout_log_appender.R"))

# Set up a pool of background workers.
# 'multisession' spawns separate R processes.
plan(multisession, workers = 4)

log_appender(stdout_log_appender)
log_formatter(formatter_paste)

log_info("Starting Plumber server...")

create_server() |>
  plumber::pr_run(
    host = "0.0.0.0",
    port = FORWARD_PORT
  )