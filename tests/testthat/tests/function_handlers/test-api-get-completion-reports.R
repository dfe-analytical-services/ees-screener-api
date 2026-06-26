library(jsonlite)
library(stringi)

source("../../utils/completion_report_test_utils.R")

testthat::test_that("GET to the completion reports function without a data_set_id returns a 400", {
  resp <- api_url(api_host(), api_port()) |>
    httr2::request() |>
    httr2::req_error(is_error = function(resp) FALSE) |>
    httr2::req_url_path("api/completion-reports") |>
    httr2::req_method("GET") |>
    httr2::req_perform()

  expect_equal(httr2::resp_status(resp), 400)

  result <- httr2::resp_body_json(resp)

  expect_equal(result$message, "Query parameter data_set_id must be specified.")
})

testthat::test_that("GET to the completion reports function with a data_set_id for an existing completion report file returns the report", {
  
  data_set_id = stri_rand_strings(1, 10)[1]
  passed = TRUE
  api_suitable = TRUE
  overall_stage = "Checking"
  results_table = list(
    list(
      check = "test check",
      result = "PASS",
      message = "Test message.",
      stage = "Test stage"
    )
  )

  # Create a temporary existing completion report file.
  create_completion_report_file(
    data_set_id = data_set_id,
    passed = passed,
    api_suitable = api_suitable,
    overall_stage = overall_stage,
    results_table = results_table)

  resp <- api_url(api_host(), api_port()) |>
    httr2::request() |>
    httr2::req_url_path("api/completion-reports") |>
    httr2::req_url_query(data_set_id = data_set_id) |>
    httr2::req_method("GET") |>
    httr2::req_perform()

  expect_equal(httr2::resp_status(resp), 200)

  result <- httr2::resp_body_json(resp)

  expect_equal(length(result), 1)

  expect_equal(result[[1]]$data_set_id, data_set_id)
  expect_equal(result[[1]]$completion_report$passed, passed)
  expect_equal(result[[1]]$completion_report$api_suitable, api_suitable)
  expect_equal(result[[1]]$completion_report$overall_stage, overall_stage)
  expect_equal(result[[1]]$completion_report$results_table, results_table)
})

testthat::test_that("GET to the completion reports function with multiple data_set_ids (comma-separated) for existing completion report files return the reports", {
  
  data_set_1_id = stri_rand_strings(1, 10)[1]
  data_set_1_passed = TRUE
  data_set_1_api_suitable = TRUE
  data_set_1_overall_stage = "Checking"
  data_set_1_results_table = list(
    list(
      check = "test check",
      result = "PASS",
      message = "Test message.",
      stage = "Test stage"
    )
  )

  data_set_2_id = stri_rand_strings(1, 10)[1]
  data_set_2_passed = FALSE
  data_set_2_api_suitable = FALSE
  data_set_2_overall_stage = "Complete"
  data_set_2_results_table = list(
    list(
      check = "Another check",
      result = "PASS",
      message = "Test message.",
      stage = "Test stage"
    )
  )

  # Create temporary completion report files for the 2 data sets.
  create_completion_report_file(
    data_set_id = data_set_1_id,
    passed = data_set_1_passed,
    api_suitable = data_set_1_api_suitable,
    overall_stage = data_set_1_overall_stage,
    results_table = data_set_1_results_table)

  create_completion_report_file(
    data_set_id = data_set_2_id,
    passed = data_set_2_passed,
    api_suitable = data_set_2_api_suitable,
    overall_stage = data_set_2_overall_stage,
    results_table = data_set_2_results_table)

  resp <- api_url(api_host(), api_port()) |>
    httr2::request() |>
    httr2::req_url_path("api/completion-reports") |>
    httr2::req_url_query(data_set_id = paste0(data_set_1_id, ",", data_set_2_id)) |>
    httr2::req_method("GET") |>
    httr2::req_perform()

  expect_equal(httr2::resp_status(resp), 200)

  result <- httr2::resp_body_json(resp)

  # Expect to find completion reports for both data sets.
  expect_equal(length(result), 2)

  expect_equal(result[[1]]$data_set_id, data_set_1_id)
  expect_equal(result[[1]]$completion_report$passed, data_set_1_passed)
  expect_equal(result[[1]]$completion_report$api_suitable, data_set_1_api_suitable)
  expect_equal(result[[1]]$completion_report$overall_stage, data_set_1_overall_stage)
  expect_equal(result[[1]]$completion_report$results_table, data_set_1_results_table)

  expect_equal(result[[2]]$data_set_id, data_set_2_id)
  expect_equal(result[[2]]$completion_report$passed, data_set_2_passed)
  expect_equal(result[[2]]$completion_report$api_suitable, data_set_2_api_suitable)
  expect_equal(result[[2]]$completion_report$overall_stage, data_set_2_overall_stage)
  expect_equal(result[[2]]$completion_report$results_table, data_set_2_results_table)
})

