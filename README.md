# dfe-ees-screener

A containerised Azure Function App consisting of an R Plumber API for the [DfE's data screener](https://github.com/dfe-analytical-services/eesyscreener).

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
> The GET endpoint is just to confirm the API is running.

> For the POST endpoint, `dataFile` and `metaFile` arguments should be submitted with a `form-data` request body. Example files can be found in the "example-data" folder

### Running locally from the CLI

1. Ensure that Rscript is executable (check with `Rscript --version`).
2. Run: `Rscript server.R`
3. Call an endpoint at `http://localhost:8000/api/screen`.

## Running the R services via the Azure Fucntions runtime

### In Docker

The API can also be run in a Docker container that is running the Azure Functions runtime.

Open up a terminal in the root of the project, and create an image using

```
docker build -t eesyscreener .
```

then run it using

```
docker run --rm --name eesyscreener -p 80:80 eesyscreener
```

and call the Azure Function endpoint at http://localhost/api/screen.

### Locally

The API can also be run directly from a local development environment, assuming that the required dependencies 
have been installed. This includes:
* [Azure Functions Core Tools](https://learn.microsoft.com/en-us/azure/azure-functions/functions-run-local?tabs=linux%2Cisolated-process%2Cnode-v4%2Cpython-v2%2Chttp-trigger%2Ccontainer-apps&pivots=programming-language-csharp#install-the-azure-functions-core-tools).
* RScript, the eesyscreener R package and the various dependencies that eesyscreener will need to run.
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

You may need to enter `pak::lockfile_install` to install the dependencies locally before running the API.

If any additional dependencies are added, run the following command to update the lockfile before commiting changes.

```
pak::lockfile_create(pkg = c("plumber", "github::dfe-analytical-services/eesyscreener", "readr", "<additional dependency 1>", "<additional dependency 2>"))
```

## Testing

If the data and meta files supplied to the POST endpoint generate an error from `eesyscreener`, and you only want to generate a successful response for testing, replace the function call in `screen_Controller.R`:

```
result <- screen_files(req$body$dataFile$filename, req$body$metaFile$filename, req$body$dataFile, req$body$metaFile)
```

with

```
write.csv(example_data, "example_data.csv", row.names = FALSE)
write.csv(example_data.meta, "example_data.meta.csv", row.names = FALSE)
result <- screen_files("example_data.csv", "example_data.meta.csv", example_data, example_data.meta)
```
