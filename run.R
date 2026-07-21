library(future)
library(logger)

source(here::here("create_server.R"))
source(here::here("src/utils/stdout_log_appender.R"))

build_version <- Sys.getenv("BUILD_VERSION", unset = 0)
eesyscreener_version <- Sys.getenv("EESYSCREENER_VERSION", unset = '')

# Set up a pool of background workers to be used by code blocks that execute
# as futures (e.g. long-running background requests).
number_of_concurrent_workers <- strtoi(Sys.getenv("CONCURRENT_R_WORKERS", unset = 0))

if (number_of_concurrent_workers > 0) {
  plan(multisession, workers = number_of_concurrent_workers)
}

log_appender(stdout_log_appender)
log_formatter(formatter_paste)

log_info("Screener API starting with build version ", build_version, " and eesyscreener version ", eesyscreener_version)

create_server() |>
  plumber::pr_run(
    host = "0.0.0.0",
    port = FORWARD_PORT
  )