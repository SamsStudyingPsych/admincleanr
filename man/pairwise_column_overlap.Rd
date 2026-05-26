\name{pairwise_column_overlap}
\alias{pairwise_column_overlap}
\title{Pairwise overlap of distinct values between columns of two tables}
\usage{
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
\item{left, right}{Data frames.}

\item{left_cols}{Column names in \code{left} to evaluate.}

\item{right_cols}{Column names in \code{right} to evaluate.}

\item{max_distinct}{Maximum distinct values retained per column before comparison.}

\item{seed}{Optional RNG seed so sampling is reproducible when sets are large.}
}
\value{
A data.frame sorted by descending \code{jaccard}.
}
\description{
Builds a similarity score (Jaccard index on distinct value sets) for every
pair of columns listed from \code{left} and \code{right}. Use it to rank
plausible identifier or code columns when joining unfamiliar extracts.
}
\examples{
\dontrun{
library(admincleanr)
pairwise_column_overlap(left, right)
}
}
