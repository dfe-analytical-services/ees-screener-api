source(here::here("create_server.R"))

create_server() |>
  plumber::pr_run(
    host = "0.0.0.0",
    port = FORWARD_PORT
  )