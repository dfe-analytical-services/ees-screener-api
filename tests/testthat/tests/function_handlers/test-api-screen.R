testthat::test_that("POST to the HTTP-triggered screen function returns success and expected structure for valid local files", {
  body <- list(
    dataFileName = "pass.csv",
    dataFilePath = "example-data/pass.csv",
    metaFileName = "pass.meta.csv",
    metaFilePath = "example-data/pass.meta.csv"
  )
  
  resp <- httr2::request(api_url(api_host(), api_port())) |>
    httr2::req_url_path("/api/screen") |>
    httr2::req_body_json(body) |>
    httr2::req_method("POST") |>
    httr2::req_perform()
  
  expect_equal(httr2::resp_status(resp), 200)

  result <- httr2::resp_body_json(resp)

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

testthat::test_that("POST to the HTTP-triggered screen function returns error for missing files", {
  body <- list(
    dataFileName = "missing.csv",
    dataFilePath = "example-data/missing.csv",
    metaFileName = "missing.meta.csv",
    metaFilePath = "example-data/missing.meta.csv"
  )
  resp <- httr2::request(api_url(api_host(), api_port())) |>
    httr2::req_error(is_error = function(resp) FALSE) |>
    httr2::req_url_path("/api/screen") |>
    httr2::req_body_json(body) |>
    httr2::req_method("POST") |>
    httr2::req_perform()
  
  expect_equal(httr2::resp_status(resp), 200)
  result <- httr2::resp_body_string(resp)

  # error message originates from eesyscreener
  expect_match(result, "No file found at example-data/missing.csv")
})