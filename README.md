# DfE EES Screener API

[![R-CMD-check](https://github.com/dfe-analytical-services/ees-screener-api/actions/workflows/testthat.yml/badge.svg)](https://github.com/dfe-analytical-services/ees-screener-api/actions)

A containerised Azure Function App consisting of an R Plumber API for the [DfE's data screener](https://github.com/dfe-analytical-services/eesyscreener).

See [Request format](#request-format) for details on how to construct API requests.

## Running the R services directly

### If you have R set up already

1. `pak::lockfile_install()` - install dependencies
2. `source("run.R")` - set API running
3. The API healthcheck endpoint will then be live at `http://localhost:8000/api/healthcheck`

### Setup from scratch in VS Code

1. Download R binary (https://www.stats.bris.ac.uk/R/)
2. Download the [R Extension for VS Code](https://marketplace.visualstudio.com/items?itemName=REditorSupport.r), you may be prompted to download the `languageservice` to use R code locally. Alternatively you can use an R-specific IDE such as [RStudio](https://posit.co/download/rstudio-desktop/)
3. Open `run.R` click the Run button at the top of the file. Alternatively, open an R Terminal and use the command `source("run.R")`
4. Open up Postman/PowerShell/curl etc. to hit the endpoints:

```
GET localhost:8000/api/healthcheck
POST localhost:8000/function_start_screening
GET localhost:8000/api/progress?data_set_id=<data set id>
```

### Running locally from the CLI

1. Ensure that Rscript is executable (check with `Rscript --version`).
2. Run: `Rscript run.R`
3. Call an endpoint at `http://localhost:8000/api/healthcheck`.

## Running the R services via the Azure Functions runtime

### In Docker

The API can also be run in a Docker container that is running the Azure Functions runtime.

Open up a terminal in the root of the project, and create an image using

```
docker build -t data-screener .
```

then run it using

```
docker run --rm \
  --name data-screener \
  --network explore-education-statistics_default \
  -p 7078:80 \
  -e "STORAGE_URL=http://data-storage:10000/devstoreaccount1" \
  -e "STORAGE_CONTAINER_NAME=releases-temp" \
  -e "AzureWebJobs_StartScreening=DefaultEndpointsProtocol=http;AccountName=devstoreaccount1;AccountKey=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==;BlobEndpoint=http://data-storage:10000/devstoreaccount1;QueueEndpoint=http://data-storage:10001/devstoreaccount1;" \
  -e "FUNCTIONS_WORKER_RUNTIME=custom" \
  data-screener
```

and call the Azure Function healthcheck endpoint at http://localhost:7078/api/healthcheck.

The environment variables are necessary because when run using the `mcr.microsoft.com/azure-functions` base Docker image,
`local.settings.json` is not used.

> ℹ️ The `--network` parameter used here assumes you are using the storage container configured by the main EES project (see [Dependencies > Azurite](#azurite) for details on how to construct API requests for further details).

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
http://localhost:7071/api/healthcheck
```

## Dependencies

### Packages

You will need to install the R packages to run the API locally in R, update the command below and rerun. Make sure to update the Dockerfile and GitHub action as appropriate too as they are not yet working from a lockfile. `eesyscreener` needs installing separately as it is only available from GitHub currently.

```r
pak::pak("dfe-analytical-services/eesyscreener@v0.3.2")

pak::pak(
  c(
    "plumber",
    "logger",
    # below for testing only
    "testthat",
    "mirai",
    "withr",
    "httr2"
  )
)
```

In Linux, the recommended duckdb install is from binary with the following:

```
install.packages( 
  'duckdb', 
  repos = sprintf( 
    'https://p3m.dev/cran/latest/bin/linux/manylinux_2_28-%s/%s', 
    R.version['arch'], 
    substr(getRversion(), 1, 3) 
  ) 
)
```

Installing from source currently takes 50-60 mins, so not advised!

#### Alternative package management

Note on pkg.lock file. This was added as part of development, but is not currently used in workflows.

To update it with the latest versions, you can use the following (updating the eesyscreener version number as needed):

```
pak::lockfile_create(pkg = c("dfe-analytical-services/eesyscreener@v0.3.2","deps::."))
```

Restoring packages based on this lockfile, should then be doable using:

```
pak::lockfile_install()
```

### Azurite

The screener's `POST /function_start_screening` endpoint retrieves files from a blob storage container based on the environment variables `STORAGE_URL` and `STORAGE_CONTAINER_NAME`. If wanting to use the same storage container used by the main EES solution, use the following variable values:

* STORAGE_URL: `DefaultEndpointsProtocol=http;AccountName=devstoreaccount1;AccountKey=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==;BlobEndpoint=http://data-storage:10000/devstoreaccount1;QueueEndpoint=http://data-storage:10001/devstoreaccount1;`
* STORAGE_CONTAINER_NAME: `releases-temp`
```

The container can be started up by opening a terminal in the main project directory and running the start script, e.g.:

```bash
cd source/repos/dfe-analytical-services/explore-education-statistics
pnpm start dataStorage
```

If using a different storage container, the connection details can be changed by replacing the destination URL and container name in the controller. The custom storage container should also be assigned a `network`, so that the API can be started within the same network to allow cross-container communication.

If wanting to test files locally using local file storage rather than blob storage, refer to the [Testing](#testing) guide below.

## Requests and responses

The general flow for screening a file end-to-end is:

1. Screening is started using a queue message.
1. Screening progress can be regularly checked using an HTTP endpoint.
1. When screening completes (either successfully or unsuccessfully), a completion report can be requested using an HTTP endpoint.
1. After the completion report has been used, the progress and completion files can be cleaned up using an HTTP endpoint.

### Healthcheck

The `GET /api/healthcheck` endpoint is just a health check to confirm the API is running, and expects no parameters.

It produces a `200 OK` response with a body like:

```
["Success"]
```

### Start screening

The screening process is triggered via a queue message to the storage container's `start-screening` queue.  The queue message body expects the
following JSON format:

```json
{
  "data_set_id": "<a unique identifier for a data set to undergo screening>",
  "data_file_name": "<name of data file>",
  "data_file_path": "<absolute path to data file's owning container>",
  "data_file_sas_token": "<SAS token generated from storage account to read data file>",
  "meta_file_name": "<name of meta file>",
  "meta_file_path:": "<absolute path to meta file's owning container>",
  "meta_file_sas_token": "<SAS token generated from storage account to read meta file>",
}
```

e.g.

```json
{
  "data_set_id":"8ac520d9-7589-469d-8c14-08ded5ef9b4d",
  "data_file_name":"absence_school.csv",
  "data_file_path":"0d519b8b-b4c0-4afc-694b-08ded5ea9207/data/24a314dc-d815-481d-8eb0-9f2f9bc28ebe",
  "data_file_sas_token":"sv=2026-02-06\u0026se=2026-06-29T21%3A09%3A41Z\u0026sr=b\u0026sp=r\u0026sig=8w7Bb8fejYahCVRx8fUwpYPkF9RbWCYRmxFf7t7nHOs%3D",
  "meta_file_name":"absence_school.meta.csv",
  "meta_file_path":"0d519b8b-b4c0-4afc-694b-08ded5ea9207/data/64dba375-4310-4053-8b4d-c510c014d255",
  "meta_file_sas_token":"sv=2026-02-06\u0026se=2026-06-29T21%3A09%3A41Z\u0026sr=b\u0026sp=r\u0026sig=bmLzQhzd2slBxu8D9cu%2FzQa%2dF%2FvtZBpPi9m6TDy2AJc%3D"
}
```

This triggers screening as a background process.


> ℹ️ Path format is `<releaseVersionId>/data/<fileId>`.

### Screening progress

The `GET /api/progress?data_set_id=<data set 1 id>&data_set_id=<data set 2 id>` endpoint allows the current screening progress for one or more data sets 
to be checked, using the unique `data_set_id` values provided in the [Start screening](#start-screening) request.

For instance, to check on the progress of the example provided in [Start screening](#start-screening), we would call:

`GET /api/progress?data_set_id=8ac520d9-7589-469d-8c14-08ded5ef9b4d`

which would produce a `200 OK` response with a body like:

```json
[
  {
    "data_set_id": "8ac520d9-7589-469d-8c14-08ded5ef9b4d",
    "progress_report": {
      "percentage_complete": 30.67,
      "status": "Screening",
      "completed": false
    }
  }
]
```

When the value for `completed` for a data set is true, the screener has finished screening the file and a completion report will be available which will
contain the full screening result. 

### Completion report

The `GET /api/completion-reports?data_set_id=<data set 1 id>&data_set_id=<data set 2 id>` endpoint allows the screening results for one or more data sets 
to be checked, using the unique `data_set_id` values provided in the [Start screening](#start-screening) request.

This can be used for any data sets that have finished screening, as identified by use of the `completed` flag in the response from the
[Screening progress](#screening-progress) response.

For instance, to check on the completion result of the example provided in [Start screening](#start-screening), we would call:

`GET /api/completion-reports?data_set_id=8ac520d9-7589-469d-8c14-08ded5ef9b4d`

which would produce a `200 OK` response with a body like:

```json
[
  {
    "data_set_id": "8ac520d9-7589-469d-8c14-08ded5ef9b4d",
    "completion_report": {
      "passed": true,
      "api_suitable": false,
      "overall_stage": "Complete",
      "results_table": []
    }
  }
]
```

### Delete progress and completion report files

The `DELETE /api/progress-and-completion-files?data_set_id=<data set 1 id>&data_set_id=<data set 2 id>` endpoint allows the cleanup of screening
progress files and completion reports for one or more data sets, using the unique `data_set_id` values provided in the
[Start screening](#start-screening) request.

This can be used for any data sets that have finished screening, as identified by use of the `completed` flag in the response from the
[Screening progress](#screening-progress) response.

For instance, to clear up progress and completion reports of the example provided in [Start screening](#start-screening), we would call:

`DELETE /api/progress-and-completion-files?data_set_id=8ac520d9-7589-469d-8c14-08ded5ef9b4d`

which would produce a `204 No Content` response.

## Testing

Unit tests have been setup using [testthat](https://testthat.r-lib.org/) and [mirai](https://mirai.r-lib.org/index.html), you can run them locally in R using:

```
testthat::test_dir("tests/testthat/tests/function_handlers")
testthat::test_dir("tests/testthat/tests/utils")
```

If one of the environment variables isn't set from "STORAGE_URL" or "STORAGE_CONTAINER_NAME", the API will fallback to looking for local files.
You can then supply the paths to the example-data in this repository, and SAS tokens can be omitted. For example:

```json
{
  "data_set_id":"8ac520d9-7589-469d-8c14-08ded5ef9b4d",
  "data_file_name":"pass.csv",
  "data_file_path":"example-data/pass.csv",
  "meta_file_name":"pass.meta.csv",
  "meta_file_path":"example-data/pass.meta.csv",
}
```

Those files should pass reliably, if not, regenerate them using the following lines in R:

```r
write.csv(eesyscreener::example_data, "example-data/pass.csv", row.names = FALSE)
write.csv(eesyscreener::example_meta, "example-data/pass.meta.csv", row.names = FALSE)
```

For other test files that are available, review the eesyscreener docs and adapt the code above accordingly. For an example failure from the API locally use the fail.csv files:

```r
write.csv(
    eesyscreener::example_data |>
        dplyr::mutate(time_identifier = "parsec"),
    "example-data/fail.csv",
    row.names = FALSE
)
write.csv(eesyscreener::example_meta, "example-data/fail.meta.csv", row.names = FALSE)
```

request body

```json
{
  "data_set_id":"8ac520d9-7589-469d-8c14-08ded5ef9b4d",
  "data_file_name":"fail.csv",
  "data_file_path":"example-data/fail.csv",
  "meta_file_name":"fail.meta.csv",
  "meta_file_path":"example-data/fail.meta.csv",
}
```

> ℹ️ Example files can be found in the "example-data" folder. When running locally (e.g. using Postman Desktop), these can be provided in the json body to `date_file_path` and `meta_file_path` as relative paths within the local repo, e.g. `"data_file_path": "example-data/pass.csv"`.