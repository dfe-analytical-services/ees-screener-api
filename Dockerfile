FROM r-base:4.4.2

RUN apt-get update && apt-get install -y libcurl4-openssl-dev
RUN R -e "install.packages('pak')"
RUN R -e "pak::pkg_install('plumber')"
RUN R -e "pak::pkg_install('dfe-analytical-services/eesyscreener')"
RUN R -e "pak::pkg_install('readr')"

COPY / /

EXPOSE 8000

ENTRYPOINT ["Rscript", "server.R"]
