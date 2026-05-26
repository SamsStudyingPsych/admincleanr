.admincleanr_attach_package <- function(pkg) {
  search_name <- paste0("package:", pkg)
  if (search_name %in% search()) {
    return(TRUE)
  }

  if (!requireNamespace(pkg, quietly = TRUE)) {
    return(FALSE)
  }

  suppressPackageStartupMessages(
    require(pkg, character.only = TRUE, quietly = TRUE, warn.conflicts = FALSE)
  )
}

.admincleanr_attach_companions <- function() {
  companions <- c("admincleanr_crunch", "admincleanr_pipe")
  invisible(vapply(companions, .admincleanr_attach_package, logical(1)))
}

.onAttach <- function(libname, pkgname) {
  if (!identical(pkgname, "admincleanr")) {
    return(invisible())
  }

  autoload_companions <- getOption("admincleanr.autoload_companions", TRUE)
  if (isTRUE(autoload_companions)) {
    try(
      .admincleanr_attach_companions(),
      silent = TRUE
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
