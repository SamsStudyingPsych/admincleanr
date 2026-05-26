#' Attach the usual interactive analysis stack
#'
#' Calls \code{library()} on \pkg{tidyverse}, \pkg{janitor}, \pkg{readxl},
#' \pkg{DBI}, and \pkg{odbc} with startup messages suppressed. Optionally also
#' attaches companion packages (\pkg{admincleanr_crunch}, \pkg{admincleanr_pipe})
#' when they are installed, so their exported helpers can be called without
#' \code{pkg::} prefixes.
#'
#' @param attach_companions Logical; if \code{TRUE}, attempt to attach companion
#'   packages when available.
#' @param warn_missing_companions Logical; if \code{TRUE}, emit startup messages
#'   when requested companion packages are not installed.
#' @return \code{NULL} invisibly.
#' @section Workflow integration:
#' \itemize{
#'   \item Set \code{options(admincleanr.autoload_workbench = TRUE)} before
#'     \code{library(admincleanr)} to auto-attach in interactive sessions (see
#'     package attach hook).
#'   \item Set \code{options(admincleanr.autoload_companions = FALSE)} to keep
#'     companion packages from auto-attaching.
#'   \item Set \code{options(admincleanr.autoload_workbench = FALSE)} on servers
#'     or \code{R CMD check} contexts where silent attach is undesirable.
#' }
#' @export
#' @examples
#' \dontrun{
#' admincleanr_attach_workbench()
#' }
admincleanr_attach_workbench <- function(
  attach_companions = getOption("admincleanr.autoload_companions", interactive()),
  warn_missing_companions = interactive()
) {
  suppressPackageStartupMessages({
    library(tidyverse)
    library(janitor)
    library(readxl)
    library(DBI)
    library(odbc)
  })

  if (isTRUE(attach_companions)) {
    for (pkg in c("admincleanr_crunch", "admincleanr_pipe")) {
      if (requireNamespace(pkg, quietly = TRUE)) {
        suppressPackageStartupMessages(
          library(pkg, character.only = TRUE)
        )
      } else if (isTRUE(warn_missing_companions)) {
        packageStartupMessage(
          sprintf(
            "%s not installed; skipping auto-attach. Install from this repo subdir to expose its exported helpers.",
            pkg
          )
        )
      }
    }
  }

  invisible()
}
