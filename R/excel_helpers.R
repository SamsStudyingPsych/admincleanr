#' Turn snake_case/dot.case column labels into readable Title Case (Excel-friendly)
#'
#' @section Limitations:
#' Uses \code{tools::toTitleCase()}; acronyms or domain tokens may be split
#' awkwardly—hand-rename sensitive headers if needed.
#'
#' @param obj A data frame or character vector (e.g. column names).
#' @return If `obj` is a data frame, same structure with renamed
#'   columns. If `obj` is a character vector, the transformed strings.
#' @section Workflow integration:
#' \itemize{
#'   \item Prepare **column labels** before stakeholder-facing Excel or memo tables.
#'   \item See \code{\link{admincleanr_training}} and \code{\link{export_formatted_excel}}.
#' }
#' @export
excelify_names <- function(obj) {
  if (is.data.frame(obj)) {
    colnames(obj) <- .excelify_name_vec(colnames(obj))
    return(obj)
  }
  .excelify_name_vec(obj)
}

.excelify_name_vec <- function(v) {
  v <- as.character(v)
  v <- gsub("[_.]", " ", v)
  toTitleCase(v)
}


#' Export a dataframe to formatted single-sheet Excel workbook
#'
#' Headers get bold/light-blue styling and auto-fit width. Saves to a timestamped path
#' derived from `filepath`.
#'
#' @section Limitations:
#' \itemize{
#'   \item Applies styling to the data as given; very wide or long sheets may hit
#'     Excel limits independently of R.
#'   \item Timestamped path is derived from system time; reproducible builds should
#'     record the returned path explicitly downstream.
#' }
#'
#' @param df Data frame.
#' @param filepath Base path for `.xlsx` output (timestamp is inserted before the extension).
#' @param sheet_name Worksheet label.
#' @return Invisibly, the written path (`character(1)`).
#' @section Workflow integration:
#' \itemize{
#'   \item **One-click styled handoff** after an analysis block—timestamped path avoids overwriting prior QA copies.
#'   \item See \code{\link{admincleanr_training}} for multi-sheet variant.
#' }
#' @export
export_formatted_excel <- function(df, filepath, sheet_name = "Data") {
  export_df <- excelify_names(df)

  wb <- createWorkbook()
  addWorksheet(wb, sheet_name)
  writeData(wb, sheet = sheet_name, x = export_df)

  header_style <- createStyle(
    textDecoration = "bold",
    fgFill = "#DCE6F1",
    halign = "center",
    border = "Bottom",
    borderColour = "#000000"
  )

  num_cols <- ncol(export_df)
  addStyle(
    wb,
    sheet = sheet_name,
    style = header_style,
    rows = 1,
    cols = seq_len(num_cols),
    gridExpand = TRUE
  )
  setColWidths(wb, sheet = sheet_name, cols = seq_len(num_cols), widths = "auto")
  addFilter(wb, sheet = sheet_name, row = 1, cols = seq_len(num_cols))

  timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
  base_path <- file_path_sans_ext(filepath)
  ext <- file_ext(filepath)
  if (!nzchar(ext)) ext <- "xlsx"
  final_path <- paste0(base_path, "_", timestamp, ".", ext)

  saveWorkbook(wb, final_path, overwrite = TRUE)
  message("Exported formatted Excel file to ", final_path)
  invisible(final_path)
}


