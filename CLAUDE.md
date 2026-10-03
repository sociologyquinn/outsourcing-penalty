# Outsourcing penalty replication

Goal: replicate Dube & Kaplan (2010, ILRR) in Python, extend to 2001-2025,
and compare the D&K specification (dk) to my own (kq). Python only.

## Environment
- Conda env `outsourcing`: /Users/kq/opt/anaconda3/envs/outsourcing/bin/python
- Estimation: pyfixest.

## Source of truth
- `refs/cleaning.md`: variable construction (implemented in 01_clean).
- `refs/dk_spec.md`: D&K model, samples, incidence, benchmarks, robustness.
- `refs/kq_spec.md`: my model (dk plus gov_employee), mediation,
  summary statistics.
- Read the relevant spec before writing code. Spec files are authoritative.
- `refs/dube_kaplan_2010.pdf` is background. Read only when asked.
- If code and a spec disagree, stop and ask. Never edit spec files unless asked.

## Rules
- Never read raw files in data/ipums_data directly into the conversation.
- Never modify or overwrite anything in data/.
- Never overwrite datasets or files: write new filenames; never reassign
  a dataframe to its own name (dk_raw -> dk_core -> dk_clean).
- Never tune code to move estimates toward benchmarks; report differences.

## Notebooks
- 00_build_data.ipynb: raw extract -> data/dk_core.parquet
- 01_clean.ipynb: recodes -> outputs/py/dk_clean.parquet
- Later notebooks load outputs/py/dk_clean.parquet and do not re-clean.

## Outputs
Write to outputs/py/ (figures: outputs/figures/). Estimates in long format,
one row per term: lang, spec, model, occ, sample, term, estimate, se, t, p, n_obs.
- spec: dk, kq, or dk_kqsample (dk estimated on the kq sample)
- model: base or nounion

## Reference files in data/
See `data/README_manifest.csv`. The `role` column governs use:
- input: source data. Read via code only; never load into the conversation.
- benchmark: D&K published values. Compare to these; never invent others.
- crosscheck: legacy R output expected to match Python closely.
- legacy: old R spec and cleaning. Reference only.

## Robustness checks (planned)
- Complete cases on urbanicity (defined in `refs/dk_spec.md`; expect a somewhat smaller penalty)
- Unweighted vs EARNWT-weighted
- Extension: metro-by-year FE (city minimum wages concentrate in central
  cities, where outsourced workers are overrepresented)

## Open issues (delete each line once resolved)
- 1983-85 incidence: janitors 0.13 vs D&K 0.164; guards 0.37 vs 0.401.
  Compare against data/incidence_table1_1983_2000.csv (crosscheck)
  before looking elsewhere.
  - DEFERRED, do not investigate unless asked: incidence levels below D&K; excluding local government (CLASSWKR 28) closely matches D&K Table 1. Mechanism unconfirmed. Report the gap; do not change the sample.