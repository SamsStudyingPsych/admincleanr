#' Placeholder until pipeline helpers migrate here
#'
#' @details
#' This function namespaces the \dQuote{pipe} workflow story (explicit contracts,
#' minimal dependencies). Production-hardened transforms (explicit parsers,
#' contract checks) will be added over time.
#'
#' @return `TRUE` invisibly.
#' @export
pipe_scaffold_message <- function() {
  message(
    "admincleanr_pipe is a scaffold. Load admincleanr for active helpers; ",
    "see README.md for the migration plan."
  )
  invisible(TRUE)
}
