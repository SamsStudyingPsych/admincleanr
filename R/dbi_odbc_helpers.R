#' Open an ODBC connection from a DSN
#'
#' Thin wrapper around \code{DBI::dbConnect(odbc::odbc(), ...)} so scripts share
#' one pattern: DSN, optional credentials, optional driver arguments.
#'
#' @param dsn ODBC data source name (Windows ODBC Administrator, \code{/etc/odbc.ini}, or DSN-less driver blocks as supported by \pkg{odbc}).
#' @param uid,pwd Optional user and password; many DSNs embed these—omit when not needed.
#' @param ... Additional arguments forwarded to \code{odbc::odbc()} / \code{DBI::dbConnect()}.
#' @return A \code{DBI} connection object. Caller must \code{DBI::dbDisconnect()} when finished.
#' @export
#' @examples
#' \dontrun{
#' con <- odbc_connect_dsn("MY_ORACLE_DSN")
#' on.exit(DBI::dbDisconnect(con), add = TRUE)
#' DBI::dbGetQuery(con, "SELECT 1 AS x")
#' }
odbc_connect_dsn <- function(dsn, uid = NULL, pwd = NULL, ...) {
  if (missing(dsn) || !nzchar(as.character(dsn)[1L])) {
    stop("`dsn` must be a non-empty string.", call. = FALSE)
  }
  args <- list(dsn = dsn, ...)
  if (!is.null(uid)) {
    args$uid <- uid
  }
  if (!is.null(pwd)) {
    args$pwd <- pwd
  }
  do.call(dbConnect, c(list(odbc()), args))
}


#' Read SQL from a string or from a file path
#'
#' If \code{query} exists as a path on disk, the file contents are read with
#' \code{readLines(warn = FALSE)} and collapsed with newlines; otherwise
#' \code{query} is returned as a single string.
#'
#' @param query SQL text or path to a \code{.sql} file.
#' @return A length-one character string containing SQL.
#' @keywords internal
.read_sql_text <- function(query) {
  q <- as.character(query)[1L]
  if (is.na(q)) {
    stop("`query` is NA.", call. = FALSE)
  }
  if (nzchar(q) && file.exists(q)) {
    paste(readLines(q, warn = FALSE), collapse = "\n")
  } else {
    q
  }
}


#' Run a query against a DSN and return a data frame
#'
#' Connects, runs \code{DBI::dbGetQuery()}, optionally disconnects. Suitable for
#' ad hoc extracts in RStudio when the heavy lifting stays in SQL.
#'
#' @inheritParams odbc_connect_dsn
#' @param query SQL string or path to a file containing SQL (see unexported helper \code{.read_sql_text}).
#' @param .disconnect If \code{TRUE} (default), close the connection before returning.
#' @return A \code{data.frame} (tibble-like driver output depending on DBI method).
#' @export
#' @examples
#' \dontrun{
#' df <- dsn_query("MY_DSN", "SELECT TOP 10 * FROM dbo.DimDate")
#' }
dsn_query <- function(dsn, query, uid = NULL, pwd = NULL, ..., .disconnect = TRUE) {
  sql <- .read_sql_text(query)
  con <- odbc_connect_dsn(dsn, uid = uid, pwd = pwd, ...)
  if (isTRUE(.disconnect)) {
    on.exit(dbDisconnect(con), add = TRUE)
  }
  dbGetQuery(con, sql)
}


#' Store a data frame in the database
#'
#' Default uses \code{DBI::dbWriteTable()} with \code{append = TRUE} and
#' \code{row.names = FALSE}. Override \code{...} for schemas, temporary tables, or
#' vendor-specific arguments supported by your DBI backend.
#'
#' @inheritParams odbc_connect_dsn
#' @param data A \code{data.frame} (or coercible object) to write.
#' @param name Target table name (unqualified or \code{Id(schema = ..., table = ...)} when supported).
#' @param ... Additional arguments to \code{DBI::dbWriteTable()}.
#' @param .disconnect If \code{TRUE} (default), disconnect after the write.
#' @return \code{TRUE} invisibly on success.
#' @export
#' @examples
#' \dontrun{
#' dsn_write_table("MY_DSN", mtcars, name = "sandbox_mtcars", overwrite = TRUE)
#' }
dsn_write_table <- function(dsn, data, name, uid = NULL, pwd = NULL, ...,
                            .disconnect = TRUE) {
  con <- odbc_connect_dsn(dsn, uid = uid, pwd = pwd, ...)
  if (isTRUE(.disconnect)) {
    on.exit(dbDisconnect(con), add = TRUE)
  }
  dbWriteTable(con, name = name, value = data, row.names = FALSE, ...)
  invisible(TRUE)
}
