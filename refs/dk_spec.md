# Dube and Kaplan (2010) specification

What D&K report, from the paper (ILRR 63(2): 287-306): eq. 1 text,
Tables 1-3, and table notes. Variable definitions: `refs/cleaning.md`.
Items marked "not documented" are not stated in the paper; how the
author handles them is in `refs/author_spec.md`.

## Sample
- CPS ORG, 1983-2000. Janitors (OCC 453), guards (OCC 426).
- Outsourced: janitors in industry 722, guards in industry 740.
- Not documented: age limits, class of worker, hourly vs. salaried,
  wage construction, topcoding, trimming, allocated earnings, weights.

## Incidence (Table 1)
- Share outsourced by occupation, 3-year bins 1983-85 to 1998-2000,
  plus change from 1983-85 to 1998-2000. SE method not documented.

## Wage regression (eq. 1; Tables 3a-3b, row 1)
log wage on: outsourced, union (member or covered), part-time (usual
hours < 30), age, age squared, race, sex, six education categories
(college omitted), MSA and central city dummies, state x year effects.
SEs clustered by survey month.
- Rows 2-3: row 1 by sex. Row 4: adds outsourced x union and
  outsourced x part-time.
- Not replicated: row 5 (BEA industry controls), row 6 (inter-
  occupational differencing), rows 7-9 (panel switchers).

## Benchmarks
- Incidence: `data/comparisons/dk_published_incidence.csv`.
- Wage regressions: `data/comparisons/dk_published_penalty.csv`
  (Tables 3a-3b, all rows, transcribed). Compare on occ, row, term.
- These files are the only source of D&K values. Never invent others.

## Known inconsistencies in the paper
- Janitor sex composition: Table 3a row N's imply 69% female; Table 2
  implies about 54%; the CPS ORG shows about 31%. Guards are consistent
  (about 17%). Do not pair the author's sex-split janitor estimates with
  specific D&K rows; report them alongside D&K's without matching labels.