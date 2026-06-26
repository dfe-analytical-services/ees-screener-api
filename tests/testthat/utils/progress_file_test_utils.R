get_progress_file <- function(data_set_id) {
  filepath = .get_progress_filepath(data_set_id)
  
  if (file.exists(filepath)) {
    return (read_json(filepath))
  }
}

#* Create a progress JSON file to represent the current screening progress for a particular data set.
create_progress_file <- function(data_set_id, percentage_complete = 100, status = 'Complete', completed = TRUE) {
  
  filepath = .get_progress_filepath(data_set_id)

  file_content <- list(
    progress = percentage_complete,
    status = status,
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

  write_json(file_content, filepath)

  return(filepath)
}

create_malformed_progress_file <- function(data_set_id) {

  filepath = .get_progress_filepath(data_set_id)

  # Write some incomplete JSON.
  writeLines(c('{', '  "name": "value"'), con = filepath)
}

.get_progress_filepath <- function(data_set_id) {
  paste0(tempdir(), "/eesyscreener_log_", data_set_id, ".json")
}