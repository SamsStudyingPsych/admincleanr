#' Attach the usual interactive analysis stack
#'
#' Calls \code{library()} on \pkg{tidyverse}, \pkg{janitor}, \pkg{readxl},
#' \pkg{DBI}, and \pkg{odbc} with startup messages suppressed. Use when you want
#' the same environment you get from hand-typing five \code{library()} lines.
#'
#' @return \code{NULL} invisibly.
#' @section Workflow integration:
#' \itemize{
#'   \item Set \code{options(admincleanr.autoload_workbench = TRUE)} before
#'     \code{library(admincleanr)} to auto-attach in interactive sessions (see
#'     package attach hook).
#'   \item Set \code{options(admincleanr.autoload_workbench = FALSE)} on servers
#'     or \code{R CMD check} contexts where silent attach is undesirable.
#' }
#' @export
#' @examples
#' \dontrun{
#' admincleanr_attach_workbench()
#' }
admincleanr_attach_workbench <- function() {
  suppressPackageStartupMessages({
    library(tidyverse)
    library(janitor)
    library(readxl)
    library(DBI)
    library(odbc)
  })
  invisible()
}
