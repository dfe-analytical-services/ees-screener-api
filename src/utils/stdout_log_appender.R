.stdout_con <- NULL

#* This function acts as a log appender for use with the "logger" library.
#* When registered, it will attempt to log directly to an environment's
#* stdout pipe if it can find one. This allows code running in both the main
#* R process and any background processes as well to log immediately to stdout
#* and bypass R's buffered stdout stream.
stdout_log_appender <- function(lines) {

  # Look to see if there's a Linux file for stdout in the running environment.
  # If so, write directly to it to bypass R's buffered stdout.
  #
  # The main reason we need this is to allow any code running in a future block
  # to be able to log its output immediately rather than only when the future
  # completes (as per R's standard buffered stdout behaviour).
  if (file.exists("/proc/1/fd/1")) {
    if (is.null(.stdout_con) || !isOpen(.stdout_con)) {
      .stdout_con <<- file("/proc/1/fd/1", open = "ab", raw = TRUE)
    }

    writeLines(lines, .stdout_con)
    flush(.stdout_con)
  # Otherwise output normally.
  } else {
    writeLines(lines, stdout())
    flush(stdout())
  }
}