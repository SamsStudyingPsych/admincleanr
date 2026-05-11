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
