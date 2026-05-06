# admincleanr

Toolkit for administrative data cleaning, record linkage, and heavy-session workflows in R.

Install from GitHub:

```r
# install.packages("devtools")
devtools::install_github("SamsStudyingPsych/admincleanr")
```

## Staying up to date

Re-run `install_github` whenever you pull changes from GitHub:

```r
devtools::install_github("SamsStudyingPsych/admincleanr", upgrade = "always")
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

Quick pattern after pulling from a database (`DBI`), before writing Parquet:

```r
df <- dbGetQuery(con, "SELECT ... FROM ...")
df <- df %>% admincleanr::squish_character_columns()
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

Exported functions compile to the same bytecode as equivalent code you paste into a `.R` file. The package adds namespacing (`admincleanr::`), documentation, versioning, and **dependency declarations** (`Imports` / `Suggests`) so `install_github` resolves what you need. Runtime speed is essentially the same; the win is reproducibility and sharing without copying ad hoc scripts.

---

## Maintainer notes

Development workflow summary (Positron, SQL, governance constraints) lives in [`docs/WORKFLOW_NOTES.md`](docs/WORKFLOW_NOTES.md).

Optional tooling: maintainer-facing `usethis` helpers moved to [`tools/add_dependencies.R`](tools/add_dependencies.R) (they are **not** loaded when users `library(admincleanr)`).

---

## Contributing

Pull requests are welcome for repetitive administrative-data tasks.

Contact: [sam.a.barans@gmail.com](mailto:sam.a.barans@gmail.com).
