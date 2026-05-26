#' Normalize person-style full names for deterministic matching
#'
#' Applies a single-pass, vectorized transform that is faster than chaining
#' multiple \pkg{stringr} steps in \code{mutate()} for large columns. Intended
#' for **blocking keys** and overlap flags, not display names.
#'
#' @param x Character vector (other types are coerced with \code{as.character()}).
#' @param remove_whitespace If \code{TRUE} (default), remove all whitespace after
#'   lower-casing. If \code{FALSE}, keep internal spaces and strip only characters
#'   outside `[a-z0-9 ]` (after lower-casing).
#' @return Character vector the same length as \code{x}; \code{NA} stays \code{NA}.
#' @section Workflow integration:
#' \itemize{
#'   \item Build **one** normalized lookup vector from your reference table, then
#'     use \code{\%in\%} or \code{\link{name_in_lookup}} instead of repeating
#'     \code{(x \%in\% a | x \%in\% b)} on wide tables.
#'   \item For very large extracts, prefer \code{\link{build_name_lookup}} once
#'     per session rather than re-deriving reference keys inside a grouped pipeline.
#' }
#' @export
#' @examples
#' normalize_full_name(c("O'Brien,  Ann", NA))
normalize_full_name <- function(x, remove_whitespace = TRUE) {
  x <- as.character(x)
  if (!length(x)) {
    return(x)
  }
  out <- tolower(x)
  if (isTRUE(remove_whitespace)) {
    out <- gsub("[[:space:]]+", "", out, perl = TRUE)
    out <- gsub("[^a-z0-9]", "", out, perl = TRUE)
  } else {
    out <- gsub("[^a-z0-9 ]", "", out, perl = TRUE)
  }
  out[is.na(x)] <- NA_character_
  out
}


#' Build a unique normalized name lookup from several columns
#'
#' @param ... Unnamed character vectors (typically columns from a reference
#'   \code{data.frame}), passed to \code{\link{normalize_full_name}}.
#' @param remove_whitespace Passed to \code{\link{normalize_full_name}}.
#' @return Sorted unique non-missing normalized names (character vector).
#' @export
#' @examples
#' build_name_lookup(c("Ann A", "ann a"), c("Bob  B", NA))
build_name_lookup <- function(..., remove_whitespace = TRUE) {
  parts <- list(...)
  if (!length(parts)) {
    return(character())
  }
  flat <- unlist(parts, use.names = FALSE)
  flat <- normalize_full_name(flat, remove_whitespace = remove_whitespace)
  flat <- flat[!is.na(flat) & nzchar(flat)]
  sort(unique(flat))
}


#' Flag whether normalized names appear in a pre-built lookup
#'
#' Uses \pkg{data.table}'s \code{chmatch} for membership checks (often faster than
#' repeated \code{\%in\%} with duplicated reference categories on long vectors).
#'
#' @param x Character vector of raw names (same semantics as \code{\link{normalize_full_name}}).
#' @param lookup Character vector of **normalized** reference names, e.g. from
#'   \code{\link{build_name_lookup}}.
#' @param remove_whitespace Passed to \code{\link{normalize_full_name}}.
#' @return Integer \code{0/1} vector parallel to \code{x}; \code{NA} when \code{x} is \code{NA}.
#' @export
#' @examples
#' ref <- build_name_lookup(c("Ann A"), c("Bob B"))
#' name_in_lookup(c("ann a", "zzz", NA), ref)
name_in_lookup <- function(x, lookup, remove_whitespace = TRUE) {
  nx <- normalize_full_name(x, remove_whitespace = remove_whitespace)
  if (!length(lookup)) {
    out <- rep.int(0L, length(nx))
    out[is.na(nx)] <- NA_integer_
    return(out)
  }
  m <- chmatch(nx, lookup, nomatch = NA_integer_)
  out <- as.integer(!is.na(m))
  out[is.na(nx)] <- NA_integer_
  out
}
