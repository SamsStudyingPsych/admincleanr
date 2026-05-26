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
#' @section Workflow integration:
#' \itemize{
#'   \item **Parquet ingest with provenance**: confirm you are reading the extract you think before merging—typical after scheduled SQL-to-Parquet jobs.
#'   \item See \code{\link{admincleanr_training}} for staging and \code{\link{read_data_file}} when extension varies.
#' }
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
  df <- read_parquet(filepath, ...)
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
#' @section Workflow integration:
#' \itemize{
#'   \item **Single entry point** when analysts receive mixed file types (Parquet, CSV, xlsx) from the same workflow—reduces branching boilerplate in scripts.
#'   \item See \code{\link{admincleanr_training}} for post-read cleaning (\code{\link{squish_character_columns}}).
#' }
#' @export
read_data_file <- function(path, ...) {
  if (!is.character(path) || length(path) != 1L || !nzchar(path)) {
    stop("path must be a single non-empty string.")
  }
  if (!file.exists(path)) {
    stop("File does not exist: ", path)
  }
  ext <- tolower(file_ext(path))
  switch(ext,
    "parquet" = {
      df <- read_parquet(path, ...)
      if (inherits(df, "ArrowTabular") || inherits(df, "Table")) df <- as.data.frame(df)
      df
    },
    "csv" = ,
    "tsv" = ,
    "txt" = fread(path, ..., data.table = FALSE),
    "xlsx" = ,
    "xls" = read_excel(path, ...),
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
#' @section Workflow integration:
#' \itemize{
#'   \item Run **immediately after** reading messy exports so downstream joins and documentation use stable, machine-safe column names plus trimmed text.
#'   \item See \code{\link{admincleanr_training}} for SQL handoff patterns.
#' }
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
  out <- clean_names(df, ...)
  out <- mutate(out, across(where(is.character), trimws))
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
#' @section Workflow integration:
#' \itemize{
#'   \item Standard **post-SQL** normalization before joins or Parquet writes when text fields contain embedded line breaks.
#'   \item See \code{\link{admincleanr_training}} for ordering with \code{\link{clean_names_trim_ws}}.
#' }
#' @export
#' @importFrom dplyr mutate across
squish_character_columns <- function(df, collapse_newlines = TRUE) {
  if (!is.data.frame(df)) {
    stop("df must be a data.frame.")
  }
  mutate(
    df,
    across(where(is.character), function(x) {
      if (isTRUE(collapse_newlines)) {
        x <- gsub("[\r\n]+", " ", x, perl = TRUE)
      }
      str_squish(x)
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
#' @section Workflow integration:
#' \itemize{
#'   \item Convert **clock-only** survey or operations fields to a numeric axis for stacking with same-day timestamps or shift logic.
#'   \item See \code{\link{admincleanr_training}} and \code{\link{ts_to_weekly_mins}} for combined time-position features.
#' }
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
#' @section Workflow integration:
#' \itemize{
#'   \item **Align timestamps** to a common weekly offset for capacity or scheduling analytics when calendar week boundaries matter.
#'   \item See \code{\link{admincleanr_training}} for datetime strategy (explicit vs heuristic).
#' }
#' @export
#' @importFrom lubridate as_datetime wday hour minute
ts_to_weekly_mins <- function(ts) {
  ts <- as_datetime(ts)
  days_in <- wday(ts, week_start = 1) - 1L
  days_in * 24 * 60 + hour(ts) * 60 + minute(ts)
}
