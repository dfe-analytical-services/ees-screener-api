library(jsonlite)

get_queue_message_payload <- function(req) {
  escaped_json <- fromJSON(req$postBody)
      
  escaped_json$Data |>
    gsub('^"|"$', '', x = _) |>
    gsub('\\\\\"', '"', x = _) |>
    gsub('\\\\n', '', x = _) |>
    fromJSON()
}