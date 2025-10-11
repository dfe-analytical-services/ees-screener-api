testthat::test_that("gets the success message", {
  request <- api_url(api_host(), api_port()) |>
    httr2::request() |>
    httr2::req_url_path("api/screen") |>
    httr2::req_method("GET")

  result <- request |>
    httr2::req_perform() |>
    httr2::resp_body_json()

  expect_equal(result[[1]], "Success")
})

testthat::test_that("POST returns success and expected structure for valid local files", {
  body <- list(
    dataFileName = "one.csv",
    dataFilePath = "example-data/one.csv",
    metaFileName = "one.meta.csv",
    metaFilePath = "example-data/one.meta.csv"
  )
  resp <- httr::POST(
    paste0(api_url(), "/api/screen"),
    body = body,
    encode = "json"
  )

  expect_equal(httr::status_code(resp), 200)
  
  result <- httr::content(resp, as = "parsed")

  expect_true(is.list(result))
  expect_equal(names(result), c("results_table", "overall_stage", "overall_message", "api_suitable"))
  expect_equal(names(result[["results_table"]][[1]]), c("check", "result", "message", "stage"))
})

testthat::test_that("POST returns error for missing files", {
  body <- list(
    dataFileName = "missing.csv",
    dataFilePath = "example-data/missing.csv",
    metaFileName = "missing.meta.csv",
    metaFilePath = "example-data/missing.meta.csv"
  )
  resp <- httr::POST(
    paste0(api_url(), "/api/screen"),
    body = body,
    encode = "json"
  )

  expect_equal(httr::status_code(resp), 400)
  result <- httr::content(resp, as = "text")
  
  expect_match(result, "unhandled exception.*No file found")
})
