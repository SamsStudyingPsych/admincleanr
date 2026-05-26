.default_parse_orders <- function() {
  c(
    "Ymd HMS", "Ymd HM", "Ymd",
    "mdy HMS", "mdy HM", "mdy",
    "dmy HMS", "dmy HM", "dmy",
    "ymd HMS", "ymd HM", "ymd"
  )
}

#' Coerce to Date/POSIXct by trying several parse orders (heuristic)
#'
#' Samples non-missing values (up to `sample_size` rows), evaluates each candidate
#' `orders` string with [lubridate::parse_date_time()], and keeps the order that
#' yields the fewest failed parses on that sample. The winning order is then
#' applied to the full vector.
#'
#' Numeric vectors in a range typical of Excel serial days are coerced via an
#' origin of `1899-12-30` when `excel_serial = TRUE`.
#'
#' @section Intended use:
#' Ad hoc exploration and one-off extracts (see package \code{admincleanr_crunch}).
#' Once formats are understood, encode them explicitly (see \code{admincleanr_pipe}
#' roadmap and [lubridate::parse_date_time()] / SQL casting in production pipelines).
#'
#' @section Limitations:
#' \itemize{
#'   \item \strong{Ambiguous strings} (for example short year or day/month swaps) may
#'     parse cleanly but still reflect the wrong calendar intent; lowering NA count
#'     does not imply semantic correctness.
#'   \item The \emph{best} order is chosen on a \strong{random sample} of non-empty rows
#'     when there are more than \code{sample_size}; rare formats in the tail of the
#'     file can be mis-ranked.
#'   \item \strong{Ties} on the loss score default to the first matching order in
#'     \code{orders}; extend or reorder \code{orders} if ISO (\code{ymd}-style)
#'     should beat US (\code{mdy}) when scores match.
#'   \item \strong{Time zones}: values are interpreted in \code{tz}; compare policy
#'     with your source system. When the database returns already-typed date/time,
#'     prefer those columns over re-parsing character.
#'   \item \strong{Excel serial} detection uses a heuristic numeric range only; some
#'     non-date numerics could be misclassified.
#'   \item \strong{DST} and fractional-second behavior follow \code{lubridate}; this
#'     function does not validate business-calendar rules (fiscal periods, etc.).
#' }
#'
#' @section Workflow integration:
#' \itemize{
#'   \item **Exploratory** pass on new string-date columns before you lock an explicit \code{parse_date_time} order in a production script (see \pkg{admincleanr_pipe} roadmap).
#'   \item See \link[admincleanr]{admincleanr_training} for extract-to-report sequencing with the main package.
#' }
#'
#' @param x Vector of input values (`character`, `Date`, `POSIXt`, or numeric for Excel).
#' @param orders Character vector of `parse_date_time` order strings; defaults to a
#'   compact US/EU/ISO-oriented menu.
#' @param tz Time zone for parsed datetimes.
#' @param sample_size Maximum number of non-empty values to use when scoring orders.
#' @param result Return `Date`, `POSIXct`, or `auto` (date if all times are midnight).
#' @param excel_serial If `TRUE`, attempt Excel serial conversion for numeric `x`.
#' @param quiet If `FALSE`, prints the chosen order and NA rate on non-empty strings.
#' @return `Date` or `POSIXct` vector aligned with `x`.
#' @export
coerce_best_datetime <- function(x,
                                 orders = .default_parse_orders(),
                                 tz = "UTC",
                                 sample_size = 8000L,
                                 result = c("auto", "Date", "POSIXct"),
                                 excel_serial = TRUE,
                                 quiet = TRUE) {
  result <- match.arg(result)

  if (inherits(x, "Date")) {
    return(switch(result,
      Date = x,
      POSIXct = lubridate::as_datetime(x, tz = tz),
      auto = x
    ))
  }
  if (inherits(x, "POSIXt")) {
    px <- lubridate::as_datetime(x, tz = tz)
    if (identical(result, "Date")) {
      return(as.Date(px, tz = tz))
    }
    return(px)
  }

  if (is.numeric(x) && isTRUE(excel_serial)) {
    xn <- as.numeric(x)
    xn <- xn[!is.na(xn)]
    if (length(xn) && all(xn > 20000 & xn < 80000, na.rm = TRUE)) {
      out <- as.Date(as.numeric(x), origin = "1899-12-30")
      if (identical(result, "POSIXct")) {
        return(lubridate::as_datetime(out, tz = tz))
      }
      return(out)
    }
  }

  xc <- trimws(as.character(x))
  nonempty <- nzchar(xc) & !is.na(xc)
  if (!any(nonempty)) {
    return(rep_len(as.POSIXct(NA, tz = tz), length(x)))
  }

  idx <- which(nonempty)
  if (length(idx) > sample_size) {
    idx <- sample(idx, sample_size)
  }

  best_order <- orders[[1]]
  best_loss <- Inf
  xsub <- xc[idx]

  for (ord in orders) {
    parsed <- suppressWarnings(
      lubridate::parse_date_time(xsub, orders = ord, tz = tz, quiet = TRUE)
    )
    loss <- sum(is.na(parsed))
    if (loss < best_loss) {
      best_loss <- loss
      best_order <- ord
    }
  }

  full <- suppressWarnings(
    lubridate::parse_date_time(xc, orders = best_order, tz = tz, quiet = TRUE)
  )

  if (!quiet) {
    ne_total <- sum(nonempty)
    na_total <- sum(is.na(full) & nonempty)
    message(
      "coerce_best_datetime: chosen order = ", encodeString(best_order, quote = "\""),
      " | NA on non-empty = ", na_total, "/", ne_total
    )
  }

  if (identical(result, "POSIXct")) {
    return(lubridate::as_datetime(full, tz = tz))
  }
  if (identical(result, "Date")) {
    return(as.Date(full, tz = tz))
  }

  if (all(is.na(full))) {
    return(rep_len(as.Date(NA), length(x)))
  }

  lt <- as.POSIXlt(full, tz = tz)
  has_time <- !is.na(full) & ((lt$hour + lt$min + lt$sec) > 0)
  if (any(has_time, na.rm = TRUE)) {
    return(lubridate::as_datetime(full, tz = tz))
  }
  as.Date(full, tz = tz)
}


#' Apply [coerce_best_datetime()] to selected columns
#'
#' Applies the same heuristic independently to each listed column—formats may
#' differ column to column but each column is scored in isolation (no joint model).
#'
#' @inheritSection coerce_best_datetime Limitations
#'
#' @section Workflow integration:
#' \itemize{
#'   \item **Batch exploration** on several mystery string-date columns in one call before promoting per-column parsers into a validated pipeline.
#'   \item See \link[admincleanr]{admincleanr_training} for when to stop using heuristics and fix formats explicitly.
#' }
#'
#' @param data A `data.frame`.
#' @param cols Character vector of column names.
#' @param ... Arguments passed to [coerce_best_datetime()].
#' @return `data` with selected columns coerced.
#' @export
coerce_best_datetime_cols <- function(data, cols, ...) {
  if (!is.data.frame(data)) {
    stop("data must be a data.frame.", call. = FALSE)
  }
  miss <- setdiff(cols, names(data))
  if (length(miss)) {
    stop("Unknown columns: ", paste(miss, collapse = ", "), call. = FALSE)
  }
  for (nm in cols) {
    data[[nm]] <- coerce_best_datetime(data[[nm]], ...)
  }
  data
}
