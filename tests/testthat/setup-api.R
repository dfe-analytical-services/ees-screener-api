# Credit to https://jakubsobolewski.com/r-tests-gallery/plumber/
# for the examples of how to do this

source("../../create_server.R")

seconds_to_wait_for_server_start = 30

api_host <- function() "127.0.0.1"
api_port <- function() 13001
api_url <- function(host = api_host(), port = api_port()) {
  paste0("http://", host, ":", port)
}

api_start <- function(host = api_host(), port = api_port(), server = create_server()) {
  # Temporarily unset the storage environment variables to force local file usage in tests
  withr::local_envvar(STORAGE_URL = "")

  mirai::daemons(0L)
  # Use 1 daemon to not block the test process
  mirai::daemons(1L, dispatcher = FALSE, autoexit = tools::SIGINT, output = TRUE)
  m <- mirai::mirai(
    {
      withr::local_envvar(LOG_DIR = "/tmp")

      server |>
        plumber::pr_run(host = host, port = port)
    },
    host = host,
    port = port,
    server = server
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
  for (i in seq_len(seconds_to_wait_for_server_start)) {
    if (pingr::is_up(host, port)) break
    
    if (!mirai::unresolved(m)) {
      res <- m[]
      
      if (mirai::is_mirai_error(res) || mirai::is_error_value(res)) {
        message("mirai failed: ", conditionMessage(res))
        print(res$stack.trace)
      } else {
        print(res)
      }
      
      stop("API process exited before opening port")
    }
    
    Sys.sleep(1)
  }

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
