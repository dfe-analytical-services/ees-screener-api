#* Screen data set files located at the supplied blob storage paths using the eesyscreener package
#* If the storage account environment variables are not set, local file paths will be assumed instead
handle_screen <- function(req, res) {
  
  source(here::here("services/screen_csvs.R"))
  
  data_file_path <- req$body$dataFilePath
  data_file_name <- req$body$dataFileName
  data_file_sas_token <- req$body$dataFileSasToken
  meta_file_path <- req$body$metaFilePath
  meta_file_name <- req$body$metaFileName
  meta_file_sas_token <- req$body$metaFileSasToken

  result <- tryCatch({

    result <- screen_csvs(data_file_path, data_file_name, data_file_sas_token, meta_file_path, meta_file_name, meta_file_sas_token)

    res$status <- 200
    res$body <- result
  }, error = function(e) {
    print(paste0("Error details: ", e))
    res$status <- 400
    res$body <- paste0("An unhandled exception occurred in eesyscreener: ", e)
    # TODO: Add logging
  }, finally = {
    # Intentionally blank
  })
}
