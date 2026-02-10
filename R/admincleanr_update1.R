#' Excelify Column Names
#' Converts snake_case or dot.case to "Title Case With Spaces"
excelify_names <- function(x) {
  x %>%
    gsub("[_\\.]", " ", .) %>%  # Replace underscores and dots with spaces
    tools::toTitleCase()        # Convert to Title Case
}

#' Export Dataframe with Professional Formatting
#'
#' @param df The dataframe to export.
#' @param filepath The output path for the .xlsx file.
#' @param sheet_name Name of the worksheet.
export_formatted_excel <- function(df, filepath, sheet_name = "Data") {
  
  # 1. Excelify Names (Rename columns in a copy of the dataframe)
  # We use setNames to apply the formatting function to headers
  export_df <- df
  colnames(export_df) <- excelify_names(colnames(df))
  
  # 2. Create Workbook and Worksheet
  wb <- openxlsx::createWorkbook()
  openxlsx::addWorksheet(wb, sheet_name)
  
  # 3. Write Data
  openxlsx::writeData(wb, sheet = sheet_name, x = export_df)
  
  # --- FORMATTING ---
  
  # Define Style: Bold + Light Blue Background
  header_style <- openxlsx::createStyle(
    textDecoration = "bold",
    fgFill = "#DCE6F1",       # Standard Excel light blue
    halign = "center",        # Optional: Centers text
    border = "Bottom",        # Optional: Adds a subtle border line
    borderColour = "#000000"
  )
  
  # Identify dimensions
  num_cols <- ncol(export_df)
  num_rows <- nrow(export_df) + 1 # +1 for header
  
  # Apply Style to Header Row (Row 1)
  openxlsx::addStyle(
    wb, 
    sheet = sheet_name, 
    style = header_style, 
    rows = 1, 
    cols = 1:num_cols, 
    gridExpand = TRUE
  )
  
  # 4. "Double Click" Cols (Auto-fit widths)
  openxlsx::setColWidths(
    wb, 
    sheet = sheet_name, 
    cols = 1:num_cols, 
    widths = "auto"
  )
  
  # 5. Add Dropdowns (Auto-filter)
  openxlsx::addFilter(
    wb, 
    sheet = sheet_name, 
    row = 1, 
    cols = 1:num_cols
  )

    # 6. Construct Timestamped Path
  timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
  
  # Handle extension correctly (insert timestamp before .xlsx)
  base_path <- tools::file_path_sans_ext(filepath)
  ext <- tools::file_ext(filepath)
  if (ext == "") ext <- "xlsx" # Default if user forgets extension
  
  final_path <- paste0(base_path, "_", timestamp, ".", ext)
  
  # 6. Save
  openxlsx::saveWorkbook(wb, filepath, overwrite = TRUE)
  message(paste("Exported formatted Excel file to:", filepath))
}

#' Save Multiple Dataframes to Formatted Excel Sheets
#'
#' @description
#' Takes a list of dataframes and saves them to separate sheets in a single
#' timestamped Excel workbook. Applies standard formatting (Excelify names, 
#' bold/blue headers, auto-width, auto-filter) to every sheet.
#'
#' @param filepath The base output path for the .xlsx file. A timestamp will be appended.
#' @param sheet_names A character vector of names for the sheets.
#' @param data_list A list of the dataframe objects to write.
#' @export
save_to_excel_multisheet_formatted <- function(filepath, sheet_names, data_list) {
  
  # --- Input Validation ---
  if (length(sheet_names) != length(data_list)) {
    stop("Error: The number of sheet names must equal the number of dataframes in the list.")
  }
  
  if (!is.list(data_list) || is.data.frame(data_list)) {
    stop("Error: 'data_list' must be a list of dataframes (e.g., list(df1, df2)).")
  }
  
  # 1. Create Workbook
  wb <- openxlsx::createWorkbook()
  
  # Define Style once to reuse
  header_style <- openxlsx::createStyle(
    textDecoration = "bold",
    fgFill = "#DCE6F1",       # Standard Excel light blue
    halign = "center",
    border = "Bottom",
    borderColour = "#000000"
  )
  
  # 2. Loop through list and process each dataframe
  for (i in seq_along(data_list)) {
    current_sheet <- sheet_names[i]
    current_df <- data_list[[i]]
    
    # Skip if not a dataframe
    if (!is.data.frame(current_df)) {
      warning(paste("Item at index", i, "is not a dataframe. Skipping sheet:", current_sheet))
      next
    }
    
    # Excelify Names
    current_df <- excelify_names(current_df)
    
    # Add Sheet and Write Data
    openxlsx::addWorksheet(wb, sheetName = current_sheet)
    openxlsx::writeData(wb, sheet = current_sheet, x = current_df)
    
    # Apply Formatting
    num_cols <- ncol(current_df)
    
    if (num_cols > 0) {
      # Style Header
      openxlsx::addStyle(
        wb, 
        sheet = current_sheet, 
        style = header_style, 
        rows = 1, 
        cols = 1:num_cols, 
        gridExpand = TRUE
      )
      
      # Auto Widths
      openxlsx::setColWidths(
        wb, 
        sheet = current_sheet, 
        cols = 1:num_cols, 
        widths = "auto"
      )
      
      # Auto Filter
      openxlsx::addFilter(
        wb, 
        sheet = current_sheet, 
        row = 1, 
        cols = 1:num_cols
      )
    }
  }
  
  # 3. Construct Timestamped Path
  timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
  base_path <- tools::file_path_sans_ext(filepath)
  ext <- tools::file_ext(filepath)
  if (ext == "") ext <- "xlsx"
  
  final_path <- paste0(base_path, "_", timestamp, ".", ext)
  
  # 4. Save
  openxlsx::saveWorkbook(wb, final_path, overwrite = TRUE)
  message(paste("Exported multi-sheet formatted Excel file to:", final_path))
}

