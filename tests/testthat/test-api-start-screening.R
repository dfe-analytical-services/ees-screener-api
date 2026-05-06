source("utils/queue_trigger_test_utils.R")
source("utils/progress_file_test_utils.R")

testthat::test_that("POST to the queue-triggered start_screening function returns success and expected structure for valid local files", {
  
  body <- create_queue_trigger_message_payload(
    'startScreening',
    list(
      data_file_name = "pass.csv",
      data_file_path = "example-data/pass.csv",
      meta_file_name = "pass.meta.csv",
      meta_file_path = "example-data/pass.meta.csv",
      data_set_id = "data-set-id"
    )
  )

  resp <- httr::POST(
    paste0(api_url(), "/function_start_screening"),
    body = body, # Escape the JSON body, as this is how queue message bodies are received.
    encode = "json"
  )

  expect_equal(httr::status_code(resp), 200)

  result <- httr::content(resp, as = "parsed")

  expect_true(is.list(result))
  
  # These depend on eesyscreener, but are here to catch breaking changes to structure
  expect_equal(
    names(result),
    c("results_table", "overall_stage", "passed", "api_suitable")
  )
  expect_equal(
    names(result[["results_table"]][[1]]),
    c("check", "result", "message", "stage")
  )

  # Check that a progress log has been output and that it shows the screening process
  # has completed successfully.
  progress_log <- get_progress_file("data-set-id")

  expect_equal(progress_log$progress[[1]], 100)
  expect_equal(progress_log$status[[1]], "PASS")
  expect_equal(progress_log$completed[[1]], TRUE)
})

testthat::test_that("POST to the queue-triggered start_screening function returns error for missing files", {
  
  body <- create_queue_trigger_message_payload(
    'startScreening',
    list(
      data_file_name = "missing.csv",
      data_file_path = "example-data/missing.csv",
      meta_file_name = "missing.meta.csv",
      meta_file_path = "example-data/missing.meta.csv",
      data_set_id = "data-set-id"
    )
  )

  resp <- httr::POST(
    paste0(api_url(), "/function_start_screening"),
    body = body,
    encode = "json"
  )

  expect_equal(httr::status_code(resp), 200)
  result <- httr::content(resp, as = "text")

  # error message originates from eesyscreener
  expect_match(result, "No file found at example-data/missing.csv")
})
