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
  
  envelope <- fromJSON(req$postBody)
  
  raw_string <- envelope$Data[[1]]

  # Double-unescape the double-escaped JSON string.
  fromJSON(fromJSON(raw_string))
}