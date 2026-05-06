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


#' Pairwise overlap of distinct values between columns of two tables
#'
#' Builds a **similarity score** (Jaccard index on distinct value sets) for every
#' pair of columns you list from `left` and `right`. Use it to **rank** plausible
#' identifier or code columns when joining unfamiliar extracts. It is only a
#' structural hint—validate keys out-of-band.
#'
#' @param left,right Data frames.
#' @param left_cols Column names in `left` to evaluate.
#' @param right_cols Column names in `right` to evaluate.
#' @param max_distinct Maximum distinct values retained per column before comparison.
#' @param seed Optional RNG seed so sampling is reproducible when sets are large.
#' @return A `data.frame` sorted by descending `jaccard` with columns
#'   `left_col`, `right_col`, `jaccard`, `n_left`, `n_right`, `n_intersect`, `n_union`.
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
