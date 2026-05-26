.onAttach <- function(libname, pkgname) {
  if (!identical(pkgname, "admincleanr")) {
    return(invisible())
  }
  autoload <- getOption("admincleanr.autoload_workbench", interactive())
  if (isTRUE(autoload) && interactive()) {
    try(
      admincleanr_attach_workbench(
        attach_companions = getOption("admincleanr.autoload_companions", interactive()),
        warn_missing_companions = interactive()
      ),
      silent = TRUE
    )
  }
  invisible()
}
