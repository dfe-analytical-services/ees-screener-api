library(stringi)

source("../../utils/queue_trigger_test_utils.R")
source("../../utils/progress_file_test_utils.R")

testthat::test_that("POST to the queue-triggered start_screening function returns success and provides a progress and completion report for valid local files", {
  
  data_set_id = stri_rand_strings(1, 10)[1]

  body <- create_queue_trigger_message_payload(
    'startScreening',
    list(
      data_file_name = "pass.csv",
      data_file_path = "example-data/pass.csv",
      meta_file_name = "pass.meta.csv",
      meta_file_path = "example-data/pass.meta.csv",
      data_set_id = data_set_id
    )
  )

  resp <- httr2::request(api_url(api_host(), api_port())) |>
    httr2::req_url_path("/function_start_screening") |>
    httr2::req_body_json(body) |>
    httr2::req_method("POST") |>
    httr2::req_perform()

  expect_equal(httr2::resp_status(resp), 200)

  result <- httr2::resp_body_json(resp)

  expect_equal(result$message, "Screening started.")

  # Check that a progress log has been output and that it shows the screening process
  # has completed successfully.
  progress_log <- get_progress_file(data_set_id)

  expect_equal(progress_log$progress[[1]], 100)
  expect_equal(progress_log$status[[1]], "PASS")
  expect_equal(progress_log$completed[[1]], TRUE)

  completion_report <- get_completion_report(data_set_id)

  expect_true(is.list(completion_report))
  
  expect_equal(completion_report$overall_stage[[1]], "Passed")
  expect_equal(completion_report$passed[[1]], TRUE)
  expect_equal(completion_report$api_suitable[[1]], FALSE)
  expect_true(length(completion_report$results_table) > 0)
})

testthat::test_that("POST to the queue-triggered start_screening function returns error for missing files", {
  
  data_set_id = stri_rand_strings(1, 10)[1]

  body <- create_queue_trigger_message_payload(
    'startScreening',
    list(
      data_file_name = "missing.csv",
      data_file_path = "example-data/missing.csv",
      meta_file_name = "missing.meta.csv",
      meta_file_path = "example-data/missing.meta.csv",
      data_set_id = data_set_id
    )
  )

  resp <- httr2::request(api_url(api_host(), api_port())) |>
    httr2::req_error(is_error = function(resp) FALSE) |>
    httr2::req_url_path("/function_start_screening") |>
    httr2::req_body_json(body) |>
    httr2::req_method("POST") |>
    httr2::req_perform()
    
  expect_equal(httr2::resp_status(resp), 200)

  result <- httr2::resp_body_json(resp)

  expect_equal(result$message, "Screening started.")

  # Expect a progress file to have been created showing that screening failed due to missing
  # files.
  progress_log <- get_progress_file(data_set_id)
  
  expect_equal(progress_log$progress[[1]], 0)
  expect_equal(progress_log$status[[1]], "No file found at example-data/missing.csv")
  expect_equal(progress_log$completed[[1]], TRUE)

  # Expect a completion file to have been created that shows a failure to screen.
  completion_report <- get_completion_report(data_set_id)

  expect_true(is.list(completion_report))
  
  expect_equal(completion_report$overall_stage[[1]], "No file found at example-data/missing.csv")
  expect_equal(completion_report$passed[[1]], FALSE)
  expect_equal(completion_report$api_suitable[[1]], FALSE)
  expect_equal(completion_report$results_table, list())
})
