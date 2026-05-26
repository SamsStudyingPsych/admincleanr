# admincleanr_crunch

Heuristic helpers for **fast exploration** when you have limited prior knowledge of a feed: try several datetime parse orders, compare distinct values across columns to guess candidate join keys, and similar "crunch time" tooling.

Designed for iterative analysis—not as a substitute for explicit formats and keys once you discover them (**see `admincleanr_pipe`** for that trajectory).

**These functions are exported by `admincleanr`** — installing and loading the main package is all
you need:

```r
pak::pak("SamsStudyingPsych/admincleanr")
library(admincleanr)

coerce_best_datetime(x)           # no prefix needed
coerce_best_datetime_cols(df, cols)
pairwise_column_overlap(df1, df2)
```

Main entry points:

- `coerce_best_datetime()`, `coerce_best_datetime_cols()`
- `pairwise_column_overlap()`

Fuzzy joins remain in **`admincleanr`** for now (`fuzzy_left_join_stringdist()`).

Open the shared training overview from R (`docs/TRAINING.md` on GitHub):

```r
library(admincleanr)
admincleanr_training()
```
