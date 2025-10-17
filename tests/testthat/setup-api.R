# Credit to https://jakubsobolewski.com/r-tests-gallery/plumber/
# for the examples of how to do this

api_host <- function() "127.0.0.1"
api_port <- function() 3001
api_url <- function(host = api_host(), port = api_port()) {
  paste0("http://", host, ":", port)
}
api_start <- function(host = api_host(), port = api_port()) {
  # Temporarily unset the storage environment variables to force local file usage in tests
  withr::local_envvar(STORAGE_URL = "")

  mirai::daemons(0L)
  # Use 1 daemon to not block the test process
  mirai::daemons(1L, dispatcher = FALSE, autoexit = tools::SIGINT)
  m <- mirai::mirai(
    {
      plumber::pr("../../screen_controller.R") |>
        plumber::pr_run(
          host = host,
          port = port
        )
    },
    host = host,
    port = port
  )

  withr::defer(envir = testthat::teardown_env(), {
    # Stop the API when the test run ends
    if (mirai::unresolved(m)) {
      mirai::stop_mirai(m)
    }
    # Stop the daemon
    mirai::daemons(0L)
  })

  # Wait for the API to be up
  is_up <- function() if (!pingr::is_up(host, port)) stop()
  is_up <- purrr::insistently(
    is_up,
    rate = purrr::rate_delay(0.2, max_times = 10)
  )
  is_up()

  # Return a function to stop the API on demand
  # To be used when test needs own instance of the API
  list(
    stop = function() {
      mirai::stop_mirai(m)
      mirai::daemons(0L)
    }
  )
}

# Start an API running in the background
api <- api_start()
