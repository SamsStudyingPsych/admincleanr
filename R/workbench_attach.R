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
#'     \verb{package::} prefixes. Opt out with
#'     \code{options(admincleanr.autoload_workbench = FALSE)}.
#'   \item During \code{R CMD check} on \pkg{admincleanr} itself, auto-attach is
#'     skipped even when the option is \code{TRUE}.
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
