# D&K (2010) specification

Source: Dube & Kaplan (2010), ILRR: eq. 1 text and Tables 3a/3b notes.
Variable definitions: `refs/cleaning.md`.
Items marked "replication choice" are not specified in the paper.

## Samples
- Base sample and regression sample as defined in `refs/cleaning.md`.
- Estimated separately for janitors (453) and guards (426).
- Pooled 1983-2000 (D&K period; compared to D&K benchmarks).
- Pooled 2001-2025 (extension; compared to kq spec).
- By period: 1983-85, 86-88, 89-91, 92-94, 95-97, 98-2000, 2001-03,
  04-06, 07-09, 10-12, 13-15, 2016-19, 2021-25 (2020 excluded).
- Same fixed effects in every sample, including by period.

## Incidence of outsourcing (D&K Table 1)
- share = sum(EARNWT * outsourced) / sum(EARNWT), by occupation.
- 3-year bins: 1983-85, 86-88, 89-91, 92-94, 95-97, 98-2000.
- Change row: share(1998-2000) - share(1983-85).
- Annual series: same share and SE by YEAR, 1983-2025, 2020 excluded.
- SE (replication choice): binomial with Kish effective N,
  n_eff = (sum EARNWT)^2 / sum(EARNWT^2), se = sqrt(share(1-share)/n_eff);
  se_change = sqrt(se_1^2 + se_2^2).
- Incidence has no covariates, so it is identical for dk and kq.
  Compute once.

## Wage regression (eq. 1; Tables 3a/3b row 1)
pyfixest.feols(
  "log_wage ~ outsourced + union + parttime + educ_cat + female + black
   + hispanic + age + age2 + msa + central_city + cc_unknown
   + geo_unidentified | STATEFIP^YEAR",
  weights="EARNWT", vcov={"CRV1": "ym"})

- Outcome: log nominal hourly wage.
- Education: six categories; college_plus must be the omitted level.
  Confirm in output.
- Race/ethnicity: black, hispanic (replication choice; paper lists
  "race" and "race and ethnicity dummies" without specifying them).
- Urbanicity: D&K's two dummies (msa, central_city) plus indicators for
  METRO 4 (cc_unknown) and METRO 0/9 (geo_unidentified), so workers with
  missing geography are kept (replication choice). On complete cases this
  is identical to D&K's two dummies. Reason: geography is missing for
  15-20% of workers in every occupation and period, missingness is 2-5
  points higher for in-house workers, and the raw outsourcing gap is
  largest among unidentified workers, so complete cases would likely
  understate the penalty.
- Weights: EARNWT (replication choice; paper does not state weighting).
- SEs clustered by survey month (ym), per the paper.
- Coefficient on outsourced = wage penalty in log points.

## Additional D&K rows replicated (1983-2000 only)
- Row 2: row 1 model on women only (drop female).
- Row 3: row 1 model on men only (drop female).
- Row 4: row 1 model plus union_x_outsourced and parttime_x_outsourced.

## Robustness
- Complete cases on urbanicity: drop METRO in {0, 4, 9}; drop
  cc_unknown and geo_unidentified from the model.

## D&K published benchmarks
- Incidence: `data/comparisons/dk_published_incidence.csv` (Table 1).
- Wage regressions: `data/comparisons/dk_published_penalty.csv` (Tables 3a, 3b).
  Compare on outsourced, union, parttime, interactions, n, and r2,
  matching on occ, row, and term.
- Check N first: if the regression sample N differs materially from
  the benchmark, investigate sample construction before comparing
  coefficients.
- Janitor rows 2/3: the paper reports 22,760 "female" vs 10,462 "male."
  Before comparing, compute the weighted female share of the 1983-2000
  janitor sample. If it is near one third, treat the paper's labels as
  swapped and note this in the output.
- These files are the only source of D&K values. Never invent others.
- Report differences; never adjust specification or cleaning to move
  estimates toward D&K values.

## Not replicated
- Row 5 (BEA underlying industry controls)
- Row 6 (inter-occupational differencing with secretaries)
- Rows 7-9 (panel switcher models)