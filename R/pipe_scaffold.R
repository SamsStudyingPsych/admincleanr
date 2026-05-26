#' Placeholder until pipeline helpers migrate here
#'
#' @details
#' Pipeline scaffold helpers are reserved for production-hardened transforms
#' (explicit parsers, contract checks) as they are promoted out of exploratory
#' scripts.
#'
#' @section Workflow integration:
#' \itemize{
#'   \item See \code{\link{admincleanr_training}} for the planned split between heuristic and pipe-stable code.
#' }
#'
#' @return `TRUE` invisibly.
#' @export
pipe_scaffold_message <- function() {
  message(
    "Pipeline scaffold: production-hardened transforms will be added here over time; ",
    "see README.md for the migration plan."
  )
  invisible(TRUE)
}
