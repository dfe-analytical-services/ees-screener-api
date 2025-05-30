#* Test the service is running
#* @serializer unboxedJSON
#* @get /api/screen
test_get <- function() {
    list("Success")
}

#* Screen data set files located at the supplied blob storage paths using the eesyscreener package
#* @parser json
#* @serializer unboxedJSON
#* @post /api/screen
screen <- function(req, res) {
    library(eesyscreener)
    library(vroom)
    library(AzureStor)

    endpoint <- blob_endpoint("http://data-storage:10000/devstoreaccount1", key = "Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==")
    container <- blob_container(endpoint, "releases-temp")

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
