#' Attach the usual interactive analysis stack
#'
#' Calls \code{library()} on \pkg{tidyverse}, \pkg{janitor}, \pkg{readxl},
#' \pkg{DBI}, and \pkg{odbc} with startup messages suppressed. Use when you want
#' the same environment you get from hand-typing five \code{library()} lines.
#'
#' @return \code{NULL} invisibly.
#' @section Workflow integration:
#' \itemize{
#'   \item By default, \code{library(admincleanr)} auto-attaches this stack in
#'     interactive sessions. Set \code{options(admincleanr.autoload_workbench = TRUE)}
#'     before \code{library(admincleanr)} to attach in non-interactive jobs too.
#'   \item Set \code{options(admincleanr.autoload_workbench = FALSE)} on servers
#'     or \code{R CMD check} contexts where silent attach is undesirable.
#' }
#' @export
#' @examples
#' \dontrun{
#' admincleanr_attach_workbench()
#' }
admincleanr_attach_workbench <- function() {
  workbench_packages <- c("tidyverse", "janitor", "readxl", "DBI", "odbc")
  missing_packages <- workbench_packages[
    !vapply(workbench_packages, requireNamespace, logical(1), quietly = TRUE)
  ]

  if (length(missing_packages) > 0) {
    stop(
      "Cannot attach admincleanr workbench package(s): ",
      paste(missing_packages, collapse = ", "),
      ". Reinstall admincleanr with dependencies, e.g. ",
      "pak::pak(\"SamsStudyingPsych/admincleanr\", upgrade = \"always\").",
      call. = FALSE
    )
  }

  suppressPackageStartupMessages({
    for (pkg in workbench_packages) {
      library(pkg, character.only = TRUE)
    }
  })
  invisible()
}
