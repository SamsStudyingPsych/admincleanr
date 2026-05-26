.onAttach <- function(libname, pkgname) {
  if (!identical(pkgname, "admincleanr")) {
    return(invisible())
  }
  if (interactive()) {
    packageStartupMessage(
      "Exported admincleanr functions are available without `admincleanr::` ",
      "after `library(admincleanr)`."
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
