#' Open package training notes in your browser
#'
#' Opens the GitHub-rendered copy of `docs/TRAINING.md` for this package. To use a
#' fork or mirror, set `options(admincleanr.training_url = "<full URL>")` before
#' calling.
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
