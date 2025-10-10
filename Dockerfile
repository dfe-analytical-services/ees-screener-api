FROM mcr.microsoft.com/azure-functions/dotnet:4

ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    AzureFunctionsJobHost__Logging__Console__IsEnabled=true \
    RENV_CONFIG_PAK_ENABLED=TRUE

RUN apt-get update && apt-get -y install --no-install-recommends \
    dirmngr \
    gpg \
    gpg-agent

RUN echo "deb http://cloud.r-project.org/bin/linux/debian bullseye-cran40/" >> /etc/apt/sources.list
RUN gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 95C0FAF38DB3CCAD0C080A7BDC78B2DDEABC47B7
RUN gpg -a --export 95C0FAF38DB3CCAD0C080A7BDC78B2DDEABC47B7 | apt-key add -

RUN apt-get update && apt-get install -y --no-install-recommends r-base r-base-dev libcurl4-openssl-dev

RUN R -e "install.packages('renv', repos = c(CRAN = 'https://cloud.r-project.org'))"
COPY renv.lock renv.lock
RUN R -e "renv::restore()"

WORKDIR /home/site/wwwroot
COPY / /home/site/wwwroot
