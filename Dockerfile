FROM mcr.microsoft.com/azure-functions/dotnet:4-dotnet8.0

ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    AzureFunctionsJobHost__Logging__Console__IsEnabled=true \
    R_VERSION=4.5.2 \
    LOG_DIR=/tmp \
    DD_CHECKS=TRUE \
    LOG_SCREENING_RESULTS=FALSE \
    CONCURRENT_R_WORKERS=4

# Install system dependencies and tools - https://packagemanager.posit.co/client/#/repos/cran/setup
RUN apt-get update && apt-get -y install --no-install-recommends \
    wget \
    gdebi-core \
    ca-certificates \
    dirmngr \
    gpg \
    gpg-agent \
    g++ \
    cmake \
    build-essential \
    libcurl4-openssl-dev \
    libssl-dev \
    libssh2-1-dev \
    xz-utils \
    curl

# Install R from Posit's official binary for Debian 12 (Bookworm)
RUN wget https://cdn.posit.co/r/debian-12/pkgs/r-${R_VERSION}_1_$(dpkg --print-architecture).deb && \
    gdebi -n r-${R_VERSION}_1_$(dpkg --print-architecture).deb && \
    rm r-${R_VERSION}_1_$(dpkg --print-architecture).deb && \
    ln -s /opt/R/${R_VERSION}/bin/R /usr/bin/R && \
    ln -s /opt/R/${R_VERSION}/bin/Rscript /usr/bin/Rscript

WORKDIR /home/site/wwwroot
COPY / /home/site/wwwroot

# Install R packages using pre-complied binaries for Debian 12 (Bookworm)
RUN R -e "options(repos = c(CRAN = 'https://packagemanager.posit.co/cran/__linux__/bookworm/latest')); \
          install.packages('pak'); \
          pak::pkg_install(c('dfe-analytical-services/eesyscreener@v0.3.1', 'deps::.'));"

# Limit the number of concurrent background screening jobs to 1 less than the number of concurrent R
# workers. This allows 1 worker to always be free to process progress update requests whilst the
# other workers are busy screening in the background.
#
# "newBatchThreshold" in host.json is set to 0 so that a new batch of background screening requests
# will only be fetched when all background screening processes have completed, thus ensuring we only
# run the desired maximum number of background screening processes at a time.
RUN \
  if [ "$CONCURRENT_R_WORKERS" = "0" ] || [ "$CONCURRENT_R_WORKERS" = "1" ]; then \
    echo "export AzureFunctionsJobHost__extensions__queues__batchSize=1" >> /etc/profile; \
  else \
    echo "export AzureFunctionsJobHost__extensions__queues__batchSize=$((CONCURRENT_R_WORKERS - 1))" >> /etc/profile; \
  fi
