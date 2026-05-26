\name{coerce_best_datetime}
\alias{coerce_best_datetime}
\title{Coerce values to Date/POSIXct by trying several parse orders}
\usage{
coerce_best_datetime(
  x,
  orders = .default_parse_orders(),
  tz = "UTC",
  sample_size = 8000L,
  result = c("auto", "Date", "POSIXct"),
  excel_serial = TRUE,
  quiet = TRUE
)
}
\arguments{
\item{x}{Vector of input values.}

\item{orders}{Character vector of \code{parse_date_time} order strings.}

\item{tz}{Time zone for parsed datetimes.}

\item{sample_size}{Maximum number of non-empty values to score.}

\item{result}{Return \code{Date}, \code{POSIXct}, or \code{auto}.}

\item{excel_serial}{If \code{TRUE}, attempt Excel serial conversion for numeric input.}

\item{quiet}{If \code{FALSE}, print the chosen order and NA rate.}
}
\value{
A \code{Date} or \code{POSIXct} vector aligned with \code{x}.
}
\description{
Samples non-missing values, evaluates candidate \code{orders} strings with
\code{lubridate::parse_date_time()}, and applies the order with the fewest
failed parses to the full vector.
}
\details{
This helper is intended for exploratory work when a source date format is not
yet known. Once the format is understood, prefer an explicit parser in
production code.
}
\examples{
\dontrun{
library(admincleanr)
coerce_best_datetime(c("2024-01-02", "2024-01-03"), quiet = FALSE)
}
}