#' Write multiple worksheets with simple professional styling
#'
#' @section Limitations:
#' \itemize{
#'   \item Skips non-dataframe list entries with a warning; does not validate sheet
#'     name length or character rules beyond \code{openxlsx} defaults.
#'   \item Same practical limits as [export_formatted_excel()] regarding workbook size.
#' }
#'
#' @param filepath Base output path ending in `.xlsx` (timestamp is inserted).
#' @param sheet_names Names for each worksheet.
#' @param data_list List of dataframes aligned with `sheet_names`.
#' @return Invisibly, written path (`character(1)`).
#' @section Workflow integration:
#' \itemize{
#'   \item Package **multiple QA tables** (raw vs cleaned vs unmatched keys) for program staff in one workbook with consistent header styling.
#'   \item See \code{\link{admincleanr_training}} for export vs \code{gt} table choice.
#' }
#' @export
save_to_excel_multisheet_formatted <- function(filepath, sheet_names, data_list) {
  if (length(sheet_names) != length(data_list)) {
    stop("The number of sheet names must equal the number of dataframes.")
  }

  wb <- createWorkbook()
  header_style <- createStyle(
    textDecoration = "bold",
    fgFill = "#DCE6F1",
    halign = "center",
    border = "Bottom",
    borderColour = "#000000"
  )

  for (i in seq_along(data_list)) {
    sh <- sheet_names[[i]]
    current_df <- data_list[[i]]
    if (!is.data.frame(current_df)) {
      warning("Item ", i, " is not a dataframe — skipping sheet: ", sh)
      next
    }
    current_df <- excelify_names(current_df)

    addWorksheet(wb, sheetName = sh)
    writeData(wb, sheet = sh, x = current_df)
    num_cols <- ncol(current_df)
    if (!num_cols) next

    addStyle(
      wb,
      sheet = sh,
      style = header_style,
      rows = 1,
      cols = seq_len(num_cols),
      gridExpand = TRUE
    )
    setColWidths(wb, sheet = sh, cols = seq_len(num_cols), widths = "auto")
    addFilter(wb, sheet = sh, row = 1, cols = seq_len(num_cols))
  }

  timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
  base_path <- file_path_sans_ext(filepath)
  ext <- file_ext(filepath)
  if (!nzchar(ext)) ext <- "xlsx"
  final_path <- paste0(base_path, "_", timestamp, ".", ext)

  saveWorkbook(wb, final_path, overwrite = TRUE)
  message("Saved formatted multi-sheet workbook: ", final_path)
  invisible(final_path)
}


#' Bold header row, light-blue fill, and filter on worksheet row 1
#'
#' Applies styles to rows and columns \(1\) through \(max_cols\) for every sheet inside
#' an [`openxlsx`] workbook object created with [`openxlsx::createWorkbook()`] or loaded
#' with [`openxlsx::loadWorkbook()`].
#'
#' @section Limitations:
#' \itemize{
#'   \item Styles a \strong{fixed} column window \code{1:max_cols}; real data wider
#'     than \code{max_cols} will not be dressed or filtered unless you raise the cap.
#'   \item Auto column width for many empty leading columns can still be imprecise—
#'     verify layout in Excel for presentation-critical workbooks.
#' }
#'
#' @param wb [`openxlsx`] Workbook object.
#' @param max_cols Upper bound of columns to dress (covers cases where workbook metadata
#'   does not encode width).
#' @return `wb`, invisibly.
#' @section Workflow integration:
#' \itemize{
#'   \item Apply a **consistent header look** to workbooks you did not create (legacy templates) before circulation.
#'   \item See \code{\link{admincleanr_training}} for Excel vs Parquet staging norms.
#' }
#' @export
format_workbook_headers <- function(wb, max_cols = 200L) {
  if (!inherits(wb, "Workbook")) {
    stop("wb must be an openxlsx Workbook.")
  }

  sheets <- wb$sheet_names
  if (!length(sheets) && length(wb$worksheets)) {
    sheets <- names(wb$worksheets)
  }
  if (!length(sheets)) {
    return(invisible(wb))
  }
  header_style <- createStyle(
    textDecoration = "bold",
    fgFill = "#DCE6F1",
    halign = "center",
    border = "Bottom",
    borderColour = "#000000"
  )

  for (sheet in sheets) {
    addStyle(
      wb,
      sheet = sheet,
      style = header_style,
      rows = 1,
      cols = seq_len(as.integer(max_cols)),
      gridExpand = TRUE
    )
    setColWidths(wb, sheet = sheet, cols = seq_len(as.integer(max_cols)), widths = "auto")
    addFilter(wb, sheet = sheet, row = 1, cols = seq_len(as.integer(max_cols)))
  }
  invisible(wb)
}


