# admincleanr_crunch

Heuristic helpers for **fast exploration** when you have limited prior knowledge of a feed: try several datetime parse orders, compare distinct values across columns to guess candidate join keys, and similar “crunch time” tooling.

Designed for iterative analysis—not as a substitute for explicit formats and keys once you discover them (**see `admincleanr_pipe`** for that trajectory).

Install from this monorepo:

```r
devtools::install_github("SamsStudyingPsych/admincleanr", subdir = "admincleanr_crunch")
```

Attach once per session, then call the exported heuristics directly:

```r
library(admincleanr_crunch)
coerce_best_datetime(x, quiet = FALSE)
pairwise_column_overlap(left_tbl, right_tbl)
```

Main entry points:

- `coerce_best_datetime()`, `coerce_best_datetime_cols()`
- `pairwise_column_overlap()`

Fuzzy joins remain in **`admincleanr`** for now (`fuzzy_left_join_stringdist()`).

Open the shared training overview from R (`docs/TRAINING.md` on GitHub):

```r
admincleanr::admincleanr_training()
```
