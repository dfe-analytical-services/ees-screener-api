#!/bin/sh

# Limit the number of concurrent background screening jobs to 1 less than the number of concurrent R
# workers. This allows 1 worker to always be free to process progress update requests whilst the
# other workers are busy screening in the background.
#
# "newBatchThreshold" in host.json is set to 0 so that a new batch of background screening requests
# will only be fetched when all background screening processes have completed, thus ensuring we only
# run the desired maximum number of background screening processes at a time.
if [ "$CONCURRENT_R_WORKERS" = "0" ] || [ "$CONCURRENT_R_WORKERS" = "1" ]; then
  export AzureFunctionsJobHost__extensions__queues__batchSize=1
else
  export AzureFunctionsJobHost__extensions__queues__batchSize=$((CONCURRENT_R_WORKERS - 1))
fi

# Expose the eesyscreener version as an environment variable for use in the R program.
export EESYSCREENER_VERSION=$(cat /eesyscreener_version)

# Expose the build version as an environment variable for use in the R program.
export BUILD_VERSION=$(cat /build_version)

exec /azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost