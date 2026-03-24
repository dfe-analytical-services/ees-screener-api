testthat::test_that("GET to the healthcheck function returns success message", {
  request <- api_url(api_host(), api_port()) |>
    httr2::request() |>
    httr2::req_url_path("api/healthcheck") |>
    httr2::req_method("GET")

  result <- request |>
    httr2::req_perform() |>
    httr2::resp_body_json()

  expect_equal(result[[1]], "Success")
})