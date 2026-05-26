#' Placeholder until pipeline helpers migrate here
#'
#' @details
#' The \dQuote{pipe} workflow story (explicit contracts, minimal dependencies) is
#' reserved for production-hardened transforms as they are promoted out of
#' exploratory scripts.
#'
#' @section Workflow integration:
#' \itemize{
#'   \item Reserve this namespace for **production-hardened** transforms (explicit parsers, contract checks) as they are promoted out of exploratory scripts.
#'   \item See \code{\link{admincleanr_training}} for the planned split between heuristic helpers and pipe-stable code.
#' }
#'
#' @return `TRUE` invisibly.
#' @export
pipe_scaffold_message <- function() {
  message(
    "admincleanr_pipe helpers are now part of admincleanr. ",
    "See README.md for the migration plan."
  )
  invisible(TRUE)
}
