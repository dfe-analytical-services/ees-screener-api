#* Create a progress JSON file to represent the current screening progress for a particular data set.
create_progress_file <- function(data_set_id, percentage_complete = 100, stage = 'Complete', completed = TRUE) {
  
  filepath = paste0(tempdir(), "/eesyscreener_log_", data_set_id, ".json")

  file_content <- list(
    progress = percentage_complete,
    status = stage,
    completed = completed,
    results = list(
      list(
        check = "meta_ind_unit",
        result = "PASS",
        message = "No filters have an indicator_unit value.",
        guidance_url = "NA",
        stage = "Check meta"
      )
    )
  )

  write_json(file_content, paste0(tempdir(), "/eesyscreener_log_", data_set_id, ".json"))

  return(filepath)
}

get_progress_file <- function(data_set_id) {
  filepath = paste0(tempdir(), "/eesyscreener_log_", data_set_id, ".json")
  return (read_json(filepath))
}