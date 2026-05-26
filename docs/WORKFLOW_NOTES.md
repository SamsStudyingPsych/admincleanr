# Workflow notes (from package development brief)

Compressed summary of priorities discussed for **admincleanr** and surrounding practice. Intended as durable context for collaborators and agents without depending on proprietary data.

## Goals

- **Governance:** Share code patterns, not identifiable record-level exports.
- **Sustainability:** Prefer plain R + standard packages; avoid IDE lock-in where possible (Positron today, transferable to RStudio/VSC-style setups).
- **Compute:** Optimize for laptops (e.g. 64 GB RAM) against multi-million-row tables—stream with **SQL → Parquet/Arrow**, `rm()`, and `clean_but_keep()`, not monster `left_join`s in RAM when avoidable.

## Repository layout

The single install is **`admincleanr`**, which includes both core cleaning helpers and exploratory heuristics (datetime guessing, column-overlap scoring). Multi-schema Oracle environments favour keeping connection details local while sharing only the R transformations that sit *after* extracts.

## Practical stack

| Layer | Recommendation |
| ----- | ---------------- |
| Queries | Prefer push-down SQL (filters, aggregates, narrowing columns) instead of hauling full histories into R. |
| Transfer | Save Parquet (see `squish_character_columns()`, `arrow`) for repeatable local steps. |
| IDE | Positron for R; adopt a dedicated SQL workflow where editing is weakest (dbeaver-lite style client, IDE SQL notebook, or versioned `.sql` files). |
| Linkage | Build candidate keys in SQL where possible; use R for fuzzy tiers (`stringdist`, `fuzzyjoin`, package overlap/TF-IDF helpers). |

## Clarifying answers (inform future features)

Automating “guess every datetime format blindly” across columns without context risks silent corruption on administrative data **unless** guarded (column metadata, allowable format list, or human validation). Prefer explicit format lists plus `parse_time_to_mins()` / similar helpers once you infer the pattern on a slice.

Questions worth revisiting periodically: which ODBC drivers/DNS are sanctioned, nightly batch versus interactive extract limits, and whether Arrow datasets or DuckDB-backed queries are approved for PHI-adjacent work.
