#' Placeholder for future production-hardened pipeline helpers
#'
#' @details
#' Pipeline helper implementations will accumulate over time as APIs stabilize.
#' See \code{\link{admincleanr_training}} for the planned workflow.
#'
#' @return `TRUE` invisibly.
#' @export
pipe_scaffold_message <- function() {
  message(
    "Pipeline helpers are under development. ",
    "See admincleanr_training() for the current workflow."
  )
  invisible(TRUE)
}
