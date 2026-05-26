# admincleanr_pipe (scaffold)

This package reserves a **narrow API** for code you want to keep boring, explicit, and safe when database formats change—typically the path from **Oracle → typed extract → Parquet** with named formats, documented keys, and regression checks.

Today the implementation still lives mainly in the root **`admincleanr`** package. Install that for real functions; install this subpackage to signal intent and to receive future migrations without renaming your project folder.

```r
devtools::install_github("SamsStudyingPsych/admincleanr", subdir = "admincleanr_pipe")
```

Design goals when code moves here:

- Prefer **declared** datetime formats and schema contracts over guessing.
- Keep **dependencies minimal** and auditable.
- Pair each transform with a **cheap validation** (row counts, key uniqueness, spot diffs between refresh dates).

See also `docs/TRAINING.md` in the repository; after `library(admincleanr)`, run `admincleanr_training()`.
