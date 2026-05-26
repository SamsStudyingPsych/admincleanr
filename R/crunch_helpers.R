#' Coerce values to Date/POSIXct by trying several parse orders
#'
#' Samples non-missing values, evaluates candidate `orders` strings with
#' `lubridate::parse_date_time()`, and applies the order with the fewest failed
#' parses to the full vector. Numeric vectors in a range typical of Excel serial
#' days are coerced through the Excel date origin when `excel_serial = TRUE`.
#'
#' This helper is intended for exploratory work when a source date format is not
#' yet known. Once the format is understood, prefer an explicit parser in
#' production code.
#'
#' @param x Vector of input values (`character`, `Date`, `POSIXt`, or numeric
#'   for Excel serial dates).
#' @param orders Character vector of `parse_date_time` order strings.
#' @param tz Time zone for parsed datetimes.
#' @param sample_size Maximum number of non-empty values to score.
#' @param result Return `Date`, `POSIXct`, or `auto`.
#' @param excel_serial If `TRUE`, attempt Excel serial conversion for numeric
#'   input.
#' @param quiet If `FALSE`, print the chosen order and NA rate.
#' @return A `Date` or `POSIXct` vector aligned with `x`.
#' @export
#' @examples
#' \dontrun{
#' library(admincleanr)
#' coerce_best_datetime(c("2024-01-02", "2024-01-03"), quiet = FALSE)
#' }
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


#' Apply coerce_best_datetime() to selected columns
#'
#' Applies the same heuristic independently to each listed column. Formats may
#' differ column to column, but each column is scored in isolation.
#'
#' @param data A data.frame.
#' @param cols Character vector of column names.
#' @param ... Arguments passed to [coerce_best_datetime()].
#' @return `data` with selected columns coerced.
#' @export
#' @examples
#' \dontrun{
#' library(admincleanr)
#' coerce_best_datetime_cols(df, c("start_date", "end_date"))
#' }
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


#' Pairwise overlap of distinct values between columns of two tables
#'
#' Builds a similarity score (Jaccard index on distinct value sets) for every
#' pair of columns listed from `left` and `right`. Use it to rank plausible
#' identifier or code columns when joining unfamiliar extracts.
#'
#' @param left,right Data frames.
#' @param left_cols Column names in `left` to evaluate.
#' @param right_cols Column names in `right` to evaluate.
#' @param max_distinct Maximum distinct values retained per column before
#'   comparison.
#' @param seed Optional RNG seed so sampling is reproducible when sets are large.
#' @return A data.frame sorted by descending `jaccard`.
#' @export
#' @examples
#' \dontrun{
#' library(admincleanr)
#' pairwise_column_overlap(left, right)
#' }
pairwise_column_overlap <- function(left,
                                    right,
                                    left_cols = names(left),
                                    right_cols = names(right),
                                    max_distinct = 5000L,
                                    seed = NULL) {
  if (!is.data.frame(left) || !is.data.frame(right)) {
    stop("left and right must be data.frames.", call. = FALSE)
  }
  miss_l <- setdiff(left_cols, names(left))
  miss_r <- setdiff(right_cols, names(right))
  if (length(miss_l) || length(miss_r)) {
    stop("Unknown column names.", call. = FALSE)
  }

  combos <- expand.grid(
    left_col = left_cols,
    right_col = right_cols,
    stringsAsFactors = FALSE
  )

  out <- lapply(seq_len(nrow(combos)), function(i) {
    lc <- combos$left_col[i]
    rc <- combos$right_col[i]
    a <- .sample_unique_char(left[[lc]], max_distinct, seed)
    b <- .sample_unique_char(right[[rc]], max_distinct, seed)
    inter <- length(intersect(a, b))
    uni <- length(union(a, b))
    jac <- if (uni == 0L) NA_real_ else inter / uni
    data.frame(
      left_col = lc,
      right_col = rc,
      jaccard = jac,
      n_left = length(a),
      n_right = length(b),
      n_intersect = inter,
      n_union = uni,
      stringsAsFactors = FALSE
    )
  })

  df <- do.call(rbind, out)
  df <- df[order(df$jaccard, decreasing = TRUE, na.last = TRUE), ]
  rownames(df) <- NULL
  df
}


.default_parse_orders <- function() {
  c(
    "Ymd HMS", "Ymd HM", "Ymd",
    "mdy HMS", "mdy HM", "mdy",
    "dmy HMS", "dmy HM", "dmy",
    "ymd HMS", "ymd HM", "ymd"
  )
}


.sample_unique_char <- function(v, max_distinct, seed) {
  v <- unique(as.character(v[!is.na(v)]))
  if (length(v) > max_distinct) {
    if (!is.null(seed)) {
      set.seed(seed)
    }
    v <- sample(v, max_distinct)
  }
  v
}
