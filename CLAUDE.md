# Outsourcing penalty replication

Goal: replicate Dube & Kaplan (2010, ILR Review) in Python for 1983-2000, then
apply the same model to 2001-2025. Python only.

## Environment
- Conda env `outsourcing`: /Users/kq/opt/anaconda3/envs/outsourcing/bin/python
- Estimation: pyfixest.

## Source of truth
- `refs/cleaning.md`: variable construction (implemented in 01_clean).
- `refs/dk_spec.md`: what D&K report, and benchmarks.
- `refs/author_spec.md`: the author's model (D&K's eq. 1 with documented
  construction choices), analyses, and robustness checks.
- Read the relevant spec before writing code. Spec files are authoritative.
- `refs/dube_kaplan_2010.pdf` is background. Read only when asked.
- If code and a spec disagree, stop and ask. Never edit spec files unless asked.

## Rules
- Never read data/ipums_data/ directly into the conversation.
- Never modify files in data/, and never reassign a dataframe to its own name.
- Anything in outputs/ may be overwritten; git keeps history for tracked files.
- Never tune code to move estimates toward benchmarks; report differences.
- Rerun only notebooks affected by a change. Formatting or table changes:
  03_tables only. Rerun 02_estimates only if cleaning or the model changed.
- Exception: 00_build_data writes data/ipums_data/dk_core.parquet. Do not
  rerun it unless asked.

## Notebooks
- 00_build_data: raw extract -> data/ipums_data/dk_core.parquet
- 01_clean: recodes -> outputs/py/dk_clean.parquet
- 02_estimates: incidence, validation, penalties, mediation
- 03_tables: publication tables -> outputs/tables/
- 04_trends: trend tests
- 05_minwage: minimum wage extension
Later notebooks load outputs/py/dk_clean.parquet and do not re-clean.

## Outputs
Write to outputs/py/ (figures: outputs/figures/). Estimates in long format,
one row per term: lang, spec, model, occ, sample, term, estimate, se, t, p, n_obs.
- spec: author (robustness variants: author_<check>, e.g., author_gov)
- model: base, nounion, or interactions
- sample: period label ("1983-2000", "2001-2025", "1986-1988"); sex-split
  subsamples append "_female" or "_male"
- Each analysis notebook writes its own results file (RESULTS.md from
  03_tables; RESULTS_trends.md; RESULTS_minwage.md) so reruns don't
  overwrite one another.

## Data layout
- data/ipums_data/: IPUMS codebook and microdata. Read via code only.
- data/comparisons/: D&K benchmarks and legacy R outputs. May be read directly.
- data/cpi_annual.csv, data/minimumwage_annual.csv: may be read directly.
- data/README_manifest.csv: role column (input, benchmark, crosscheck, legacy).

## Paper structure
- Body: 2001-2025 only. No D&K comparisons in the body, except the
  incidence figure (annual shares with D&K Table 1 period averages).
- Appendix: 1983-2000 validation against D&K (replication of rows 1-4,
  pooled coefficients, incidence table, sensitivity analyses) and any
  1983-2025 series.

## Open issues (delete each line once resolved)
- DEFERRED: incidence below D&K; excluding local government closely
  matches D&K Table 1. Report the gap; do not change the sample.
- DEFERRED: regression N 1983-2000 is ~1.7x D&K's (hourly-only ~1.4x).
  Possibly allocated earnings; untestable without allocation flags.
- Check the guard penalty by single year, 1999-2005 (2003 code change).
- 05_minwage: trend coefficients are per year but labeled per decade;
  drop the "share absorbed" percentage.
- Guard penalty halves between 2000 (-0.189) and 2001 (-0.090); janitor
  2001 is an outlier. Not the 2003 code change. Checking quarterly
  2000-2002 (CPS 2001 sample expansion vs. post-September 2001).
