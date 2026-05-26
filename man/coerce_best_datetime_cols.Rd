\name{coerce_best_datetime_cols}
\alias{coerce_best_datetime_cols}
\title{Apply coerce_best_datetime() to selected columns}
\usage{
coerce_best_datetime_cols(data, cols, ...)
}
\arguments{
\item{data}{A data.frame.}

\item{cols}{Character vector of column names.}

\item{...}{Arguments passed to \code{\link{coerce_best_datetime}}.}
}
\value{
\code{data} with selected columns coerced.
}
\description{
Applies the same heuristic independently to each listed column. Formats may
differ column to column, but each column is scored in isolation.
}
\examples{
\dontrun{
library(admincleanr)
coerce_best_datetime_cols(df, c("start_date", "end_date"))
}
}
