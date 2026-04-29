#* The Azure Function runtime alters the request when forwarding onto Functions.
#* In order to ensure we have a consistent behaviour when testing inside and
#* outside of the runtime, we get request parameters from the original unaltered
#* query string.
#* 
#* This helps us to consistently receive, for instance, repeated request
#* parameters (e.g. "?id=1&id=2") as an array of the values in the repeated
#* parameter, whether it be the original "?id=1&id=2" form, or the form rewritten
#* by the Azure Function runtime of "?id=1,2".
get_request_parameters <- function(req) {

  lapply(req$args, function(x) {
    values <- unlist(x, use.names = FALSE)

    values <- unlist(
      strsplit(values, ",", fixed = TRUE),
      use.names = FALSE
    )

    values <- trimws(values)
    values[nzchar(values)]
  })
}