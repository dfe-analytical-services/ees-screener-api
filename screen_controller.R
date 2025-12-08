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
  library(AzureStor)

  storage_account_url <- Sys.getenv("STORAGE_URL")
  storage_account_key <- Sys.getenv("STORAGE_KEY")
  blob_container_name <- Sys.getenv("STORAGE_CONTAINER_NAME")

  use_local_storage <- all(
    storage_account_url == "",
    storage_account_key == "",
    blob_container_name == ""
  )

  data_file_name <- req$body$dataFileName
  meta_file_name <- req$body$metaFileName

  if (use_local_storage) {
    temp_data_path <- req$body$dataFilePath
    temp_meta_path <- req$body$metaFilePath

    message(
      "Storage account environment variables not set. Using local files: ",
      temp_data_path,
      " and ",
      temp_meta_path
    )
  } else {
    temp_data_path <- paste0(tempdir(), "/", data_file_name)
    temp_meta_path <- paste0(tempdir(), "/", meta_file_name)

    az_data_file_path <- req$body$dataFilePath
    az_meta_file_path <- req$body$metaFilePath

    message(
      "Downloading files from Azure Blob Storage: ",
      az_data_file_path,
      " and ",
      az_meta_file_path
    )

    endpoint <- blob_endpoint(storage_account_url, key = storage_account_key)
    container <- blob_container(endpoint, blob_container_name)
    result <- tryCatch(
      {
        storage_download(
          container,
          src = az_data_file_path,
          dest = temp_data_path
        )
        storage_download(
          container,
          src = az_meta_file_path,
          dest = temp_meta_path
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
