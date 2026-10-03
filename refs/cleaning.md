# Cleaning rules

Implemented in `notebooks/01_clean.ipynb`. Used by both `refs/dk_spec.md`
and `refs/kq_spec.md`.

## Source
- IPUMS CPS extract: `data/ipums_data/cps_00047.xml` (codebook),
  `data/ipums_data/dk_core.parquet` (microdata).

## Base sample
- OCC1990 in {453 janitors, 426 guards}. Apply this filter in 01_clean
  even if dk_core.parquet is already restricted.
- AGE >= 16.
- YEAR 1983-2025, 2020 excluded.
- Weight: EARNWT (nonzero only for outgoing rotation groups, MISH 4 and 8).

## Missing-value sentinels (set to NaN)
- HOURWAGE: 999.99
- EARNWEEK2: 999999.99
- UHRSWORKORG: 0, 998 (hours vary), 999 (NIU)
- UHRSWORK1: 997 (hours vary), 999 (NIU)

## Wages
- hours = UHRSWORKORG; if NaN, UHRSWORK1. Fallback to UHRSWORK1 is a
  replication choice, not from D&K.
- hourly_wage:
  - PAIDHOUR == 2 and HOURWAGE non-missing: HOURWAGE
  - otherwise, EARNWEEK2 non-missing and hours > 0: EARNWEEK2 / hours
    (includes paid-hourly workers with missing HOURWAGE)
  - else NaN
- log_wage = log(hourly_wage), only where hourly_wage > 0.
- Nominal dollars. No topcode adjustment, no trimming.
  Allocated (imputed) earnings retained; D&K do not document their handling.
- real_wage = hourly_wage * (CPI_2025 / CPI_YEAR), using annual average
  CPI-U-RS from `data/cpi_annual.csv` (columns YEAR, AVG). 2025 dollars.
  Used for summary statistics only. Regressions use nominal log_wage;
  deflating by annual CPI is absorbed by STATEFIP^YEAR FE.

## Outsourcing
- outsourced = 1 if (OCC1990 == 453 and IND1990 == 722)
  or (OCC1990 == 426 and IND1990 == 740); else 0.

## Covariates
- union = 1 if UNION in {2, 3} (member or covered); 0 if UNION == 1; NaN if 0.
- parttime = 1 if UHRSWORK1 < 30; 0 if >= 30; NaN if missing.
  Check: report the count of UHRSWORK1 == 0. If nonzero, stop and ask.
- age = AGE; age2 = AGE^2.
- female = 1 if SEX == 2 (male = reference).
- hispanic = 1 if HISPAN in 100-612; 0 if HISPAN == 0; NaN if 901/902.
- black = 1 if RACE == 200 and hispanic == 0; 0 if RACE != 200 or
  hispanic == 1; NaN if hispanic is NaN. RACE 200 is single-race Black
  (excludes multiracial Black in 2003+ coding).
- educ_cat (pandas Categorical, college = first level/reference), from EDUC:
  - no_school: 2
  - primary: 10-14, 20-22, 30-32
  - hs_attend: 40, 50, 60, 70, 71, 72
  - hs_complete: 73
  - some_college: 80, 81, 90, 91, 92, 100
  - college: 110-125
  - NaN: 0, 1 (NIU), 999
- Urbanicity (all four are 0/1, never NaN; reference = nonmetro, METRO 1):
  - msa = 1 if METRO in {2, 3, 4}; else 0
  - central_city = 1 if METRO == 2; else 0
  - cc_unknown = 1 if METRO == 4 (in MSA, central city status unknown); else 0
  - geo_unidentified = 1 if METRO in {0, 9}; else 0
- gov_employee = 1 if CLASSWKR in {24, 25, 27, 28}; 0 if in {21, 22, 23};
  NaN otherwise. Used in kq spec only.
- union_x_outsourced = union * outsourced;
  parttime_x_outsourced = parttime * outsourced (D&K row 4 only).

## Clustering and FE identifiers
- ym = YEAR * 100 + MONTH (survey month; cluster variable).
- STATEFIP, YEAR (combined as STATEFIP^YEAR fixed effects).

## Analysis samples
- Incidence: base sample, no wage restriction. EARNWT weighting
  effectively restricts to ORG respondents. Report N as count of
  EARNWT > 0 rows.
- Regression: base sample with non-missing log_wage and every covariate
  in the given spec. kq drops more rows than dk (gov_employee NaN).
- For dk vs kq comparisons, also estimate dk on the kq sample, so
  differences reflect covariates rather than sample.
- replication_sample: YEAR 1983-2000.
- extension_sample: YEAR >= 2001.

## Output
- 01_clean writes `outputs/py/dk_clean.parquet`: all base-sample rows,
  all constructed variables. Downstream notebooks load this file and
  do not re-clean.