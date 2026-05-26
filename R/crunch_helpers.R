.admincleanr_default_parse_orders <- function() {
  c(
    "Ymd HMS", "Ymd HM", "Ymd",
    "mdy HMS", "mdy HM", "mdy",
    "dmy HMS", "dmy HM", "dmy",
    "ymd HMS", "ymd HM", "ymd"
  )
}


#' Coerce to Date/POSIXct by trying several parse orders
#'
#' Samples non-missing values, evaluates candidate `orders` with
#' [lubridate::parse_date_time()], and keeps the order that yields the fewest
#' failed parses on that sample. The winning order is then applied to the full
#' vector.
#'
#' Numeric vectors in a range typical of Excel serial days are coerced via an
#' origin of `1899-12-30` when `excel_serial = TRUE`.
#'
#' @section Intended use:
#' Ad hoc exploration and one-off extracts. Once formats are understood, encode
#' them explicitly with a fixed parser in production scripts.
#'
#' @section Limitations:
#' \itemize{
#'   \item Ambiguous strings can parse cleanly while still reflecting the wrong
#'     calendar intent.
#'   \item When there are more than `sample_size` non-empty rows, the best order
#'     is selected from a random sample.
#'   \item Ties on the loss score default to the first matching order in
#'     `orders`.
#'   \item Time zones follow `lubridate`; compare `tz` with source-system
#'     policy.
#' }
#'
#' @param x Vector of input values (`character`, `Date`, `POSIXt`, or numeric for
#'   Excel serial dates).
#' @param orders Character vector of `parse_date_time` order strings.
#' @param tz Time zone for parsed datetimes.
#' @param sample_size Maximum number of non-empty values to use when scoring
#'   orders.
#' @param result Return `Date`, `POSIXct`, or `auto` (date if all times are
#'   midnight).
#' @param excel_serial If `TRUE`, attempt Excel serial conversion for numeric
#'   `x`.
#' @param quiet If `FALSE`, prints the chosen order and NA rate on non-empty
#'   strings.
#' @return `Date` or `POSIXct` vector aligned with `x`.
#' @export
coerce_best_datetime <- function(x,
                                 orders = .admincleanr_default_parse_orders(),
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
#' Applies the same heuristic independently to each listed column. Formats may
#' differ column to column, but each column is scored in isolation.
#'
#' @inheritSection coerce_best_datetime Limitations
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


.admincleanr_sample_unique_char <- function(v, max_distinct, seed) {
  v <- unique(as.character(v[!is.na(v)]))
  if (length(v) > max_distinct) {
    if (!is.null(seed)) {
      set.seed(seed)
    }
    v <- sample(v, max_distinct)
  }
  v
}


#' Pairwise overlap of distinct values between columns of two tables
#'
#' Builds a Jaccard-style similarity score for every pair of columns listed from
#' `left` and `right`. Use it to rank plausible identifier or code columns when
#' joining unfamiliar extracts.
#'
#' @section Limitations:
#' \itemize{
#'   \item High overlap can reflect chance, shared status codes, or linkage that
#'     is not appropriate for merges.
#'   \item Values are compared as character strings after `as.character()`.
#'   \item When distinct counts exceed `max_distinct`, values are subsampled
#'     independently per column.
#' }
#'
#' @param left,right Data frames.
#' @param left_cols Column names in `left` to evaluate.
#' @param right_cols Column names in `right` to evaluate.
#' @param max_distinct Maximum distinct values retained per column before
#'   comparison.
#' @param seed Optional RNG seed so sampling is reproducible when sets are large.
#' @return A `data.frame` sorted by descending `jaccard`.
#' @export
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
    a <- .admincleanr_sample_unique_char(left[[lc]], max_distinct, seed)
    b <- .admincleanr_sample_unique_char(right[[rc]], max_distinct, seed)
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
