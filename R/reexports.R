# ── magrittr re-export ────────────────────────────────────────────────────────

#' Pipe operator (re-exported from \pkg{magrittr})
#'
#' \code{library(admincleanr)} attaches this symbol explicitly: \code{exportPattern("^[[:alpha:]]+")}
#' in \code{NAMESPACE} does \strong{not} match \code{"\%>\%"}, so \code{export("\%>\%")} is
#' listed separately—do not remove that line from \code{NAMESPACE} unless you switch to
#' full roxygen-generated exports. Other exported helpers are also available without the
#' \code{admincleanr::} prefix after \code{library(admincleanr)}.
#'
#' @section Workflow integration:
#' \itemize{
#'   \item Use throughout **tidyverse-style** cleaning pipelines (extract \rightarrow mutate \rightarrow validate) documented in \code{\link{admincleanr_training}}.
#'   \item Keeps analysis scripts readable when chaining \pkg{admincleanr} helpers with \pkg{dplyr}.
#' }
#'
#' @importFrom magrittr %>%
#' @export
magrittr::`%>%`

#' @importFrom dplyr mutate
#' @export
dplyr::mutate

#' @importFrom dplyr filter
#' @export
dplyr::filter

#' @importFrom dplyr select
#' @export
dplyr::select

#' @importFrom dplyr left_join
#' @export
dplyr::left_join

#' @importFrom dplyr arrange
#' @export
dplyr::arrange

#' @importFrom dplyr group_by
#' @export
dplyr::group_by

#' @importFrom dplyr summarise
#' @export
dplyr::summarise

#' @importFrom dplyr pull
#' @export
dplyr::pull

#' @importFrom janitor clean_names
#' @export
janitor::clean_names

#' @importFrom readxl read_excel
#' @export
readxl::read_excel

#' @importFrom DBI dbConnect
#' @export
DBI::dbConnect

#' @importFrom DBI dbGetQuery
#' @export
DBI::dbGetQuery

#' @importFrom DBI dbDisconnect
#' @export
DBI::dbDisconnect

#' @importFrom DBI dbWriteTable
#' @export
DBI::dbWriteTable

#' @importFrom dplyr across
#' @export
dplyr::across

#' @importFrom dplyr where
#' @export
dplyr::where

#' @importFrom dplyr case_when
#' @export
dplyr::case_when

#' @importFrom dplyr bind_rows
#' @export
dplyr::bind_rows

#' @importFrom dplyr rename
#' @export
dplyr::rename

#' @importFrom dplyr distinct
#' @export
dplyr::distinct

#' @importFrom dplyr count
#' @export
dplyr::count

#' @importFrom stringr str_squish
#' @export
stringr::str_squish

#' @importFrom stringr str_trim
#' @export
stringr::str_trim

#' @importFrom tidyr pivot_longer
#' @export
tidyr::pivot_longer

#' @importFrom tidyr pivot_wider
#' @export
tidyr::pivot_wider

#' @importFrom tidyr drop_na
#' @export
tidyr::drop_na
