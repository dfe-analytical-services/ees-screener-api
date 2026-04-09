library(jsonlite)

source("utils/progress_file_test_utils.R")

testthat::test_that("DELETE to the progress deletion function without a dataSetId returns a 400", {
  request <- api_url(api_host(), api_port()) |>
    httr2::request() |>
    httr2::req_error(is_error = function(resp) FALSE) |>
    httr2::req_url_path("api/progress") |>
    httr2::req_method("DELETE")

  resp <- httr2::req_perform(request)

  expect_equal(httr2::resp_status(resp), 400)

  result <- httr2::resp_body_json(resp)

  expect_equal(result$message, "Query parameter dataSetId must be specified.")
})


testthat::test_that("DELETE to the progress deletion function with a dataSetId for a non-existent progress file gracefully returns a 204", {
  
    # Create a temporary existing progress file that will not be touched by the deletion request.
  filepath = create_progress_file('existing')

  request <- api_url(api_host(), api_port()) |>
    httr2::request() |>
    httr2::req_error(is_error = function(resp) FALSE) |>
    httr2::req_url_path("api/progress") |>
    httr2::req_url_query(dataSetId = "not_found") |>
    httr2::req_method("DELETE")

  resp <- httr2::req_perform(request)

  # Ensure a graceful status code is returned despite not finding the file to delete.
  expect_equal(httr2::resp_status(resp), 204)

  # Ensure unrelated files are untouched.
  expect_true(file.exists(filepath))
})


testthat::test_that("DELETE to the progress deletion function with a dataSetId for an existing progress file deletes the progress file", {
  
  data_set_id = "existing"

  # Create a temporary existing progress file.
  filepath = create_progress_file(data_set_id)

  expect_true(file.exists(filepath))

  request <- api_url(api_host(), api_port()) |>
    httr2::request() |>
    httr2::req_url_path("api/progress") |>
    httr2::req_url_query(dataSetId = data_set_id) |>
    httr2::req_method("DELETE")

  resp <- httr2::req_perform(request)

  expect_equal(httr2::resp_status(resp), 204)

  # Ensure the target file was successfully deleted.
  expect_false(file.exists(filepath))
})