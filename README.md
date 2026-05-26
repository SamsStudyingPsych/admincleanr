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
library(admincleanr)
admincleanr_training()         # browser → GitHub training page
admincleanr_training("local") # IDE → bundled TRAINING.md (needs install from GitHub)
```

Forks: `options(admincleanr.training_url = "<your TRAINING.md blob URL>")` then `admincleanr_training()`. Training source: `docs/TRAINING.md` (mirrored in `inst/doc/` for installs).

### Previously separate companion packages (now included)

Functions from `admincleanr_crunch` (datetime guessing, column-overlap scoring) and `admincleanr_pipe` (pipeline scaffold) are now bundled in the main package. No separate install needed — just `library(admincleanr)` and call them directly:

```r
library(admincleanr)
coerce_best_datetime(x)
coerce_best_datetime_cols(df, c("date1", "date2"))
pairwise_column_overlap(left, right)
```

## Staying up to date

Re-run `pak::pak` whenever you pull changes from GitHub:

```r
pak::pak("SamsStudyingPsych/admincleanr", upgrade = "always")
```

`upgrade = "always"` refreshes dependency packages as well (`remotes`/Pak offer similar workflows). For reproducibility in production jobs, pin a commit or Git tag once you validate a release.

---

## Highlights

- **Environment hygiene:** `clean_but_keep()` trims large workspaces without wiping functions you rely on.
- **Join QA:** `cross_check_missing()` helps trace records that fail merges.
- **String similarity:** `calculate_edit_distance()`, `count_consecutive_overlap()`, and `calculate_tfidf_similarity()` for comparing messy names and labels.
- **Fuzzy joins (optional):** install `fuzzyjoin` and `stringdist`, then use `fuzzy_left_join_stringdist()` for approximate key matches (typos, formatting drift).
- **I/O helpers:** `read_data_file()` by extension, `read_parquet_with_date()` with a quick mtime message, `clean_names_trim_ws()`, and `squish_character_columns()` (newline/whitespace cleanup after SQL pulls).
- **Time helpers:** `parse_time_to_mins()`, `ts_to_weekly_mins()` for clock / weekly-offset math.
- **Excel exports:** `export_formatted_excel()`, `save_to_excel_multisheet_formatted()`.
- **Datetime guessing:** `coerce_best_datetime()`, `coerce_best_datetime_cols()` for heuristic date/time parsing on messy extracts.
- **Join discovery:** `pairwise_column_overlap()` ranks candidate join keys by Jaccard overlap across two tables.

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

Exported functions compile to the same bytecode as equivalent code you paste into a `.R` file. The package adds documentation, versioning, and **dependency declarations** (`Imports` / `Suggests`) so `install_github` resolves what you need. After `library(admincleanr)`, all functions are available directly — no `admincleanr::` prefix required. Runtime speed is essentially the same; the win is reproducibility and sharing without copying ad hoc scripts.

---

## Maintainer notes

Development workflow summary (Positron, SQL, governance constraints) lives in [`docs/WORKFLOW_NOTES.md`](docs/WORKFLOW_NOTES.md).

Optional tooling: maintainer-facing `usethis` helpers moved to [`tools/add_dependencies.R`](tools/add_dependencies.R) (they are **not** loaded when users `library(admincleanr)`).

---

## Contributing

Pull requests are welcome for repetitive administrative-data tasks.

Contact: [sam.a.barans@gmail.com](mailto:sam.a.barans@gmail.com).
