# admincleanr

Toolkit for administrative data cleaning, record linkage, and heavy-session workflows in R.

Install from GitHub:

```r
# install.packages("devtools")
# install.packages("pak")
pak::pak("SamsStudyingPsych/admincleanr")
```

### Training — copy-paste in RStudio / Positron

```r
library(admincleanr)           # exports helpers and autoloads the tidyverse/DBI workbench stack
admincleanr_training()         # browser → GitHub training page
admincleanr_training("local") # IDE → bundled TRAINING.md (needs install from GitHub)
```

The workbench stack auto-attaches by default in normal console, `Rscript`, and batch sessions. Set `options(admincleanr.autoload_workbench = FALSE)` before `library(admincleanr)` only when you want to disable that behavior; if dependencies were missing, reinstall and then run `admincleanr_attach_workbench()`.

Forks: `options(admincleanr.training_url = "<your TRAINING.md blob URL>")` then `admincleanr_training()`. Training source: `docs/TRAINING.md` (mirrored in `inst/doc/` for installs). After `library(admincleanr)`, you can call every exported helper by name; the `admincleanr::` prefix is only required when you deliberately skip attaching the package.

## Staying up to date

Re-run `pak::pak` whenever you pull changes from GitHub:

```r
pak::pak("SamsStudyingPsych/admincleanr", upgrade = "always")
```

`upgrade = "always"` refreshes dependency packages as well (`remotes`/Pak offer similar workflows). For reproducibility in production jobs, pin a commit or Git tag once you validate a release.

### Calling helpers (no `admincleanr::` prefix)

After `library(admincleanr)`, use exported helpers by name — for example `squish_character_columns()`, not `admincleanr::squish_character_columns()`. The `::` form is optional (handy when you have not attached the package yet).

In normal sessions, `library(admincleanr)` also tries to attach the usual workbench stack (`tidyverse`, `janitor`, `readxl`, `DBI`, `odbc`), so those helpers are available without a package prefix too. Turn that off with `options(admincleanr.autoload_workbench = FALSE)`.

If workbench packages fail to attach, you now get an explicit startup message with reinstall guidance instead of a silent skip.

---

## Highlights

- **Environment hygiene:** `clean_but_keep()` trims large workspaces without wiping functions you rely on.
- **Join QA:** `cross_check_missing()` helps trace records that fail merges.
- **String similarity:** `calculate_edit_distance()`, `count_consecutive_overlap()`, and `calculate_tfidf_similarity()` for comparing messy names and labels.
- **Fuzzy joins (optional):** install `fuzzyjoin` and `stringdist`, then use `fuzzy_left_join_stringdist()` for approximate key matches (typos, formatting drift).
- **I/O helpers:** `read_data_file()` by extension, `read_parquet_with_date()` with a quick mtime message, `clean_names_trim_ws()`, and `squish_character_columns()` (newline/whitespace cleanup after SQL pulls).
- **Time helpers:** `parse_time_to_mins()`, `ts_to_weekly_mins()` for clock / weekly-offset math.
- **Excel exports:** `export_formatted_excel()`, `save_to_excel_multisheet_formatted()`.
- **Datetime guessing:** `coerce_best_datetime()` and `coerce_best_datetime_cols()` try several parse orders and pick the best fit (heuristic, for exploration).
- **Column-overlap scoring:** `pairwise_column_overlap()` ranks candidate join keys by Jaccard overlap on distinct values.

Quick pattern after pulling from a database (`DBI`), before writing Parquet:

```r
library(admincleanr)
df <- dbGetQuery(con, "SELECT ... FROM ...")
df <- df %>% squish_character_columns()
arrow::write_parquet(df, "out.parquet")
```

(or keep everything in-memory and skip writing when exploring).

---

## TF-IDF similarity vs overlap scores

Functions answer different questions:

| Function | Idea |
| -------- | ---- |
| `count_consecutive_overlap()` | Longest streak of matching *characters* (substring-style signal). |
| `calculate_edit_distance()` | How many single-character edits to turn one string into another. |
| `calculate_tfidf_similarity()` | Tokenize on spaces, look at *shared words*, weight each word by inverse document frequency (rarer words count more). It is **not** the same as longest shared character runs; it rewards shared distinctive tokens (e.g. unusual provider name fragments). |

Use them together: high token overlap + low edit distance usually means a confident match candidate.

---

## Package vs pasted functions

Exported functions compile to the same bytecode as equivalent code you paste into a `.R` file. After `library(admincleanr)` you can call helpers by name (for example `squish_character_columns()` or `coerce_best_datetime()`, no `admincleanr::` prefix required). The package adds documentation, versioning, re-exported pipeline verbs (`mutate`, `dbGetQuery`, and others), and **dependency declarations** (`Imports` / `Suggests`) so `install_github` resolves what you need. Runtime speed is essentially the same; the win is reproducibility and sharing without copying ad hoc scripts. The `admincleanr::` prefix remains available when you choose not to attach the package.

---

## Maintainer notes

Development workflow summary (Positron, SQL, governance constraints) lives in [`docs/WORKFLOW_NOTES.md`](docs/WORKFLOW_NOTES.md).

Optional tooling: maintainer-facing `usethis` helpers moved to [`tools/add_dependencies.R`](tools/add_dependencies.R) (they are **not** loaded when users `library(admincleanr)`).

---

## Contributing

Pull requests are welcome for repetitive administrative-data tasks.

Contact: [sam.a.barans@gmail.com](mailto:sam.a.barans@gmail.com).
