# kq specification

Inherits everything in `refs/dk_spec.md` row 1 (samples, period bins,
covariates, urbanicity coding, fixed effects, weights, clustering,
incidence) and all variable definitions in `refs/cleaning.md`,
except where listed below. D&K rows 2-4 are validation only and are
not part of kq.

## Deviation from D&K
- Adds gov_employee (definition in `refs/cleaning.md`). Restricts the
  regression sample to wage/salary workers.
  Reason: public-sector janitors and guards have different wage structures
  from private ones. Outsourced workers are all private, so without this
  control the outsourcing coefficient partly reflects public-private wage
  differences. With it, the penalty compares outsourced workers to in-house
  private-sector workers.
- Everything else identical to D&K.

## Wage regression
pyfixest.feols(
  "log_wage ~ outsourced + union + parttime + educ_cat + female + black
   + hispanic + age + age2 + msa + central_city + cc_unknown
   + geo_unidentified + gov_employee | STATEFIP^YEAR",
  weights="EARNWT", vcov={"CRV1": "ym"})

## Models
- base: full covariate set above.
- nounion: base minus union (used for mediation only).

## Union mediation (not in D&K)
For each occupation and sample:
  mediated_penalty = (u_inhouse - u_outsourced) * beta_union   [from base]
  pct_explained    = mediated_penalty / |beta_outsourced|      [from nounion]
- Estimation sample is fixed by the base model: base, nounion, and union
  rates all use the same rows (non-missing on every base covariate,
  including union).
- Union rates are EARNWT-weighted means within that sample.
- Descriptive decomposition, not causal.

## Summary statistics (2001-2025)
Weighted means by outsourcing status within 5-year bins
(2001-05, 06-10, 11-15, 2016-19, 2021-25).
- Variables: real_wage, union, parttime, age, female, black, hispanic,
  educ_cat levels, gov_employee.
- SE of mean = sqrt(weighted variance / n_eff).
- diff = outsourced - in-house; se_diff = sqrt(se_in^2 + se_out^2).