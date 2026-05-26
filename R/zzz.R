.onAttach <- function(libname, pkgname) {
  if (!identical(pkgname, "admincleanr")) {
    return(invisible())
  }
  autoload <- getOption("admincleanr.autoload_workbench", interactive())
  if (isTRUE(autoload) && interactive()) {
    try(
      admincleanr_attach_workbench(),
      silent = TRUE
    )
  }
  if (interactive()) {
    packageStartupMessage(
      "admincleanr exports are attached; call helpers directly after library(admincleanr), e.g. clean_names_trim_ws(df)."
    )
  }
  invisible()
}
