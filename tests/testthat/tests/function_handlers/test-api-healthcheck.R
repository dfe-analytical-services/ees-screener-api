testthat::test_that("GET to the healthcheck function returns success message", {
  resp <- api_url(api_host(), api_port()) |>
    httr2::request() |>
    httr2::req_url_path("api/healthcheck") |>
    httr2::req_method("GET") |>
    httr2::req_perform()

  result <- httr2::resp_body_json(resp)

  expect_equal(result[[1]], "Success")
})