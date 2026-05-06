library(jsonlite)

source("utils/progress_file_test_utils.R")

testthat::test_that("GET to the progress function without a data_set_id returns a 400", {
  request <- api_url(api_host(), api_port()) |>
    httr2::request() |>
    httr2::req_error(is_error = function(resp) FALSE) |>
    httr2::req_url_path("api/progress") |>
    httr2::req_method("GET")

  resp <- httr2::req_perform(request)

  expect_equal(httr2::resp_status(resp), 400)

  result <- httr2::resp_body_json(resp)

  expect_equal(result$message, "Query parameter data_set_id must be specified.")
})

testthat::test_that("GET to the progress function with a data_set_id for an existing progress file returns the current progress", {
  
  data_set_id = "existing"
  percentage_complete = 90.12
  stage = "started"
  completed = TRUE

  # Create a temporary existing progress file.
  create_progress_file(data_set_id, percentage_complete, stage, completed)

  request <- api_url(api_host(), api_port()) |>
    httr2::request() |>
    httr2::req_url_path("api/progress") |>
    httr2::req_url_query(data_set_id = data_set_id) |>
    httr2::req_method("GET")

  resp <- httr2::req_perform(request)

  expect_equal(httr2::resp_status(resp), 200)

  result <- httr2::resp_body_json(resp)

  expect_equal(length(result), 1)

  expect_equal(result[[1]]$data_set_id, data_set_id)
  expect_equal(result[[1]]$percentage_complete, percentage_complete)
  expect_equal(result[[1]]$stage, stage)
  expect_equal(result[[1]]$completed, completed)
})

testthat::test_that("GET to the progress function with multiple data_set_ids (comma-separated) for existing progress files return the current progress", {
  
  data_set_1_id = "existing_1"
  data_set_1_percentage_complete = 90.12
  data_set_1_stage = "started"
  data_set_1_completed = FALSE

  data_set_2_id = "existing_2"
  data_set_2_percentage_complete = 50.00
  data_set_2_stage = "completed"
  data_set_2_completed = FALSE

  # Create temporary existing progress files.
  create_progress_file(data_set_1_id, data_set_1_percentage_complete, data_set_1_stage, data_set_1_completed)
  create_progress_file(data_set_2_id, data_set_2_percentage_complete, data_set_2_stage, data_set_2_completed)

  request <- api_url(api_host(), api_port()) |>
    httr2::request() |>
    httr2::req_url_path("api/progress") |>
    httr2::req_url_query(data_set_id = paste0(data_set_1_id, ",", data_set_2_id)) |>
    httr2::req_method("GET")

  resp <- httr2::req_perform(request)

  expect_equal(httr2::resp_status(resp), 200)

  result <- httr2::resp_body_json(resp)

  expect_equal(length(result), 2)

  expect_equal(result[[1]]$data_set_id, data_set_1_id)
  expect_equal(result[[1]]$percentage_complete, data_set_1_percentage_complete)
  expect_equal(result[[1]]$stage, data_set_1_stage)
  expect_equal(result[[1]]$completed, data_set_1_completed)

  expect_equal(result[[2]]$data_set_id, data_set_2_id)
  expect_equal(result[[2]]$percentage_complete, data_set_2_percentage_complete)
  expect_equal(result[[2]]$stage, data_set_2_stage)
  expect_equal(result[[2]]$completed, data_set_2_completed)
})

testthat::test_that("GET to the progress function with multiple data_set_ids for existing progress files return the current progress", {
  
  data_set_1_id = "existing_1"
  data_set_1_percentage_complete = 90.12
  data_set_1_stage = "started"
  data_set_1_completed = FALSE

  data_set_2_id = "existing_2"
  data_set_2_percentage_complete = 50.00
  data_set_2_stage = "completed"
  data_set_2_completed = TRUE

  # Create temporary existing progress files.
  create_progress_file(data_set_1_id, data_set_1_percentage_complete, data_set_1_stage, data_set_1_completed)
  create_progress_file(data_set_2_id, data_set_2_percentage_complete, data_set_2_stage, data_set_2_completed)

  request <- api_url(api_host(), api_port()) |>
    httr2::request() |>
    httr2::req_url_path("api/progress") |>
    httr2::req_url_query(data_set_id = c(data_set_1_id, data_set_2_id), .multi = "explode") |>
    httr2::req_method("GET")

  resp <- httr2::req_perform(request)

  expect_equal(httr2::resp_status(resp), 200)

  result <- httr2::resp_body_json(resp)

  expect_equal(length(result), 2)

  expect_equal(result[[1]]$data_set_id, data_set_1_id)
  expect_equal(result[[1]]$percentage_complete, data_set_1_percentage_complete)
  expect_equal(result[[1]]$stage, data_set_1_stage)
  expect_equal(result[[1]]$completed, data_set_1_completed)

  expect_equal(result[[2]]$data_set_id, data_set_2_id)
  expect_equal(result[[2]]$percentage_complete, data_set_2_percentage_complete)
  expect_equal(result[[2]]$stage, data_set_2_stage)
  expect_equal(result[[2]]$completed, data_set_2_completed)
})

testthat::test_that("GET to the progress function with a data_set_id for an existing progress file and a non-existent one returns the existing progress and ignores the not found one", {
  
  data_set_id = "existing"
  percentage_complete = 90.12
  stage = "started"
  completed = FALSE

  non_existent_data_set_id = "non-existent"

  # Create a temporary existing progress file.
  create_progress_file(data_set_id, percentage_complete, stage, completed)

  request <- api_url(api_host(), api_port()) |>
    httr2::request() |>
    httr2::req_url_path("api/progress") |>
    httr2::req_url_query(data_set_id = c(data_set_id, non_existent_data_set_id), .multi = "explode") |>
    httr2::req_method("GET")

  resp <- httr2::req_perform(request)

  expect_equal(httr2::resp_status(resp), 200)

  result <- httr2::resp_body_json(resp)

  expect_equal(length(result), 1)

  expect_equal(result[[1]]$data_set_id, data_set_id)
  expect_equal(result[[1]]$percentage_complete, percentage_complete)
  expect_equal(result[[1]]$stage, stage)
  expect_equal(result[[1]]$completed, completed)
})