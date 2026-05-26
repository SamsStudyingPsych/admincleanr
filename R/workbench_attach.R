#' Attach the usual analysis stack (tidyverse, janitor, readxl, DBI, ODBC)
#'
#' Calls \code{library()} on \pkg{tidyverse}, \pkg{janitor}, \pkg{readxl},
#' \pkg{DBI}, and \pkg{odbc} with startup messages suppressed. Use when you want
#' the same environment you get from hand-typing five \code{library()} lines.
#'
#' @return \code{NULL} invisibly.
#' @section Workflow integration:
#' \itemize{
#'   \item By default, \code{library(admincleanr)} runs this automatically in
#'     normal sessions (console, \code{Rscript}, and batch jobs) so you can call
#'     \verb{mutate()}, \verb{read_excel()}, and other workbench verbs without
#'     \verb{package::} prefixes. When \code{admincleanr.autoload_workbench} is
#'     unset it defaults to \code{TRUE}; set \code{options(admincleanr.autoload_workbench = FALSE)}
#'     to disable (for example on servers with strict attach policy).
#'   \item During \code{R CMD check} on \pkg{admincleanr} itself, auto-attach is
#'     skipped even when the option is \code{TRUE}.
#'   \item If required workbench packages are missing, auto-attach fails with a
#'     startup message; install dependencies or call
#'     \code{admincleanr_attach_workbench()} after fixing the installation.
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

#' Attach the optional \pkg{admincleanr_crunch} companion
#'
#' Installs of the main package do not require \pkg{admincleanr_crunch}, but when
#' it is present this helper (and the attach hook) load it so heuristic helpers
#' such as \code{coerce_best_datetime()} are available without the
#' \code{admincleanr_crunch::} prefix.
#'
#' @return \code{NULL} invisibly.
#' @export
#' @examples
#' \dontrun{
#' admincleanr_attach_crunch()
#' }
admincleanr_attach_crunch <- function() {
  if (!requireNamespace("admincleanr_crunch", quietly = TRUE)) {
    stop(
      "Package 'admincleanr_crunch' is not installed. ",
      "pak::pak(\"SamsStudyingPsych/admincleanr\", subdir = \"admincleanr_crunch\")",
      call. = FALSE
    )
  }
  suppressPackageStartupMessages(
    library(admincleanr_crunch, character.only = TRUE)
  )
  invisible()
}
