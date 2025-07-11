#* Screen data set files located at the supplied blob storage paths using the eesyscreener package
#* @parser json
#* @serializer unboxedJSON
#* @post /api/screen
screen <- function(req, res) {
    library(eesyscreener)
    library(vroom)
    library(AzureStor)

    storage_account_url <- Sys.getenv("STORAGE_URL")
    storage_account_key <- Sys.getenv("STORAGE_KEY")
    blob_container_name <- Sys.getenv("STORAGE_CONTAINER_NAME")

    endpoint <- blob_endpoint(storage_account_url, key = storage_account_key)
    container <- blob_container(endpoint, blob_container_name)

    data_file_name <- req$body$dataFileName
    data_file_path <- req$body$dataFilePath
    meta_file_name <- req$body$metaFileName
    meta_file_path <- req$body$metaFilePath

    data_file <- storage_download(container, src = data_file_path, dest = NULL)
    meta_file <- storage_download(container, src = meta_file_path, dest = NULL)

    result <- tryCatch({
        data_frame <- vroom(data_file)
        meta_data_frame <- vroom(meta_file)

        result <- screen_files(data_file_name, meta_file_name, data_frame, meta_data_frame)
        res$status <- 200
        res$body <- result
    }, warning = function(w) {
        # TODO: Add logging
    }, error = function(e) {
        print(paste0("Error details: ", e))
        res$status <- 400
        res$body <- paste0("An unhandled exception occurred in eesyscreener: ", e)
        # TODO: Add logging
    }, finally = {
        # Intentionally blank
    })
}
