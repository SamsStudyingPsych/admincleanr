#' Pipe operator (re-exported from \pkg{magrittr})
#'
#' \code{library(admincleanr)} attaches this symbol explicitly: \code{exportPattern("^[[:alpha:]]+")}
#' in \code{NAMESPACE} does \strong{not} match \code{"\%>\%"}, so \code{export("\%>\%")} is
#' listed separately—do not remove that line from \code{NAMESPACE} unless you switch to
#' full roxygen-generated exports.
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
