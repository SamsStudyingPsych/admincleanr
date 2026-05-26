.onAttach <- function(libname, pkgname) {
  if (!identical(pkgname, "admincleanr")) {
    return(invisible())
  }
  autoload_option <- getOption("admincleanr.autoload_workbench")
  autoload <- if (is.null(autoload_option)) interactive() else isTRUE(autoload_option)

  if (autoload) {
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
  invisible()
}
