FROM mcr.microsoft.com/azure-functions/dotnet:4-dotnet8.0

ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    AzureFunctionsJobHost__Logging__Console__IsEnabled=true \
    R_VERSION=4.5.2

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

# Install R packages using pre-complied binaries for Debian 12 (Bookworm)
RUN R -e "options(repos = c(CRAN = 'https://packagemanager.posit.co/cran/__linux__/bookworm/latest')); \
           install.packages('pak'); \
           pak::pak(c('plumber@1.3.0', 'dfe-analytical-services/eesyscreener@v0.1.5'));"

WORKDIR /home/site/wwwroot
COPY / /home/site/wwwroot
