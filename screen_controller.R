#* Test the service is running
#* @serializer unboxedJSON
#* @get /screen
test_get <- function() {
    list("Success")
}

#* Screen files using the eesyscreener package
#* @parser multi
#* @parser form
#* @parser csv
#* @serializer unboxedJSON
#* @post /screen
test_post <- function(req, res) {
    library(eesyscreener)

    result <- tryCatch({
        result <- screen_files(req$body$dataFile$filename, req$body$metaFile$filename, req$body$dataFile, req$body$metaFile)
        res$status <- 200
        res$body <- result
    }, warning = function(w) {
        # TODO: Add logging
    }, error = function(e) {
        print(paste0("Error details: ", e))
        res$status <- 400
        res$body <- paste0("An unhandled exception occurred in eesyscreener, indicating a malformed data or meta file: ", e)
        # TODO: Add logging
    }, finally = {
        # Intentionally blank
    })
}
