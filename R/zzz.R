.attach_companion_packages <- function() {
  companions <- c("admincleanr_crunch", "admincleanr_pipe")
  install_hints <- c(
    admincleanr_crunch = "pak::pak(\"SamsStudyingPsych/admincleanr\", subdir = \"admincleanr_crunch\")",
    admincleanr_pipe = "pak::pak(\"SamsStudyingPsych/admincleanr\", subdir = \"admincleanr_pipe\")"
  )

  for (pkg in companions) {
    if (paste0("package:", pkg) %in% search()) {
      next
    }

    if (requireNamespace(pkg, quietly = TRUE)) {
      suppressPackageStartupMessages(
        library(pkg, character.only = TRUE)
      )
      next
    }

    packageStartupMessage(
      "Optional companion package '", pkg, "' is not installed. Install with ",
      install_hints[[pkg]], "."
    )
  }
}

.onAttach <- function(libname, pkgname) {
  if (!identical(pkgname, "admincleanr")) {
    return(invisible())
  }
  autoload_companions <- getOption("admincleanr.autoload_companions", TRUE)
  if (isTRUE(autoload_companions)) {
    try(
      .attach_companion_packages(),
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
