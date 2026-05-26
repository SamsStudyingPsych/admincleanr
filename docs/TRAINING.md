# Training: using **admincleanr** in day-to-day work

This page is meant to be read in a browser **or** from your IDE via `admincleanr_training("local")` (uses the copy shipped in the installed package). It stays **generic**—no employer field names or schema detail.

Keep **`docs/TRAINING.md`** and **`inst/doc/TRAINING.md`** in sync when editing training content (they should match at release so offline help matches GitHub).

---

## 1. Install and stay current

```r
# install.packages("devtools")
devtools::install_github("SamsStudyingPsych/admincleanr")
```

All helpers — including heuristic datetime coercion and join-overlap exploration (formerly in the companion `admincleanr_crunch` package) — ship with the main install.

Open this training page anytime:

```r
library(admincleanr)
admincleanr_training()              # browser (GitHub-rendered)
admincleanr_training("local")      # open bundled TRAINING.md in IDE when supported
```

---

## 2. Mental model: two styles of helper

| Style | Role | When to use |
| ----- | ---- | ----------- |
| **Explicit helpers** | Cleaning, linkage, I/O, plots, environment hygiene, explicit date parsers | Default starting point and production code. |
| **Heuristic helpers** | Try parse orders, explore candidate join keys, fuzzy matching | Ad hoc investigation, new feeds, unknown column semantics. |

Heuristics trade **CPU and ambiguity** for speed of iteration. Production code should name formats, keys, and transforms explicitly once you know them.

### Linkage workflow: “blocking” vs “fuzzy in R”

**Blocking** means using **exact** keys (or tight windows: date range + program + geography) in **SQL** so each record only competes against a **small** candidate set. You then bring **thousands or millions of candidate pairs** (not full cross-products) into R for similarity or fuzzy joins.

**Fuzzy-heavy in R** means shipping **large** unmatched extracts and letting string distance or similarity run on wide sets. That can work for one-off exploration but scales poorly and is harder to audit.

The question is only: *after you block, roughly how many rows or pairs are left?* That number guides settings like `max_dist` and whether a step is exploratory (heuristic helpers) or controlled production logic.

---

## 3. Core **admincleanr** flows

### 3.1 After SQL: text fields

Database text often embeds newlines. Normalize before joins or Parquet:

```r
df <- df %>% squish_character_columns()
```

Column names from exports are often noisy; standardize and trim:

```r
df <- df %>% clean_names_trim_ws()
```

### 3.2 Reading files by extension

```r
read_data_file("extract.parquet")
read_data_file("sheetful.xlsx", sheet = 1)
```

### 3.3 Memory and session safety

```r
clean_but_keep(main_tbl, lookup_tbl)
```

### 3.4 Join debugging

```r
cross_check_missing(df1, df2, check_var = problem_col, id_var = id_col)
```

### 3.5 String similarity (explicit, not guessing)

Use **multiple** signals; they measure different things:

- `count_consecutive_overlap()` — character-level streaks.
- `calculate_edit_distance()` — edit distance.
- `calculate_tfidf_similarity()` — shared **tokens** weighted by rarity in the **current batch**.

### 3.6 Optional fuzzy joins

Install `fuzzyjoin` and `stringdist`, then:

```r
fuzzy_left_join_stringdist(left, right, by = "name", max_dist = 1)
```

Tighten `max_dist` on big tables; consider blocking keys in SQL first.

---

## 4. Datetime guessing (heuristic)

When you **do not** yet know the datetime format, `coerce_best_datetime()` samples non-missing values, tries a **fixed menu** of `lubridate::parse_date_time` orders, and picks the order with the **fewest parse failures** on non-empty strings. It is **not** a substitute for an explicit format in production.

```r
coerce_best_datetime(x, quiet = FALSE)
```

`coerce_best_datetime_cols()` applies the same idea column-wise.

**Limitations:** ambiguous strings (e.g. `01/02/03`) may still parse wrong; time zones need explicit policy; Oracle often returns already-typed dates—prefer those over re-parsing character if you can.

---

## 5. Candidate keys when you are unsure

`pairwise_column_overlap()` compares **sets of distinct values** (sample-capped) between columns of two tables and returns a **Jaccard-like** overlap score. Use it to **rank** which ID-like columns might align—not as proof of a business key.

If you use a different **matrix / ranking** method in-house, consider contributing it behind a generic name (no employer-specific labels in examples). The maintainer can wire it in once you share a sanitized pattern.

---

## 6. Oracle, many schemas, many logins

Typical pattern: one **DSN or TNS** per environment, **different `UID`/`PWD` or proxy users** per schema. Keep connection scripts **out of the package**; use `DBI` + `odbc` (or your approved driver) locally. The package focuses on what happens **after** `dbGetQuery()` or after a Parquet handoff.

---

## 7. What belongs in the repo

- Reusable **functions** and **generic** workflow notes.  
- **Not** proprietary connection strings, full field dictionaries, or record-level excerpts.

### Sharing workflow in public (agency-safe)

Patterns that help **your** collaborators without weakening security:

- **Good to share:** Statistical or structural workflows (push-down filtering, Parquet staging, validating row counts after refresh, generic “blocking then fuzzy match” sequencing), synthetic or obviously fake mini examples, lessons about ODBC/driver quirks **without** hostnames, service names, or account names.
- **Avoid in public issues, gists, or chat logs:** Passwords, tokens, `UID`/`PWD`, full TNS/DSN strings, internal server or scan hostnames, schema maps that fingerprint a specific environment, real or deduplicated-looking **record-level** values (including “anonymized” IDs that are still stable keys), and screenshots of query results.
- **Examples in docs:** Prefer abstract labels (`subject_key`, `encounter_dt`, `program_cd`) and narratives that fit **public-health or government administrative** data broadly—not names of systems, vendors, or programs tied to one agency.

Public workflow notes are welcome when framed at that level; they make the package easier to teach without widening an attack surface.

---

## 8. Roadmap

- Extend heuristic helpers (with caps and diagnostics) based on sanitized feedback.
- Add validation-first pipeline transforms as APIs stabilize.

For questions about training content only, use the contact on the main **README**.
