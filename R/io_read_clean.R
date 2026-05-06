#' Read parquet and report last modified time
#'
#' Useful when pulling extracts from databases or scripts and you want quick
#' provenance checks before merging.
#'
#' @section Limitations:
#' \itemize{
#'   \item \verb{mtime} is filesystem metadata—\strong{content} equality or lineage is not
#'     verified (same path could be overwritten).
#'   \item Coerces Arrow tables with \code{as.data.frame()}, which may materialize
#'     columns differently than Arrow-native workflows (types, timestamps).
#' }
#'
#' @param filepath Path to a `.parquet` file.
#' @param ... Passed to [`arrow::read_parquet()`].
#' @return A `data.frame`. Arrow tables are coerced with `as.data.frame()`.
#' @export
#' @examples
#' \dontrun{
#' att <- read_parquet_with_date("att_raw.parquet")
#' }
read_parquet_with_date <- function(filepath, ...) {
  if (!length(filepath) || !nzchar(filepath)) {
    stop("filepath must be a non-empty character string.")
  }
  if (!file.exists(filepath)) {
    stop("The file path does not exist; check spelling and working directory: ", filepath)
  }
  mod_time <- file.info(filepath)$mtime
  message(sprintf(
    "File '%s' was last modified on: %s",
    basename(filepath),
    format(mod_time, "%Y-%m-%d %H:%M:%S")
  ))
  df <- arrow::read_parquet(filepath, ...)
  if (inherits(df, "ArrowTabular") || inherits(df, "Table")) {
    df <- as.data.frame(df)
  }
  df
}


#' Detect file type and read tabular data
#'
#' Paths are routed by lowercase extension only:
#' `.parquet` ([`arrow::read_parquet()`]), `.csv` / `.tsv` / `.txt` ([`data.table::fread()`]),
#' `.xlsx` / `.xls` ([`readxl::read_excel()`]), `.rds` ([`readRDS()`]).
#'
#' @section Limitations:
#' \itemize{
#'   \item Extension detection is naive (no magic-byte sniffing); misnamed files route
#'     to the wrong reader.
#'   \item \verb{...} is passed through to the backing reader per type; invalid
#'     combinations fail there. Arguments for \verb{.rds} are ignored with a warning.
#'   \item Delimited text uses \code{data.table::fread} heuristics—wide or messy
#'     extracts may need explicit \code{sep}, \code{quote}, or column classes in
#'     \verb{...}.
#' }
#'
#' @param path File path.
#' @param ... Additional arguments passed to the reader (e.g. `sheet`, `sep`, `skip`).
#' @return A `data.frame`.
#' @export
read_data_file <- function(path, ...) {
  if (!is.character(path) || length(path) != 1L || !nzchar(path)) {
    stop("path must be a single non-empty string.")
  }
  if (!file.exists(path)) {
    stop("File does not exist: ", path)
  }
  ext <- tolower(tools::file_ext(path))
  switch(ext,
    "parquet" = {
      df <- arrow::read_parquet(path, ...)
      if (inherits(df, "ArrowTabular") || inherits(df, "Table")) df <- as.data.frame(df)
      df
    },
    "csv" = ,
    "tsv" = ,
    "txt" = data.table::fread(path, ..., data.table = FALSE),
    "xlsx" = ,
    "xls" = readxl::read_excel(path, ...),
    "rds" = {
      dots <- list(...)
      if (length(dots)) {
        warning("... arguments are ignored for .rds files.")
      }
      readRDS(path)
    },
    stop("Unsupported extension '.", ext, "' for path: ", path)
  )
}


