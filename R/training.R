#' Open package training notes in your browser
#'
#' Opens the GitHub-rendered copy of `docs/TRAINING.md` for this package. To use a
#' fork or mirror, set `options(admincleanr.training_url = "<full URL>")` before
#' calling.
#'
#' @section Limitations:
#' \itemize{
#'   \item Requires network access and a configured default browser unless your R
#'     session redirects `browseURL()` elsewhere.
#'   \item The resolved URL must be reachable from your machine (firewalls, offline
#'     sessions, or renamed default branches break the default link—set the option).
#'   \item Opening a browser does \strong{not} authenticate you to GitHub; training
#'     text is whatever is publicly visible at that URL when you load it.
#' }
#'
#' @return Invisibly, the URL that was opened.
#' @export
#' @examples
#' \dontrun{
#' admincleanr_training()
#' }
admincleanr_training <- function() {
  url <- getOption(
    "admincleanr.training_url",
    default = "https://github.com/SamsStudyingPsych/admincleanr/blob/master/docs/TRAINING.md"
  )
  utils::browseURL(url)
  invisible(url)
}