#' Format Workbook Headers
#'
#' @description
#' Loops through every sheet in an openxlsx Workbook object. Bolds the first row,
#' sets the background color to light blue (#DCE6F1), and adds Excel auto-filters
#' to all columns.
#'
#' @param wb A Workbook object.
#' @return The modified Workbook object.
#' @export
#' @importFrom openxlsx createStyle addStyle addFilter readWorkbook
format_workbook_headers <- function(wb) {
  
  header_style <- openxlsx::createStyle(
    textDecoration = "bold",
    fgFill = "#DCE6F1"
  )
  
  for (sheet in names(wb)) {
    header_row <- openxlsx::readWorkbook(wb, sheet = sheet, rows = 1, colNames = FALSE)
    
    if (!is.null(header_row) && ncol(header_row) > 0) {
      num_cols <- ncol(header_row)
      
      openxlsx::addStyle(
        wb, 
        sheet = sheet, 
        style = header_style, 
        rows = 1, 
        cols = 1:num_cols, 
        gridExpand = TRUE
      )
      
      openxlsx::addFilter(
        wb, 
        sheet = sheet, 
        row = 1, 
        cols = 1:num_cols
      )
    }
  }
  return(wb)
}

#' Read and Bind Excel Sheets (Excluding "Query")
#'
#' @description
#' Reads every sheet in an Excel file *except* the one named "Query" and
#' combines them into a single dataframe using `bind_rows`.
#'
#' @param filepath A character string path to the .xlsx file.
#' @param id_col Optional. A string name for a new column to store the
#'   sheet names. If NULL (default), no ID column is created.
#' @return A combined dataframe.
#' @export
#' @importFrom readxl excel_sheets read_excel
#' @importFrom purrr map set_names
#' @importFrom dplyr bind_rows
read_sheets_exclude_query <- function(filepath, id_col = NULL) {
  
  all_sheets <- readxl::excel_sheets(filepath)
  sheets_to_read <- setdiff(all_sheets, "Query")
  
  combined_data <- sheets_to_read %>%
    purrr::set_names() %>%
    purrr::map(~ readxl::read_excel(filepath, sheet = .x)) %>%
    dplyr::bind_rows(.id = id_col)
  
  return(combined_data)
}

#' Read Delimited File (UTF-16LE)
#'
#' @description
#' A wrapper for `read.delim` specifically tuned for files exported with
#' UTF-16LE encoding (common in legacy systems), which often fail with
#' standard read functions.
#'
#' @param file_path The path to the file.
#' @return A dataframe.
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

#' Multi-Value Check
#'
#' @description
#' Groups a dataframe by a specified variable and filters for groups that have
#' more than one unique value in a target variable. Useful for finding data
#' inconsistencies (e.g., one Case Number with multiple Aid Types).
#'
#' @param df The dataframe to check.
#' @param group_col The column to group by (unquoted).
#' @param target_col The column to count unique values of (unquoted).
#' @return A filtered dataframe containing only the groups with >1 unique target value.
#' @export
#' @importFrom dplyr group_by mutate ungroup filter n_distinct
mult_check <- function(df, group_col, target_col) {
  df %>%
    dplyr::group_by({{ group_col }}) %>%
    dplyr::mutate(n_unique = dplyr::n_distinct({{ target_col }})) %>%
    dplyr::ungroup() %>%
    dplyr::filter(n_unique > 1)
}

#' Find Most Recent File (Non-R Files)
#'
#' @description
#' Scans a directory for the most recently modified file, automatically excluding
#' .R, .Rmd, and .Rproj files to target data extracts.
#'
#' @param folder_path The directory to scan. Defaults to current working directory.
#' @return The full path to the newest non-script file.
#' @export
mr_file <- function(folder_path = ".") {
  all_files <- list.files(folder_path, full.names = TRUE)
  
  # Exclude script files
  data_files <- all_files[!grepl("\\.(R|Rmd|Rproj)$", all_files, ignore.case = TRUE)]
  
  if (length(data_files) == 0) return(character(0))
  
  file_info <- file.info(data_files)
  rownames(file_info)[which.max(file_info$mtime)]
}

#' Mutate to Numeric
#'
#' @description
#' A quick wrapper to convert specific columns to numeric.
#'
#' @param df The dataframe.
#' @param ... Columns to convert (unquoted).
#' @return The modified dataframe.
#' @export
#' @importFrom dplyr mutate across
mumeric <- function(df, ...) {
  df %>%
    dplyr::mutate(dplyr::across(c(...), as.numeric))
}