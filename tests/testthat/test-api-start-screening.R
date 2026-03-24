source("utils/queue_trigger_test_utils.R")

testthat::test_that("POST to the queue-triggered start_screening function returns success and expected structure for valid local files", {
  
  body <- create_queue_trigger_message_payload(
    'startScreening',
    list(
      dataFileName = "pass.csv",
      dataFilePath = "example-data/pass.csv",
      metaFileName = "pass.meta.csv",
      metaFilePath = "example-data/pass.meta.csv",
      dataSetId = "data-set-id"
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
})

testthat::test_that("POST to the queue-triggered start_screening function returns error for missing files", {
  
  body <- create_queue_trigger_message_payload(
    'startScreening',
    list(
      dataFileName = "missing.csv",
      dataFilePath = "example-data/missing.csv",
      metaFileName = "missing.meta.csv",
      metaFilePath = "example-data/missing.meta.csv",
      dataSetId = "data-set-id"
    )
  )

  resp <- httr::POST(
    paste0(api_url(), "/function_start_screening"),
    body = body,
    encode = "json"
  )

  expect_equal(httr::status_code(resp), 400)
  result <- httr::content(resp, as = "text")

  # error message originates from eesyscreener
  expect_match(result, "unhandled exception.*No file found")
})
