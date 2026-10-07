# Author's specification

The author's model is D&K's eq. 1 (`refs/dk_spec.md`, row 1), estimated
with the cleaning in `refs/cleaning.md`, on 1983-2000 (replication) and
2001-2025 (extension). Departures from D&K are construction choices
only, mostly where D&K do not document their approach.

## Model
pyfixest.feols(
  "log_wage ~ outsourced + union + parttime + educ_cat + female + black
   + hispanic + age + age2 + msa + central_city + cc_unknown
   + geo_unidentified | STATEFIP^YEAR",
  weights="EARNWT", vcov={"CRV1": "ym"})
- Coefficient on outsourced = wage penalty in log points.
- Estimated separately for janitors and guards.
- model values: base (above); nounion (base minus union, mediation
  only); interactions (base plus union_x_outsourced and
  parttime_x_outsourced, D&K row 4).

## Construction choices (D&K do not document these)
- Wages: HOURWAGE2 for all years; hours fallback to UHRSWORK1; 0 treated
  as missing; trimming below half the federal minimum or above $100
  (2025 dollars).
- Weights: EARNWT.
- Missing geography kept via cc_unknown and geo_unidentified indicators
  (identical to D&K's two dummies on complete cases).
- Race/ethnicity coded as black and hispanic.
- Allocated earnings retained.

## Samples
- Pooled 1983-2000 (replication; compared to D&K benchmarks).
- Pooled 2001-2025 (extension).
- By period: 1983-85, 86-88, 89-91, 92-94, 95-97, 98-2000, 2001-03,
  04-06, 07-09, 10-12, 13-15, 2016-19, 2021-25 (2020 excluded).
- Single years 1999-2005 (check for the 2003 Census code change).
- Same fixed effects in every sample. Rows 2-4 for 1983-2000 only.

## Union mediation
Samples: 5-year bins 1983-1987, 1988-1992, 1993-1997, 1998-2000,
2001-2005, 2006-2010, 2011-2015, 2016-2019, 2021-2025 (2020 excluded).
1998-2000 and 2016-2019 are shorter bins (3 and 4 years).

For each occupation and bin:
  gap              = u_inhouse - u_outsourced
  mediated_penalty = gap * beta_union                               [base]
  se(mediated_penalty) ~= sqrt(beta_union^2 * var(gap)
                                + gap^2 * var(beta_union))           [delta method]
  pct_explained    = mediated_penalty / |beta_outsourced|            [nounion]
- Base, nounion, and union rates use identical rows (non-missing on
  every base covariate).
- Union rates: EARNWT-weighted means within that bin; SE from the same
  weighted-share formula as incidence (Kish effective N).
- var(gap) = se(u_inhouse)^2 + se(u_outsourced)^2 (independent samples).
- var(beta_union) = the clustered SE of the union coefficient, squared.
- Descriptive decomposition, not causal. Report mediated_penalty in log
  points alongside its SE and pct_explained.

## Union premium by outsourcing status (interactions model)
- Same 5-year bins. Estimate the interactions model (D&K row 4: base
  plus union_x_outsourced and parttime_x_outsourced) for each occupation
  and bin.
- Report outsourced, union, and union_x_outsourced, with SEs.
- Descriptive: a negative union_x_outsourced coefficient means a
  smaller estimated union wage premium for outsourced workers in that
  bin, not a causal claim.

## Trend tests (04_trends)
- By-period estimates use disjoint survey months, so they are
  independent.
- Homogeneity Q test; inverse-variance weighted linear trend on period
  midpoints, reported per decade, with SEs scaled by
  sqrt(max(1, Q_resid / df_resid)).
- Pre-specified contrasts only: 1983-85 vs. 2021-25; 1998-2000 vs.
  2001-03; 2001-03 vs. 2021-25; guards 2013-15 vs. 2021-25.
- Model-based check: pooled 2001-2025 with outsourced x period and
  outsourced x linear year.

## Minimum wage extension (05_minwage)
- binding_mw = max(state, federal), Jan 1 values, from
  `data/minimumwage_annual.csv`; states with no state rate use federal.
  log_mw in nominal dollars.
- Mechanism: EARNWT-weighted share earning below 1.1 x binding_mw, by
  outsourcing status and period.
- Interaction: base model plus outsourced:log_mw, FE STATEFIP^YEAR +
  outsourced^STATEFIP + outsourced^YEAR. SEs clustered by survey month;
  state-clustered SEs as robustness.
- Leads: add outsourced:log_mw at t+1 and t+2; joint test on leads.
- Trend comparison: replace outsourced^YEAR with outsourced x year
  (centered at 2001); report the trend per decade with and without
  outsourced:log_mw, with SEs. Do not report a percentage absorbed.
- Bite not computed (extract has only janitors and guards).

## Summary statistics (Tables 1-2, 2001-2025)
- Regression sample; EARNWT-weighted means by outsourcing status, 5-year
  bins (2001-05, 06-10, 11-15, 2016-19, 2021-25).
- Variables: real_wage_trimmed, union, parttime, gov_employee, age,
  female, black, hispanic, education collapsed to four categories.
- Unweighted N (regression sample) and workers represented (sum EARNWT
  over distinct survey months, base sample, thousands).

## Robustness checks
- parttime35 instead of parttime.
- Add gov_employee (moved the 1983-2000 guard penalty from -0.222 to
  -0.191; janitors unchanged).
- Untrimmed wages (log_wage_untrimmed).
- Unweighted.
- Complete cases on geography (drop METRO 0, 4, 9; drop cc_unknown and
  geo_unidentified).
- Hourly-paid only (PAIDHOUR == 2). Salaried share is 23% of in-house vs.
  12% of outsourced guards (janitors 18% vs. 15%); expect a smaller
  guard penalty.
- Excluding local government (CLASSWKR 28).
- Metro-by-year FE (extension): requires a new extract with a metro area
  identifier (METAREA or METFIPS); not currently feasible.