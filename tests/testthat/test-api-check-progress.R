library(jsonlite)

source("utils/progress_file_test_utils.R")

testthat::test_that("GET to the progress function without a dataSetId returns a 400", {
  request <- api_url(api_host(), api_port()) |>
    httr2::request() |>
    httr2::req_error(is_error = function(resp) FALSE) |>
    httr2::req_url_path("api/progress") |>
    httr2::req_method("GET")

  resp <- httr2::req_perform(request)

  expect_equal(httr2::resp_status(resp), 400)

  result <- httr2::resp_body_json(resp)

  expect_equal(result$message, "Query parameter dataSetId must be specified.")
})


testthat::test_that("GET to the progress function with a dataSetId for a non-existent progress file returns a 404", {
  request <- api_url(api_host(), api_port()) |>
    httr2::request() |>
    httr2::req_error(is_error = function(resp) FALSE) |>
    httr2::req_url_path("api/progress") |>
    httr2::req_url_query(dataSetId = "not_found") |>
    httr2::req_method("GET")

  resp <- httr2::req_perform(request)

  expect_equal(httr2::resp_status(resp), 404)

  result <- httr2::resp_body_json(resp)

  expect_equal(result$message, "A progress file for dataSetId \"not_found\" was not found.")
})


testthat::test_that("GET to the progress function with a dataSetId for an existing progress file returns the current progress", {
  
  data_set_id = "existing"
  percentage_complete = 90.12
  stage = "started"

  # Create a temporary existing progress file.
  create_progress_file(data_set_id, percentage_complete, stage)

  request <- api_url(api_host(), api_port()) |>
    httr2::request() |>
    httr2::req_url_path("api/progress") |>
    httr2::req_url_query(dataSetId = data_set_id) |>
    httr2::req_method("GET")

  resp <- httr2::req_perform(request)

  expect_equal(httr2::resp_status(resp), 200)

  result <- httr2::resp_body_json(resp)

  expect_equal(length(result), 1)

  expect_equal(result[1]$dataSetId, data_set_id)
  expect_equal(result[1]$percentComplete, percentage_complete)
  expect_equal(result[1]$stage, stage)
})

testthat::test_that("GET to the progress function with multiple dataSetIds for existing progress files return the current progress", {
  
  data_set_1_id = "existing_1"
  data_set_1_percentage_complete = 90.12
  data_set_1_stage = "started"

  data_set_2_id = "existing_2"
  data_set_2_percentage_complete = 50.00
  data_set_2_stage = "completed"

  # Create temporary existing progress files.
  create_progress_file(data_set_1_id, data_set_1_percentage_complete, data_set_1_stage)
  create_progress_file(data_set_2_id, data_set_2_percentage_complete, data_set_2_stage)

  request <- api_url(api_host(), api_port()) |>
    httr2::request() |>
    httr2::req_url_path("api/progress") |>
    httr2::req_url_query(dataSetId = c(data_set_1_id, data_set_2_id), .multi = "explode") |>
    httr2::req_method("GET")

  resp <- httr2::req_perform(request)

  expect_equal(httr2::resp_status(resp), 200)

  result <- httr2::resp_body_json(resp)

  expect_equal(length(result), 2)

  expect_equal(result[1]$dataSetId, data_set_1_id)
  expect_equal(result[1]$percentComplete, data_set_1_percentage_complete)
  expect_equal(result[1]$stage, data_set_1_stage)

  expect_equal(result[2]$dataSetId, data_set_2_id)
  expect_equal(result[2]$percentComplete, data_set_2_percentage_complete)
  expect_equal(result[2]$stage, data_set_2_stage)
})