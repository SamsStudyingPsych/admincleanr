#' Open package training notes in the browser or in your IDE
#'
#' Training content lives in \verb{docs/TRAINING.md} on GitHub and is mirrored at
#' install time as \verb{inst/doc/TRAINING.md} so it ships with the package.
#'
#' @param where \code{"browser"} (default) opens the GitHub-rendered page via
#'   \code{\link[utils]{browseURL}}. \code{"local"} opens the installed copy: in
#'   RStudio / Positron, \code{rstudioapi::navigateToFile()} when available; otherwise
#'   \code{utils::file.edit()} or \code{file.show()} as a fallback.
#'
#' @section Limitations:
#' \itemize{
#'   \item \strong{Browser mode} needs network access and a default browser; set
#'     \code{options(admincleanr.training_url = "<URL>")} for forks or private mirrors.
#'   \item \strong{Local mode} requires a proper \code{install.packages} /
#'     \code{install_github} install so \code{system.file()} can find \verb{inst/doc/};
#'     \code{devtools::load_all()} may not surface \verb{inst/} the same way—use
#'     browser mode or open \verb{docs/TRAINING.md} from the source tree manually.
#'   \item Opening a browser does \strong{not} authenticate you to GitHub.
#' }
#'
#' @section Workflow integration:
#' Call once per session or when onboarding collaborators: the training page ties
#' together SQL handoff, cleaning helpers, linkage heuristics, and pipeline helpers.
#' Keep it open while you sketch an analysis script so function choices stay
#' consistent with the documented pipeline.
#'
#' @return Invisibly, the URL (browser) or filesystem path (local).
#' @export
#' @examples
#' \dontrun{
#' admincleanr_training()
#' admincleanr_training("local")
#' }
admincleanr_training <- function(where = c("browser", "local")) {
  where <- match.arg(where)

  if (identical(where, "local")) {
    path <- system.file("doc", "TRAINING.md", package = "admincleanr", mustWork = FALSE)
    if (!nzchar(path) || !file.exists(path)) {
      warning(
        "Bundled TRAINING.md not found. Reinstall from GitHub or use where = 'browser'.",
        call. = FALSE
      )
      return(invisible(""))
    }
    path <- normalizePath(path, winslash = "/", mustWork = TRUE)
    if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
      rstudioapi::navigateToFile(path)
    } else {
      tryCatch(
        utils::file.edit(path, title = "admincleanr training"),
        error = function(e) utils::file.show(path, title = "admincleanr training")
      )
    }
    return(invisible(path))
  }

  url <- getOption(
    "admincleanr.training_url",
    default = "https://github.com/SamsStudyingPsych/admincleanr/blob/master/docs/TRAINING.md"
  )
  utils::browseURL(url)
  invisible(url)
}
