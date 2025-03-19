#* Check the service is healthy
#* @serializer unboxedJSON
#* @get /api/healthcheck
get <- function() {
    list("Success")
}
