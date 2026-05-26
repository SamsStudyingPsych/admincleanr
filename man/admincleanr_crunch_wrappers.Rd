% Manual file for companion-package wrappers.
\name{admincleanr_crunch_wrappers}
\alias{coerce_best_datetime}
\alias{coerce_best_datetime_cols}
\alias{pairwise_column_overlap}
\title{Convenience wrappers for admincleanr_crunch helpers}
\usage{
coerce_best_datetime(
  x,
  orders = c(
    "Ymd HMS", "Ymd HM", "Ymd",
    "mdy HMS", "mdy HM", "mdy",
    "dmy HMS", "dmy HM", "dmy",
    "ymd HMS", "ymd HM", "ymd"
  ),
  tz = "UTC",
  sample_size = 8000L,
  result = c("auto", "Date", "POSIXct"),
  excel_serial = TRUE,
  quiet = TRUE
)

coerce_best_datetime_cols(data, cols, ...)

pairwise_column_overlap(
  left,
  right,
  left_cols = names(left),
  right_cols = names(right),
  max_distinct = 5000L,
  seed = NULL
)
}
\arguments{
\item{x}{Vector of input values (\code{character}, \code{Date}, \code{POSIXt}, or numeric for Excel).}

\item{orders}{Character vector of candidate datetime parse orders.}

\item{tz}{Time zone for parsed datetimes.}

\item{sample_size}{Maximum number of non-empty values used when scoring orders.}

\item{result}{Return \code{Date}, \code{POSIXct}, or \code{auto} (date if all times are midnight).}

\item{excel_serial}{If \code{TRUE}, attempt Excel serial conversion for numeric \code{x}.}

\item{quiet}{If \code{FALSE}, prints the chosen order and NA rate on non-empty strings.}

\item{data}{A \code{data.frame}.}

\item{cols}{Character vector of column names.}

\item{...}{Arguments forwarded to \code{coerce_best_datetime()}.}

\item{left,right}{Data frames.}

\item{left_cols}{Column names in `left` to evaluate.}

\item{right_cols}{Column names in `right` to evaluate.}

\item{max_distinct}{Maximum distinct values retained per column before comparison.}

\item{seed}{Optional RNG seed so sampling is reproducible when sets are large.}
}
\value{
The same return value as the matching \pkg{admincleanr_crunch} function.
}
\description{
These wrappers let \code{library(admincleanr)} expose the main entry points from
\pkg{admincleanr_crunch} without requiring \code{admincleanr_crunch::} prefixes in user code.
}
\details{
\pkg{admincleanr_crunch} remains an optional sibling package. If it is not installed,
these wrappers stop with an install hint instead of creating a hard dependency from
\pkg{admincleanr} to the companion package.
}
