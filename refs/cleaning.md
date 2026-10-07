# Cleaning rules

Implemented in `notebooks/01_clean.ipynb`. Used by `refs/dk_spec.md` and
`refs/author_spec.md`.

## Source
- IPUMS CPS extract: `data/ipums_data/cps_00047.xml` (codebook),
  `data/ipums_data/dk_core.parquet` (microdata, includes HOURWAGE2).

## Base sample
- OCC1990 in {453 janitors, 426 guards}. Apply this filter in 01_clean
  even if dk_core.parquet is already restricted.
- AGE >= 16.
- YEAR 1983-2025, 2020 excluded.
- Weight: EARNWT (nonzero only for outgoing rotation groups, MISH 4 and 8).
- All rows are wage/salary workers (CLASSWKR 21-28); ORG earnings are
  not collected for the self-employed.

## Missing-value sentinels (set to NaN)
- HOURWAGE2: 0, 999.99
- EARNWEEK2: 0, 999999.99
  (0 is missing: a wage/salary worker reporting current earnings cannot
  have a true wage of 0.)
- UHRSWORKORG: 0, 998 (hours vary), 999 (NIU)
- UHRSWORK1: 0, 997 (hours vary), 999 (NIU)
- HOURWAGE: not used; HOURWAGE2 replaces it for all years.

## Wages
- hours = UHRSWORKORG; if NaN, UHRSWORK1 (analytic choice; not from D&K).
- hourly_wage:
  - PAIDHOUR == 2 and HOURWAGE2 non-missing: HOURWAGE2
  - otherwise, EARNWEEK2 non-missing and hours > 0: EARNWEEK2 / hours
  - else NaN
  HOURWAGE2 is used for all years: HOURWAGE is not populated from
  April 2023 onward, and HOURWAGE2 applies the post-2023 Census rounding
  and topcoding to all years, so wages are comparable over time.
- log_wage_untrimmed = log(hourly_wage), where hourly_wage > 0.
- Nominal dollars. No topcode adjustment beyond HOURWAGE2's harmonized
  topcoding. Allocated (imputed) earnings retained.
- real_wage = hourly_wage * (CPI_2025 / CPI_YEAR), annual average
  CPI-U-RS from `data/cpi_annual.csv` (columns YEAR, AVG). 2025 dollars.
- Trim: wage_trimmed = 1 if hourly_wage < 0.5 x federal minimum in that
  year (STTMINWGFG, `data/minimumwage_annual.csv`) or real_wage > 100.
  Rows are kept; incidence does not use wages.
  - log_wage: log_wage_untrimmed, NaN where wage_trimmed. Used in all
    regressions (nominal; annual CPI is absorbed by STATEFIP^YEAR FE).
  - log_wage_untrimmed: robustness only.
  - real_wage_trimmed: used in summary statistics.

## Outsourcing
- outsourced = 1 if (OCC1990 == 453 and IND1990 == 722)
  or (OCC1990 == 426 and IND1990 == 740); else 0.

## Covariates
- union = 1 if UNION in {2, 3} (member or covered); 0 if UNION == 1; NaN if 0.
- parttime = 1 if hours < 30; 0 if hours >= 30; NaN if hours is NaN.
  D&K's documented definition (usual hours under 30).
- parttime35 = same with a 35-hour threshold (BLS definition).
  Robustness only.
- age = AGE; age2 = AGE^2.
- female = 1 if SEX == 2 (male = reference).
- hispanic = 1 if HISPAN in 100-612; 0 if HISPAN == 0; NaN if 901/902.
- black = 1 if RACE == 200 and hispanic == 0; 0 if RACE != 200 or
  hispanic == 1; NaN if hispanic is NaN. RACE 200 is single-race Black.
- educ_cat (pandas Categorical, college = first level/reference), from EDUC:
  - no_school: 2
  - primary: 10-14, 20-22, 30-32
  - hs_attend: 40, 50, 60, 70, 71, 72
  - hs_complete: 73
  - some_college: 80, 81, 90, 91, 92, 100
  - college: 110-125
  - NaN: 0, 1 (NIU), 999
- Urbanicity (all 0/1, never NaN; reference = nonmetro, METRO 1):
  - msa = 1 if METRO in {2, 3, 4}; else 0
  - central_city = 1 if METRO == 2; else 0
  - cc_unknown = 1 if METRO == 4; else 0
  - geo_unidentified = 1 if METRO in {0, 9}; else 0
- gov_employee = 1 if CLASSWKR in {24, 25, 27, 28}; 0 if in {21, 22, 23}.
  Descriptive statistics and robustness only; not in the main model.
- union_x_outsourced = union * outsourced;
  parttime_x_outsourced = parttime * outsourced (D&K row 4 only).
- occupation = "janitor" if OCC1990 == 453; "guard" if 426 (label only).

## Identifiers
- ym = YEAR * 100 + MONTH (survey month; cluster variable).
- STATEFIP, YEAR (combined as STATEFIP^YEAR fixed effects).

## Analysis samples
- Incidence: base sample, no wage restriction. Report N as count of
  EARNWT > 0 rows.
- Regression: base sample with non-missing log_wage and every covariate
  in the model, after pyfixest drops singleton fixed effects. Report
  post-drop N.

## Output
- 01_clean writes `outputs/py/dk_clean.parquet`: all base-sample rows,
  all constructed variables. Later notebooks load it and do not re-clean.