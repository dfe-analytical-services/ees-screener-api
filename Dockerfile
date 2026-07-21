FROM mcr.microsoft.com/azure-functions/dotnet:4.37.1-dotnet8.0

ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    AzureFunctionsJobHost__Logging__Console__IsEnabled=true \
    R_VERSION=4.5.2 \
    LOG_DIR=/tmp \
    DD_CHECKS=TRUE \
    LOG_SCREENING_RESULTS=FALSE \
    CONCURRENT_R_WORKERS=4 \
    JSON_FILES_MAX_READ_ATTEMPTS=5 \
    JSON_FILES_RETRY_WAIT_IN_SECONDS=1 \
    CRAN_REPOSITORY_SNAPSHOT_DATE=2026-07-01

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
RUN R --vanilla -e "options(repos = c(CRAN = 'https://packagemanager.posit.co/cran/__linux__/bookworm/${CRAN_REPOSITORY_SNAPSHOT_DATE}')); \
          install.packages('pak'); \
          install.packages( \
            'duckdb', \
            repos = sprintf( \
                'https://p3m.dev/cran/${CRAN_REPOSITORY_SNAPSHOT_DATE}/bin/linux/manylinux_2_28-%s/%s', \
                R.version['arch'], \
                substr(getRversion(), 1, 3) \
            ) \
          ); \
          pak::pkg_install(c('dfe-analytical-services/eesyscreener@v0.3.2', 'deps::.'), upgrade = FALSE);"

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
RUN sed -i 's/\r$//' /entrypoint.sh

# Call entrypoint script to dynamically set the "batchSize" queue property
# as an environment variable, based upon the value of "CONCURRENT_R_WORKERS".
ENTRYPOINT ["/entrypoint.sh"]