# Outsourcing penalty replication

Goal: replicate Dube & Kaplan (2010, ILRR) in Python, extend to 2001-2025,
then align the R pipeline (R/) to match.

Source paper: refs/dube_kaplan_2010.pdf. Specification and verification
targets come from here.

## Environment
- Conda env `outsourcing`: /Users/kq/opt/anaconda3/envs/outsourcing/bin/python
- Notebooks: notebooks/00_build_data.ipynb (raw extract -> parquet),
  notebooks/01_clean.ipynb (sample restrictions, recodes)

## Rules
- Never read raw files in data/ directly into the conversation.
- Never overwrite datasets or files: write new filenames; never reassign
  a dataframe to its own name (dk_raw -> dk_core -> dk_clean).
- R code uses the native pipe |>.

## Sample
- CPS ORG only (extract is ORG-only). AGE >= 16.
- Replication: 1983-2000. Extension: 2001-2025, excluding 2020.
- Occupations: 453 janitors (outsourced if IND1990 722), 426 guards (740),
  313 clerical (row 6 control group only; coded by 722 when pooled with
  janitors, 740 when pooled with guards).

## Codes
- HOURWAGE NIU 999.99; EARNWEEK2 NIU 999999.99
- UHRSWORKORG: 998 hours vary, 999 NIU; UHRSWORK1: 997 hours vary, 999 NIU
- METRO: 0 and 9 missing; 4 = central city status unknown

## D&K specification (eq. 1)
- State-by-year FE (STATEFIP^YEAR); cluster by survey month (ym)
- Controls: union (member or covered), part-time (<30 usual hrs), age,
  age^2, female, black, hispanic, urbanicity (categorical, see Decisions),
  six education categories (college omitted)
- No gov_employee control (in R code, not in D&K)

## Decisions not documented in D&K
- Weights: EARNWT. D&K don't state weighting.
- Urbanicity: METRO 1 nonmetro (omitted), 2 metro_cc, 3 metro_not_cc,
  4 metro_cc_unknown, 0/9 not_identified. On complete cases, metro_not_cc
  and metro_cc reproduce D&K's MSA and central city dummies. Missing
  categories kept, not dropped. Reason: geography is missing for 15-20% of
  workers in every occupation and period, missingness is 2-5 pts higher
  for in-house workers, and the raw outsourcing gap is largest in
  not_identified, so complete cases would likely understate the penalty.
- Hourly wage: HOURWAGE if PAIDHOUR==2 and HOURWAGE < 999.99, else
  EARNWEEK2 / hours, with EARNWEEK2 < 999999.99. Hours = UHRSWORKORG in
  1-99 (0, 998, 999 missing). See Open issues on the UHRSWORK1 fallback.
- Black: RACE==200 (single race only; excludes multiracial Black in 2003+
  coding). See Open issues on Hispanic exclusion.
- Hispanic: 1 if HISPAN 100-612; 0 if HISPAN 0; missing if 901/902.
- Education (college omitted), from IPUMS EDUC codes: no schooling {2};
  primary {10-14, 20-22, 30-32}; HS attendance {40, 50, 60, 71, 72};
  HS completion {73}; some college {80, 81, 90-92, 100};
  college {110, 111, 120-125}. EDUC 0, 1 (NIU or blank) and 999 missing.

## Verification targets (D&K 2010)
- Table 1 incidence, 1983-85: janitors 0.164, guards 0.401
- Table 3a row 1: outsourced -0.045 (0.005), N = 33,222
- Table 3b row 1: outsourced -0.202 (0.007), N = 11,116
- Report differences from these; don't tune code to hit them.

## Robustness checks (planned)
- Complete cases on urbanicity (expect a somewhat smaller penalty)
- Unweighted vs EARNWT-weighted
- Extension: metro-by-year FE (city minimum wages concentrate in central
  cities, where outsourced workers are overrepresented)

## Open issues (delete each line once resolved)
- UHRSWORK1 fallback when UHRSWORKORG is missing: added by Claude Code,
  not in the R code. Decide whether to keep; update the wage rule above.
- Black: confirm whether the notebook excludes Hispanics, and make the
  Decisions line match the code.
- EDUC 70 (grade 12): confirm it doesn't occur in the data; if it does,
  it's currently falling out as missing.
- 1983-85 incidence: janitors 0.13 vs D&K 0.164; guards 0.37 vs 0.401.
  Compare against R compute_incidence() before looking elsewhere.