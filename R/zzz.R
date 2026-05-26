.admincleanr_default_attach_packages <- function() {
  c(
    "dplyr",
    "tidyr",
    "purrr",
    "tibble",
    "stringr",
    "lubridate",
    "readxl",
    "openxlsx",
    "janitor",
    "DBI",
    "odbc",
    "arrow",
    "data.table",
    "ggplot2"
  )
}

.admincleanr_attach_packages <- function(packages) {
  for (pkg in unique(packages)) {
    if (!is.character(pkg) || length(pkg) != 1L || identical(pkg, "admincleanr")) {
      next
    }

    search_name <- paste0("package:", pkg)
    if (search_name %in% search()) {
      next
    }

    if (!requireNamespace(pkg, quietly = TRUE)) {
      next
    }

    suppressPackageStartupMessages(
      try(
        require(pkg, character.only = TRUE, quietly = TRUE, warn.conflicts = FALSE),
        silent = TRUE
      )
    )
  }

  invisible()
}

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

  attach_setting <- getOption(
    "admincleanr.attach_packages",
    .admincleanr_default_attach_packages()
  )
  if (isTRUE(attach_setting)) {
    attach_setting <- .admincleanr_default_attach_packages()
  }

  if (isFALSE(attach_setting)) {
    return(invisible())
  }

  if (!is.character(attach_setting)) {
    packageStartupMessage(
      "admincleanr: option 'admincleanr.attach_packages' must be TRUE, FALSE, or a character vector."
    )
    return(invisible())
  }

  .admincleanr_attach_packages(attach_setting)
  invisible()
}
