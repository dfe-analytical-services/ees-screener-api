#* Test the service is running
#* @serializer unboxedJSON
#* @get /api/screen
test_get <- function() {
  list("Success")
}

#* Screen data set files located at the supplied blob storage paths using the eesyscreener package
#* If the storage account environment variables are not set, local file paths will be assumed instead
#* @parser json
#* @serializer unboxedJSON
#* @post /api/screen
screen <- function(req, res) {
  library(eesyscreener)
  library(curl)

  storage_account_url <- Sys.getenv("STORAGE_URL")
  blob_container_name <- Sys.getenv("STORAGE_CONTAINER_NAME")

  use_local_storage <- all(
    storage_account_url == "",
    blob_container_name == ""
  )

  data_file_path <- req$body$dataFilePath
  data_file_name <- req$body$dataFileName
  data_file_sas_token <- req$body$dataFileSasToken
  meta_file_path <- req$body$metaFilePath
  meta_file_name <- req$body$metaFileName
  meta_file_sas_token <- req$body$metaFileSasToken

  if (use_local_storage) {
    temp_data_path <- data_file_path
    temp_meta_path <- meta_file_path

    message(
      "Storage account environment variables not set. Using local files: ",
      temp_data_path,
      " and ",
      temp_meta_path
    )
  } else {
    temp_data_path <- paste0(tempdir(), "/", data_file_name)
    temp_meta_path <- paste0(tempdir(), "/", meta_file_name)

    data_file_url_with_token <- paste0(
      storage_account_url,
      "/",
      blob_container_name,
      "/",
      data_file_path,
      "?",
      data_file_sas_token
    )
    meta_file_url_with_token <- paste0(
      storage_account_url,
      "/",
      blob_container_name,
      "/",
      meta_file_path,
      "?",
      meta_file_sas_token
    )

    message(
      "Downloading files from Azure Blob Storage: ",
      data_file_path,
      " and ",
      meta_file_path,
      " via URL with SAS token "
    )

    result <- tryCatch(
      {
        h <- new_handle()
        handle_setheaders(h, "Accept-Encoding" = "gzip, zstd")

        curl_download(
          url = data_file_url_with_token,
          destfile = temp_data_path,
          handle = h
        )
        curl_download(
          url = meta_file_url_with_token,
          destfile = temp_meta_path,
          handle = h
        )
      },
      error = function(e) {
        res$status <- 400
        res$body <- paste0("Data failed to transfer from blob storage: ", e)
      }
    )
  }

  result <- tryCatch(
    {
      result <- screen_csv(
        temp_data_path,
        temp_meta_path,
        data_file_name,
        meta_file_name
      )

      # Remove test files if sourcing from blob storage (and not if sourcing from local directory)
      if (!use_local_storage) {
        file.remove(temp_data_path)
        file.remove(temp_meta_path)
      }

      res$status <- 200
      res$body <- result
    },
    error = function(e) {
      print(paste0("Error details: ", e))
      res$status <- 400
      res$body <- paste0("An unhandled exception occurred in eesyscreener: ", e)
      # TODO: Add logging
    },
    finally = {
      # Intentionally blank
    }
  )
}
