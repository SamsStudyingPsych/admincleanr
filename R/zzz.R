.onAttach <- function(libname, pkgname) {
  if (!identical(pkgname, "admincleanr")) {
    return(invisible())
  }
  autoload <- getOption("admincleanr.autoload_workbench", TRUE)
  workbench_attached <- FALSE

  if (isTRUE(autoload)) {
    workbench_result <- try(
      admincleanr_attach_workbench(),
      silent = TRUE
    )
    workbench_attached <- !inherits(workbench_result, "try-error")
  }

  if (isTRUE(autoload) && isTRUE(workbench_attached)) {
    packageStartupMessage(
      "admincleanr attached: exported helpers are available without ",
      "`admincleanr::`, and the usual workbench packages were attached too. ",
      "Set options(admincleanr.autoload_workbench = FALSE) before ",
      "library(admincleanr) to skip that auto-attach step."
    )
  } else if (isTRUE(autoload)) {
    packageStartupMessage(
      "admincleanr attached: exported helpers are available without ",
      "`admincleanr::`. The workbench stack was not auto-attached; run ",
      "admincleanr_attach_workbench() if you want tidyverse/janitor/readxl/DBI/odbc."
    )
  } else {
    packageStartupMessage(
      "admincleanr attached: exported helpers are available without ",
      "`admincleanr::`. Set options(admincleanr.autoload_workbench = TRUE) ",
      "before library(admincleanr) to also auto-attach the usual workbench stack."
    )
  }
  invisible()
}
