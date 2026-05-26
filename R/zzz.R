.onAttach <- function(libname, pkgname) {
  if (!identical(pkgname, "admincleanr")) {
    return(invisible())
  }

  autoload_option <- getOption("admincleanr.autoload_workbench")
  autoload <- if (is.null(autoload_option)) TRUE else isTRUE(autoload_option)

  # Avoid attaching the full tidyverse stack during `R CMD check` on this package
  # (startup cost, dependency ordering, and cleaner example runs).
  checking_self <- identical(
    Sys.getenv("_R_CHECK_PACKAGE_NAME_", unset = ""),
    "admincleanr"
  )

  if (autoload && !checking_self) {
    tryCatch(
      admincleanr_attach_workbench(),
      error = function(err) {
        packageStartupMessage(
          "admincleanr workbench auto-attach skipped: ",
          conditionMessage(err),
          "\nRun admincleanr_attach_workbench() after fixing dependencies, ",
          "or set options(admincleanr.autoload_workbench = FALSE)."
        )
        invisible()
      }
    )
  }

  crunch_option <- getOption("admincleanr.autoload_crunch")
  autoload_crunch <- if (is.null(crunch_option)) {
    interactive()
  } else {
    isTRUE(crunch_option)
  }

  if (autoload_crunch && !checking_self && requireNamespace("admincleanr_crunch", quietly = TRUE)) {
    tryCatch(
      admincleanr_attach_crunch(),
      error = function(err) {
        packageStartupMessage(
          "admincleanr_crunch auto-attach skipped: ",
          conditionMessage(err)
        )
        invisible()
      }
    )
  }

  invisible()
}
