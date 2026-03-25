library(jsonlite)

#* The Azure Function runtime delivers queue message JSON bodies as a
#* double-encoded JSON string under an overarching "Data" field.
#* Given a queue-triggered Function's HTTP request, this function
#* returns the original queue message payload as an object.
#* 
#* The reason that a queue-triggered Function has to be supported with
#* an HTTP request route is because this is how the Azure Function host
#* supports queue-triggered Functions in a non-native Function App
#* project.
get_queue_message_payload <- function(req) {
  escaped_json <- fromJSON(req$postBody)
      
  escaped_json$Data |>
    gsub('^"|"$', '', x = _) |>
    gsub('\\\\\"', '"', x = _) |>
    gsub('\\\\n', '', x = _) |>
    fromJSON()
}