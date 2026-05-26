.onAttach <- function(libname, pkgname) {
  if (!identical(pkgname, "admincleanr")) {
    return(invisible())
  }

  if (interactive()) {
    packageStartupMessage(
      "admincleanr attached: exported functions are available directly ",
      "after library(admincleanr), e.g. clean_but_keep()."
    )
  }

  autoload <- getOption("admincleanr.autoload_workbench", interactive())
  if (isTRUE(autoload) && interactive()) {
    try(
      admincleanr_attach_workbench(),
      silent = TRUE
    )
  }
  invisible()
}
