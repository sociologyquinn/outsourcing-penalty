# Cleaning rules

Implemented in `notebooks/01_clean.ipynb`. Used by both `refs/dk_spec.md`
and `refs/kq_spec.md`.

## Source
- IPUMS CPS extract: `data/ipums_data/cps_00047.xml` (codebook),
  `data/ipums_data/dk_core.parquet` (microdata, includes HOURWAGE2).

## Base sample
- OCC1990 in {453 janitors, 426 guards}. Apply this filter in 01_clean
  even if dk_core.parquet is already restricted.
- AGE >= 16.
- YEAR 1983-2025, 2020 excluded.
- Weight: EARNWT (nonzero only for outgoing rotation groups, MISH 4 and 8).

## Missing-value sentinels (set to NaN)
- HOURWAGE2: 0, 999.99
- EARNWEEK2: 0, 999999.99
  (0 is treated as missing: a wage/salary worker reporting current
  earnings cannot have a true wage of 0.)
- UHRSWORKORG: 0, 998 (hours vary), 999 (NIU)
- UHRSWORK1: 0, 997 (hours vary), 999 (NIU)
  (0 usual hours carries no information about hours worked.)
- HOURWAGE: not used; HOURWAGE2 replaces it for all years.

## Wages
- hours = UHRSWORKORG; if NaN, UHRSWORK1. Fallback to UHRSWORK1 is an
  analytic choice (not from D&K) to reduce missing hours.
- hourly_wage:
  - PAIDHOUR == 2 and HOURWAGE2 non-missing: HOURWAGE2
  - otherwise, EARNWEEK2 non-missing and hours > 0: EARNWEEK2 / hours
    (includes paid-hourly workers with missing HOURWAGE2)
  - else NaN
  HOURWAGE2 is used for all years: HOURWAGE is not populated from
  April 2023 onward, and HOURWAGE2 applies the post-2023 Census rounding
  and topcoding to all years, so hourly wages are comparable over time.
- log_wage_untrimmed = log(hourly_wage), only where hourly_wage > 0.
- Nominal dollars. No topcode adjustment beyond HOURWAGE2's harmonized
  topcoding. Allocated (imputed) earnings retained; D&K do not document
  their handling.
- real_wage = hourly_wage * (CPI_2025 / CPI_YEAR), using annual average
  CPI-U-RS from `data/cpi_annual.csv` (columns YEAR, AVG). 2025 dollars.
- Trim: wage_trimmed = 1 if hourly_wage < 0.5 x federal minimum in that
  year (STTMINWGFG, `data/minimumwage_annual.csv`) or real_wage > 100.
  Janitors and guards are FLSA-covered; values outside this range are
  treated as measurement error. Rows are kept; incidence does not use wages.
  - log_wage: log_wage_untrimmed, NaN where wage_trimmed. Used in all
    regressions. Deflating by annual CPI is absorbed by STATEFIP^YEAR FE,
    so regressions use nominal wages.
  - log_wage_untrimmed: robustness only.
  - real_wage_trimmed: real_wage, NaN where wage_trimmed. Used in
    summary statistics.

## Outsourcing
- outsourced = 1 if (OCC1990 == 453 and IND1990 == 722)
  or (OCC1990 == 426 and IND1990 == 740); else 0.

## Covariates
- union = 1 if UNION in {2, 3} (member or covered); 0 if UNION == 1; NaN if 0.
- parttime = 1 if hours < 35; 0 if hours >= 35; NaN if hours is NaN.
  Uses the combined hours variable (same as the wage denominator).
  Threshold follows the BLS definition of part-time work.
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
- occupation = "janitor" if OCC1990 == 453; "guard" if 426 (label only).

## Clustering and FE identifiers
- ym = YEAR * 100 + MONTH (survey month; cluster variable).
- STATEFIP, YEAR (combined as STATEFIP^YEAR fixed effects).

## Analysis samples
- Incidence: base sample, no wage restriction. EARNWT weighting
  effectively restricts to ORG respondents. Report N as count of
  EARNWT > 0 rows.
- Regression: base sample with non-missing log_wage and every covariate
  in the given spec. dk and kq use the same rows (gov_employee has no NaNs).
- replication_sample: YEAR 1983-2000.
- extension_sample: YEAR >= 2001.

## Output
- 01_clean writes `outputs/py/dk_clean_v2.parquet`: all base-sample rows,
  all constructed variables. Downstream notebooks load this file and
  do not re-clean.