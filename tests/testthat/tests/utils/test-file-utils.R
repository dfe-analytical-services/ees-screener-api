library(stringi)

source("../../../../src/utils/file_utils.R")

testthat::test_that("read_json_file() method retries after reading malformed JSON", {

  temp_filepath <- paste0(tempdir(), "/read_json_file_", stri_rand_strings(1, 10)[1], '.json')

  # Write some incomplete JSON.
  writeLines(c('{', '  "name": "value"'), con = temp_filepath)

  retry_callback <- function(attempt) {
    
    # On the 2nd failed attempt to read the file, complete the JSON so that the 3rd attempt can succeed.
    if (attempt == 2) {
      cat("}", file = temp_filepath, append = TRUE)
    } 
  }

  contents <- read_json_file(
    filepath=temp_filepath,
    max_attempts=3,
    wait_seconds=0.1,
    retry_callback_function = retry_callback
  )
  
  expect_equal(contents, list(name = "value"))
})


testthat::test_that("read_json_file() method fails after the maximum number of retries", {

  temp_filepath <- paste0(tempdir(), "/read_json_file_", stri_rand_strings(1, 10)[1], '.json')

  # Write some incomplete JSON.
  writeLines(c('{', '  "name": "value"'), con = temp_filepath)

  err <- testthat::expect_error(
    read_json_file(
      filepath=temp_filepath,
      max_attempts=3,
      wait_seconds=0.1
    )
  )
  
  expect_match(conditionMessage(err), "^Failed to read JSON from after maximum attempts. Last error: parse error: premature EOF")
})


testthat::test_that("read_json_file() method retries for the correct number of times, and the correct amount of time between retries", {

  temp_filepath <- paste0(tempdir(), "/read_json_file_", stri_rand_strings(1, 10)[1], '.json')

  # Write some incomplete JSON.
  writeLines(c('{', '  "name": "value"'), con = temp_filepath)

  last_attempt <- 0

  retry_callback <- function(attempt) {
    last_attempt <<- attempt
  }

  elapsed_time <- system.time({

    testthat::expect_error(
      read_json_file(
        filepath=temp_filepath,
        max_attempts=3,
        wait_seconds=0.5,
        retry_callback_function = retry_callback
      )
    )
  })["elapsed"]

  expect_equal(last_attempt, 3)
  expect_gte(elapsed_time, 1) # Expect 2 retries at 0.5 seconds each. 
  expect_lt(elapsed_time, 2)
})


testthat::test_that("read_json_file() method without specific number of attempts or retry delay arguments use defaults from environment variables", {

  temp_filepath <- paste0(tempdir(), "/read_json_file_", stri_rand_strings(1, 10)[1], '.json')

  # Write some incomplete JSON.
  writeLines(c('{', '  "name": "value"'), con = temp_filepath)

  last_attempt <- 0

  retry_callback <- function(attempt) {
    last_attempt <<- attempt
  }

  withr::local_envvar(JSON_FILES_MAX_READ_ATTEMPTS = 5)
  withr::local_envvar(JSON_FILES_RETRY_WAIT_IN_SECONDS = 0.2)

  elapsed_time <- system.time({

    testthat::expect_error(
      read_json_file(
        filepath=temp_filepath,
        retry_callback_function = retry_callback
      )
    )
  })["elapsed"]

  expect_equal(last_attempt, 5)
  expect_gte(elapsed_time, 0.8) # Expect 4 retries at 0.2 seconds each.
  expect_lt(elapsed_time, 2)
})