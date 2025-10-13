# DfE EES Screener API

A containerised Azure Function App consisting of an R Plumber API for the [DfE's data screener](https://github.com/dfe-analytical-services/eesyscreener).

See [Request format](#request-format) for details on how to contruct API requests.

## Running the R services directly

### Running locally in VS Code

1. Download R binary (https://www.stats.bris.ac.uk/R/)
2. Download the [R Extension for VS Code](https://marketplace.visualstudio.com/items?itemName=REditorSupport.r), you may be prompted to download the `languageservice` to use R code locally. Alternatively you can use an R-specific IDE such as [RStudio](https://posit.co/download/rstudio-desktop/)
3. Open `server.R` click the Run button at the top of the file. Alternatively, open an R Terminal and use the command `source("server.R")`
4. Open up Postman/PowerShell/curl etc. to hit the endpoints:

```
GET localhost:8000/api/screen
POST localhost:8000/api/screen
```

### Running locally from the CLI

1. Ensure that Rscript is executable (check with `Rscript --version`).
2. Run: `Rscript server.R`
3. Call an endpoint at `http://localhost:8000/api/screen`.

## Running the R services via the Azure Functions runtime

### In Docker

The API can also be run in a Docker container that is running the Azure Functions runtime.

Open up a terminal in the root of the project, and create an image using

```
docker build -t data-screener .
```

then run it using

```
docker run --rm --name data-screener --network explore-education-statistics_default -p 7078:80 data-screener
```

and call the Azure Function endpoint at http://localhost/api/screen.

> ℹ️ The `--network` parameter used here assumes you are using the storage container configured by the main EES project (see [Dependencies > Azurite](#azurite) for details on how to contruct API requests for further details).

### Locally

The API can also be run directly from a local development environment, assuming that the required dependencies
have been installed. This includes:

- [Azure Functions Core Tools](https://learn.microsoft.com/en-us/azure/azure-functions/functions-run-local?tabs=linux%2Cisolated-process%2Cnode-v4%2Cpython-v2%2Chttp-trigger%2Ccontainer-apps&pivots=programming-language-csharp#install-the-azure-functions-core-tools).
- RScript, the eesyscreener R package and the various dependencies that eesyscreener will need to run.
  For a full list of steps to install the dependencies required, refer to the commands executed in the
  [Dockerfile](./Dockerfile).

After installing the above, the Azure Functions runtime can be started with:

```
func start
```

and the API can be called via the Azure Functions runtime by calling:

```
http://localhost:7071/api/screen
```

## Dependencies

### Packages

You may need to run `pak::lockfile_install` in the R terminal to install dependencies before running the API locally.

If any additional dependencies are added, run the following command to update the lockfile before commiting changes.

```
pak::lockfile_create(pkg = c("plumber", "github::dfe-analytical-services/eesyscreener", "AzureStor", "<additional dependency 1>", "<additional dependency 2>"))
```

### Azurite

The screener's `POST` endpoint retrieves files from a local blob storage container based on the paths supplied in the request body. The connection details hard-coded into [screen_Controller.R](./screen_Controller.R) relate to the same storage container used by the main EES solution. This container can be started up by opening a terminal in the main project directory and running the start script, e.g.:

```
cd source/repos/dfe-analytical-services/explore-education-statistics
pnpm start dataStorage
```

If using a different storage container, the connection details can be changed by replacing the destination URL, key and container name in the controller. The custom storage container should also be assigned a `network`, so that the API can be started within the same network to allow cross-container communication.

## Request format

The `GET` endpoint is just a health check to confirm the API is running, and expects no parameters: `GET <url>/api/screen`.

The `POST` endpoint uses the same URL as `GET`, and expects a JSON request body in the following format:

```
{
    "dataFileName": "data.csv",
    "dataFilePath": "00ffd291-2ff2-4b65-46c5-08dd9ec03382/data/0d5a5bc6-b12c-4ed4-986e-517679b49f88",
    "metaFileName": "meta.data.csv",
    "metaFilePath:": "00ffd291-2ff2-4b65-46c5-08dd9ec03382/data/f9c951bc-85a0-48ab-a0be-8eab3fc8dcee"
}
```

> ℹ️ Path format is `<releaseVersionId>/data/<fileId>`.

> ℹ️ Example files can be found in the "example-data" folder.

## Testing

If the data and meta files supplied to the POST endpoint generate an error from `eesyscreener`, and you only want to generate a successful response for testing, replace the function call in `screen_controller.R`:

```r
result <- eesyscreener::screen_csv(data_file, meta_file, data_file_name, meta_file_name)
```

with

```r
write.csv(eesyscreener::example_data, "example_data.csv", row.names = FALSE)
write.csv(eesyscreener::example_meta, "example_data.meta.csv", row.names = FALSE)
result <- eesyscreener::screen_csv("example_data.csv", "example_data.meta.csv")
```
