#* Create a double-encoded JSON string under an overarching "Data" field to mimic how
#* the Azure Function runtime delivers queue messages for custom Functions.
#* The equivalent unboxing of these results is done in "utils/queue_triggers.R".
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