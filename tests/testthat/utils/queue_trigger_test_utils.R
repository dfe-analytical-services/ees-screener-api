create_queue_trigger_message_payload <- function(functionName, data) {
  innerResult = list()
  innerResult[[functionName]] = toJSON(
    toJSON(data, pretty = TRUE, auto_unbox = TRUE), 
    auto_unbox = TRUE
  )
  
  list(
    Data = innerResult
  )
}