#' Snake_case names and trim all character columns
#'
#' Applies [`janitor::clean_names()`] then trims whitespace on every character
#' column (`base::trimws`, which handles Unicode spaces reasonably well).
#'
#' @section Limitations:
#' \itemize{
#'   \item \code{clean_names()} may rename duplicated or empty headers; review
#'     column mapping on new extracts.
#'   \item \code{trimws} does not normalize encoding, zero-width characters, or
#'     homoglyphs—use additional string hygiene if those appear in your feeds.
#' }
#'
#' @param df A `data.frame` or tibble.
#' @param ... Passed to [`janitor::clean_names()`].
#' @return A cleaned `data.frame`.
#' @export
#' @importFrom dplyr mutate across
#' @examples
#' \dontrun{
#' clients_raw %>%
#'   clean_names_trim_ws() %>%
#'   squish_character_columns()
#' }
clean_names_trim_ws <- function(df, ...) {
  if (!is.data.frame(df)) {
    stop("df must be a data.frame.")
  }
  out <- janitor::clean_names(df, ...)
  out <- dplyr::mutate(out, dplyr::across(dplyr::where(is.character), trimws))
  out
}


#' Collapse embedded newlines and squish whitespace in character columns
#'
#' Matches the pattern often needed after [`DBI::dbGetQuery()`] on text fields:
#' normalize `\r`/`\n` to a single space, then [`stringr::str_squish()`].
#'
#' @section Limitations:
#' \itemize{
#'   \item Destroys \strong{meaningful} embedded newlines (e.g. free-text notes);
#'     do not apply wholesale if newlines carry semantics.
#'   \item Runs on all character columns when used as written; narrow with
#'     \code{dplyr::mutate} if only some fields need treatment.
#' }
#'
#' @param df A `data.frame`.
#' @param collapse_newlines Logical. Replace runs of `\r`/`\n` with a single space.
#' @return `df` with character columns normalized.
#' @export
#' @importFrom dplyr mutate across
squish_character_columns <- function(df, collapse_newlines = TRUE) {
  if (!is.data.frame(df)) {
    stop("df must be a data.frame.")
  }
  dplyr::mutate(
    df,
    dplyr::across(dplyr::where(is.character), function(x) {
      if (isTRUE(collapse_newlines)) {
        x <- gsub("[\r\n]+", " ", x, perl = TRUE)
      }
      stringr::str_squish(x)
    })
  )
}


#' Parse `"h:mm AM/PM"` times to minutes since midnight
#'
#' @section Limitations:
#' \itemize{
#'   \item Only \strong{12-hour clock with AM/PM} and \code{strptime}'s
#'     \code{\%I:\%M \%p}; 24-hour strings, seconds, and fractional minutes return
#'     missing values unless you preprocess.
#'   \item Parsing uses a fixed \verb{UTC} \code{strptime} skeleton—no daylight-saving
#'     nuance (values are clock minutes, not anchored datetimes).
#' }
#'
#' @param time_str Character vector (e.g. `"1:30 PM"`).
#' @return Numeric vector of minutes; `NA` where parsing fails.
#' @export
parse_time_to_mins <- function(time_str) {
  if (!is.character(time_str)) time_str <- as.character(time_str)
  parsed <- as.POSIXlt(strptime(time_str, format = "%I:%M %p", tz = "UTC"))
  as.numeric(parsed$hour * 60L + parsed$min)
}


#' Minutes from Monday 00:00 to POSIX timestamp position in week
#'
#' Week starts Monday (\code{lubridate::wday(..., week_start = 1)}).
#'
#' @section Limitations:
#' \itemize{
#'   \item Depends on \code{lubridate::as_datetime()} coercion; malformed or
#'     non-POSIX-aware character input may fail or misinterpret time zone.
#'   \item Minute offset is a \strong{positional} measure within a nominal week, not
#'     a substitute for calendar-period logic (fiscal weeks, holidays).
#' }
#'
#' @param ts POSIXct or POSIXlt vector.
#' @return Numeric minutes from start of ISO-style week (Monday midnight).
#' @export
#' @importFrom lubridate as_datetime wday hour minute
ts_to_weekly_mins <- function(ts) {
  ts <- lubridate::as_datetime(ts)
  days_in <- lubridate::wday(ts, week_start = 1) - 1L
  days_in * 24 * 60 + lubridate::hour(ts) * 60 + lubridate::minute(ts)
}