#' Tab-delimited file helper for UTF-16LE dumps
#'
#' @section Limitations:
#' Assumes tab separation and UTF-16LE; wrong \code{fileEncoding} produces garbage
#' rows silently—spot-check against a known-good extract.
#'
#' @param file_path Path to `.txt`/`.tab` dumps from legacy tooling.
#' @return `data.frame`
#' @section Workflow integration:
#' \itemize{
#'   \item **Legacy mainframe-style** tab exports that default readers mishandle—use at the ingest boundary then switch to standard tools.
#'   \item See \code{\link{admincleanr_training}} for encoding caveats.
#' }
#' @export
read_delim_utf16 <- function(file_path) {
  read.delim(
    file_path,
    fileEncoding = "UTF-16LE",
    sep = "\t",
    check.names = FALSE,
    stringsAsFactors = FALSE
  )
}


#' Rows where grouping column maps to multiple target values
#'
#' @section Limitations:
#' Surfaces \emph{structural} inconsistencies only; business rules for one-to-one
#' mappings are still yours to enforce.
#'
#' @param df input data.
#' @param group_col grouping column (bare name).
#' @param target_col column whose uniqueness within group must be flagged.
#' @section Workflow integration:
#' \itemize{
#'   \item **Integrity audit**: find IDs that map to conflicting category values before trusting one-to-many merges.
#'   \item See \code{\link{admincleanr_training}} for join QA sequencing.
#' }
#' @export
#' @importFrom dplyr group_by mutate ungroup filter n_distinct
mult_check <- function(df, group_col, target_col) {
  df %>%
    group_by({{ group_col }}) %>%
    mutate(n_unique = n_distinct({{ target_col }})) %>%
    ungroup() %>%
    filter(n_unique > 1)
}


#' Newest modified file path in a folder (excluding R sources)
#'
#' [`mr_file()`] reads files; keep this lightweight helper for scripting paths.
#'
#' @section Limitations:
#' Picks purely by filesystem \verb{mtime} among files that are not \verb{.R/.Rmd/.Rproj};
#' does not inspect file content or stabilize ties when timestamps tie.
#'
#' @param folder_path Directory to inspect.
#' @return Full path (`character` length 1) or `character(0)` if nothing matches.
#' @section Workflow integration:
#' \itemize{
#'   \item Script glue when filenames include timestamps—grab the latest drop without hard-coding the string (then pass path to \code{\link{read_data_file}}).
#'   \item See \code{\link{admincleanr_training}} vs \code{\link{mr_file}} when you also need automatic read.
#' }
#' @export
newest_data_file <- function(folder_path = ".") {
  all_files <- list.files(folder_path, full.names = TRUE)
  is_file <- !file.info(all_files)$isdir
  all_files <- all_files[is_file %in% TRUE]
  data_files <- all_files[!grepl("\\.(r|rmd|rproj)$", all_files, ignore.case = TRUE)]
  if (!length(data_files)) {
    return(character(0))
  }
  fi <- file.info(data_files)
  rownames(fi)[which.max(fi$mtime)]
}


#' Quickly coerce chosen columns with [`as.numeric()`]
#'
#' @section Limitations:
#' \code{as.numeric} yields \verb{NA} for non-coercible text; coercion warnings are
#' not customized here—validate critical identifiers before and after use.
#'
#' @section Workflow integration:
#' \itemize{
#'   \item Quick **numeric typing** of selected columns after reading character-heavy CSV exports prior to modeling or joins.
#'   \item See \code{\link{admincleanr_training}} for safer typed reads upstream when possible.
#' }
#'
#' @export
#' @importFrom dplyr mutate across
mumeric <- function(df, ...) {
  df %>%
    mutate(across(c(...), as.numeric))
}
