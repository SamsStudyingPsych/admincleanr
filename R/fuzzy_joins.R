#' Left join rows by approximate key match using string distance
#'
#' Wraps [`fuzzyjoin::stringdist_left_join()`] so keys that do not match exactly can
#' still align within a tolerable [`stringdist`] distance (e.g. typos).
#'
#' @details
#' Install suggested packages: `install.packages(c("fuzzyjoin", "stringdist"))`.
#'
#' @section Limitations:
#' \itemize{
#'   \item Can return \strong{incorrect} row pairings when distances are small by
#'     chance; always \strong{block} candidates in SQL first (date windows, program,
#'     geography) before fuzzy joining large tables.
#'   \item \strong{max_dist} is a behavior dial, not a correctness guarantee—tighten
#'     it and inspect unmatched / multi-match counts.
#'   \item **Performance:** cost grows with table sizes and key cardinality; very
#'     loose `max_dist` on wide extracts can be slow or memory-heavy.
#'   \item Multiple matches per left row are possible; downstream deduplication logic
#'     is your responsibility.
#' }
#'
#' @param x Left table (`data.frame`).
#' @param y Right table (`data.frame`).
#' @param by Named or unnamed column mapping; passed to [`fuzzyjoin::stringdist_left_join()`].
#' @param ignore_case Logical; forwarded if supported by your fuzzyjoin version.
#' @param method Passed to underlying stringdist (e.g. `"osa"`, `"jw"`).
#' @param max_dist Maximum allowed distance per key (see fuzzyjoin docs).
#' @param ... Extra arguments forwarded to [`fuzzyjoin::stringdist_left_join()`].
#' @return Result of fuzzyjoin join.
#' @export
#' @examples
#' \dontrun{
#' # install.packages(c("fuzzyjoin", "stringdist"))
#' fuzzy_left_join_stringdist(names_a, names_b, by = "name_id", max_dist = 2)
#' }
fuzzy_left_join_stringdist <- function(x,
                                       y,
                                       by,
                                       ignore_case = FALSE,
                                       method = "osa",
                                       max_dist = 1,
                                       ...) {
  if (!requireNamespace("fuzzyjoin", quietly = TRUE)) {
    stop("Install suggested package fuzzyjoin.", call. = FALSE)
  }
  if (!requireNamespace("stringdist", quietly = TRUE)) {
    stop("Install suggested package stringdist.", call. = FALSE)
  }

  fuzzyjoin::stringdist_left_join(
    x = x,
    y = y,
    by = by,
    ignore_case = ignore_case,
    method = method,
    max_dist = max_dist,
    ...
  )
}
