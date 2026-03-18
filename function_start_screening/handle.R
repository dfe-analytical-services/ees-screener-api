source("utils/queue_triggers.R")

start_screening <- function(req, res) {

  payload <- get_queue_message_payload(req)
  
  dataSetId <- payload$startScreening$dataSetId

  message("Processing data set: ", dataSetId, "\n")
  
  list(
    status = 200,
    headers = list("Content-Type" = "application/json"),
    body = list(message = paste0("Screening started for dataSetId ", dataSetId))
  )
}