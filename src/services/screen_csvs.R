#* Screen data set files located at the supplied blob storage paths using the eesyscreener package
#* If the storage account environment variables are not set, local file paths will be assumed instead
screen_csvs <- function(
  data_file_path,
  data_file_name,
  data_file_sas_token,
  meta_file_path,
  meta_file_name,
  meta_file_sas_token,
  data_set_id = NULL,
  log_dir = NULL) {
  
  library(eesyscreener)
  library(curl)

  storage_account_url <- Sys.getenv("STORAGE_URL")
  blob_container_name <- Sys.getenv("STORAGE_CONTAINER_NAME")
  dd_checks <- as.logical(Sys.getenv("DD_CHECKS", unset = "TRUE"))
  
  use_local_storage <- all(
    storage_account_url == "",
    blob_container_name == ""
  )

  if (use_local_storage) {
    temp_data_path <- data_file_path
    temp_meta_path <- meta_file_path

    message(
      "Storage account environment variables not set. Using local files: ",
      temp_data_path,
      " and ", temp_meta_path
    )
  } else {
    temp_data_path <- paste0(tempdir(), "/", data_file_name)
    temp_meta_path <- paste0(tempdir(), "/", meta_file_name)

    data_file_url_with_token <- paste0(storage_account_url, "/", blob_container_name, "/", data_file_path, "?", data_file_sas_token)
    meta_file_url_with_token <- paste0(storage_account_url, "/", blob_container_name, "/", meta_file_path, "?", meta_file_sas_token)

    h <- new_handle()
    handle_setheaders(h, "Accept-Encoding" = "gzip, zstd")

    message(
      "Downloading data file from Azure Blob Storage: ",
      data_file_path,
      " via URL with SAS token."
    )

    curl_download(url = data_file_url_with_token, destfile = temp_data_path, handle = h)

    message(
      "Downloading metadata file from Azure Blob Storage: ",
      meta_file_path,
      " via URL with SAS token."
    )
    
    curl_download(url = meta_file_url_with_token, destfile = temp_meta_path, handle = h)
  }

  message("Calling eesyscreener to screen downloaded files...")

  result <- screen_csv(temp_data_path, temp_meta_path, data_file_name, meta_file_name, data_set_id, log_dir, dd_checks = dd_checks)

  message("eesyscreener screened files successfully!")

  # Remove test files if sourcing from blob storage (and not if sourcing from local directory)
  if (!use_local_storage) {
    file.remove(temp_data_path)
    file.remove(temp_meta_path)
  }

  return(result)
}
