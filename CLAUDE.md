# Outsourcing penalty replication

Goal: replicate Dube & Kaplan (2010, ILRR) in Python, extend to 2001–2025, then align the R pipeline (R/) to match.

## Environment
- Conda env `outsourcing`: /Users/kq/opt/anaconda3/envs/outsourcing/bin/python
- Notebooks: notebooks/00_build_data.ipynb (raw extract -> parquet), notebooks/01_clean.ipynb (sample restrictions, recodes)

## Rules
- Never read raw files in data/ directly into the conversation.
- Never overwrite datasets or files: write new filenames; never reassign a dataframe to its own name (dk_raw -> dk_core -> dk_clean).
- R code uses the native pipe |>.

## Sample
- CPS ORG only (extract is ORG-only). AGE >= 16.
- Replication: 1983–2000. Extension: 2001–2025, excluding 2020.
- Occupations: 453 janitors (outsourced if IND1990 722), 426 guards (740) 


## Codes
- HOURWAGE NIU 999.99; EARNWEEK2 NIU 999999.99
- UHRSWORKORG: 998 hours vary, 999 NIU; UHRSWORK1: 997 hours vary, 999 NIU
- METRO: 0 and 9 missing; 4 = central city status unknown

## D&K specification (eq. 1)
- State-by-year FE (STATEFIP^YEAR); cluster by survey month (ym)
- Controls: union (member or covered), part-time (<30 usual hrs), age, age^2,
  female, black, hispanic, MSA, central city, six education
  categories (college omitted)
- No gov_employee control (in R code, not in D&K)

## Decisions not documented in D&K
- Weights: EARNWT
- METRO 4: in MSA, missing for central city

## Verification targets (D&K 2010)
- Table 1 incidence, 1983–85: janitors 0.164, guards 0.401
- Table 3a row 1: outsourced −0.045 (0.005), N = 33,222
- Table 3b row 1: outsourced −0.202 (0.007), N = 11,116
- Report differences from these; don't tune code to hit them.