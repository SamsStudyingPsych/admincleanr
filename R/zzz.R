.onAttach <- function(libname, pkgname) {
  if (!identical(pkgname, "admincleanr")) {
    return(invisible())
  }
  autoload <- getOption("admincleanr.autoload_workbench", TRUE)
  # Avoid attaching the full tidyverse stack during `R CMD check` on this package
  # (startup cost, dependency ordering, and cleaner example runs).
  checking_self <- identical(
    Sys.getenv("_R_CHECK_PACKAGE_NAME_", unset = ""),
    "admincleanr"
  )
  if (isTRUE(autoload) && !checking_self) {
    try(
      admincleanr_attach_workbench(),
      silent = TRUE
    )
  }
  invisible()
}