testthat::test_that("GET to the completion reports function with multiple data_set_ids for existing completion reports return the completion reports", {
  
  data_set_1_id = stri_rand_strings(1, 10)[1]
  data_set_1_passed = TRUE
  data_set_1_api_suitable = TRUE
  data_set_1_overall_stage = "Checking"
  data_set_1_results_table = list(
    list(
      check = "test check",
      result = "PASS",
      message = "Test message.",
      stage = "Test stage"
    )
  )

  data_set_2_id = stri_rand_strings(1, 10)[1]
  data_set_2_passed = FALSE
  data_set_2_api_suitable = FALSE
  data_set_2_overall_stage = "Complete"
  data_set_2_results_table = list(
    list(
      check = "Another check",
      result = "PASS",
      message = "Test message.",
      stage = "Test stage"
    )
  )

  # Create temporary completion report files for the 2 data sets.
  create_completion_report_file(
    data_set_id = data_set_1_id,
    passed = data_set_1_passed,
    api_suitable = data_set_1_api_suitable,
    overall_stage = data_set_1_overall_stage,
    results_table = data_set_1_results_table)

  create_completion_report_file(
    data_set_id = data_set_2_id,
    passed = data_set_2_passed,
    api_suitable = data_set_2_api_suitable,
    overall_stage = data_set_2_overall_stage,
    results_table = data_set_2_results_table)

  resp <- api_url(api_host(), api_port()) |>
    httr2::request() |>
    httr2::req_url_path("api/completion-reports") |>
    httr2::req_url_query(data_set_id = c(data_set_1_id, data_set_2_id), .multi = "explode") |>
    httr2::req_method("GET") |>
    httr2::req_perform()

  expect_equal(httr2::resp_status(resp), 200)

  result <- httr2::resp_body_json(resp)

  # Expect to find completion reports for both data sets.
  expect_equal(length(result), 2)

  expect_equal(result[[1]]$data_set_id, data_set_1_id)
  expect_equal(result[[1]]$completion_report$passed, data_set_1_passed)
  expect_equal(result[[1]]$completion_report$api_suitable, data_set_1_api_suitable)
  expect_equal(result[[1]]$completion_report$overall_stage, data_set_1_overall_stage)
  expect_equal(result[[1]]$completion_report$results_table, data_set_1_results_table)

  expect_equal(result[[2]]$data_set_id, data_set_2_id)
  expect_equal(result[[2]]$completion_report$passed, data_set_2_passed)
  expect_equal(result[[2]]$completion_report$api_suitable, data_set_2_api_suitable)
  expect_equal(result[[2]]$completion_report$overall_stage, data_set_2_overall_stage)
  expect_equal(result[[2]]$completion_report$results_table, data_set_2_results_table)
})

testthat::test_that("GET to the completion reports function with a data_set_id for an existing completion report file and a non-existent one returns the existing completion report and ignores the not found one", {
  
  data_set_id = stri_rand_strings(1, 10)[1]
  passed = TRUE
  api_suitable = TRUE
  overall_stage = "Checking"
  results_table = list(
    list(
      check = "test check",
      result = "PASS",
      message = "Test message.",
      stage = "Test stage"
    )
  )

  # Create a temporary existing completion report file for one of the data sets.
  create_completion_report_file(
    data_set_id = data_set_id,
    passed = passed,
    api_suitable = api_suitable,
    overall_stage = overall_stage,
    results_table = results_table)

  resp <- api_url(api_host(), api_port()) |>
    httr2::request() |>
    httr2::req_url_path("api/completion-reports") |>
    httr2::req_url_query(data_set_id = paste0(data_set_id, ",", "non-existent")) |>
    httr2::req_method("GET") |>
    httr2::req_perform()

  expect_equal(httr2::resp_status(resp), 200)

  result <- httr2::resp_body_json(resp)

  expect_equal(length(result), 1)

  expect_equal(result[[1]]$data_set_id, data_set_id)
  expect_equal(result[[1]]$completion_report$passed, passed)
  expect_equal(result[[1]]$completion_report$api_suitable, api_suitable)
  expect_equal(result[[1]]$completion_report$overall_stage, overall_stage)
  expect_equal(result[[1]]$completion_report$results_table, results_table)
})