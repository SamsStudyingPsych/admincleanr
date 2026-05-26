# Keep the main package installable without a hard dependency on the sibling
# heuristic package while still exposing its entry points after library(admincleanr).
.admincleanr_crunch_export <- function(name) {
  if (!requireNamespace("admincleanr_crunch", quietly = TRUE)) {
    stop(
      "Install admincleanr_crunch from the same repository to use ",
      name,
      "() without the package prefix.\n",
      "Example: pak::pak(\"SamsStudyingPsych/admincleanr\", subdir = \"admincleanr_crunch\")",
      call. = FALSE
    )
  }

  getExportedValue("admincleanr_crunch", name)
}

coerce_best_datetime <- function(x,
                                 orders = c(
                                   "Ymd HMS", "Ymd HM", "Ymd",
                                   "mdy HMS", "mdy HM", "mdy",
                                   "dmy HMS", "dmy HM", "dmy",
                                   "ymd HMS", "ymd HM", "ymd"
                                 ),
                                 tz = "UTC",
                                 sample_size = 8000L,
                                 result = c("auto", "Date", "POSIXct"),
                                 excel_serial = TRUE,
                                 quiet = TRUE) {
  .admincleanr_crunch_export("coerce_best_datetime")(
    x = x,
    orders = orders,
    tz = tz,
    sample_size = sample_size,
    result = result,
    excel_serial = excel_serial,
    quiet = quiet
  )
}

coerce_best_datetime_cols <- function(data, cols, ...) {
  .admincleanr_crunch_export("coerce_best_datetime_cols")(
    data = data,
    cols = cols,
    ...
  )
}

pairwise_column_overlap <- function(left,
                                    right,
                                    left_cols = names(left),
                                    right_cols = names(right),
                                    max_distinct = 5000L,
                                    seed = NULL) {
  .admincleanr_crunch_export("pairwise_column_overlap")(
    left = left,
    right = right,
    left_cols = left_cols,
    right_cols = right_cols,
    max_distinct = max_distinct,
    seed = seed
  )
}
