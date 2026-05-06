#' Placeholder until pipeline helpers migrate here
#'
#' @details
#' This package intentionally ships almost no logic today; it namespaces the
#' \dQuote{pipe} workflow story (explicit contracts, minimal dependencies) while
#' implementations still live in \code{admincleanr}.
#'
#' @return `TRUE` invisibly.
#' @export
pipe_scaffold_message <- function() {
  message(
    "admincleanr_pipe is a scaffold package. Load admincleanr for active helpers; ",
    "see README.md in this folder for the migration plan."
  )
  invisible(TRUE)
}
