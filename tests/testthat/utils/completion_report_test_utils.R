get_completion_report <- function(data_set_id) {
  filepath = .get_completion_report_filepath(data_set_id)

  if (file.exists(filepath)) {
    return (read_json(filepath))
  }
}

create_completion_report_file <- function(
  data_set_id,
  passed = TRUE,
  api_suitable = TRUE,
  overall_stage = "Passed",
  results_table = NULL
) {
  
  filepath = .get_completion_report_filepath(data_set_id)

  file_content <- list(
    passed = passed,
    api_suitable = api_suitable,
    overall_stage = overall_stage,
    results_table = results_table %||% list(
      list(
        check = "filename_spaces",
        result = "PASS",
        message = "'pass.csv' does not have spaces in the filename.",
        stage = "filename meta"
      )
    )
  )

  write_json(file_content, filepath)

  return(filepath)
}

.get_completion_report_filepath <- function(data_set_id) {
  paste0(tempdir(), "/eesyscreener_log_", data_set_id, "_completion_report.json")
}