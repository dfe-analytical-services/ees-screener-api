#* Test the service is running
#* @serializer unboxedJSON
#* @get /api/screen
test_get <- function() {
    list("Success")
}

#* Screen files using the eesyscreener package
#* @parser multi
#* @parser csv
#* @serializer unboxedJSON
#* @post /api/screen
screen <- function(req, res) {
    library(eesyscreener)
    library(vroom)

    result <- tryCatch({
        data_frame <- vroom(req$body$dataFile$value)
        meta_data_frame <- vroom(req$body$metaFile$value)

        result <- screen_files(req$body$dataFile$filename, req$body$metaFile$filename, data_frame, meta_data_frame)
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
