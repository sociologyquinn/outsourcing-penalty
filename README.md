# Outsourcing Wage Penalty: Janitors and Security Guards, 1983-2025

Replication and extension of Dube and Kaplan (2010), "Does Outsourcing
Reduce Wages in the Low-Wage Service Occupations? Evidence from Janitors
and Guards," *ILR Review* 63(2). Estimates the wage penalty for outsourced
janitors and security guards using the CPS Outgoing Rotation Groups,
replicating D&K's 1983-2000 results and extending the analysis through 2025.

## Data
Microdata are not included in this repository. The analysis uses an IPUMS
CPS extract (basic monthly samples, 1983-2025) with these variables:
YEAR, MONTH, OCC1990, IND1990, CLASSWKR, EARNWT, MISH, PAIDHOUR, HOURWAGE,
HOURWAGE2, EARNWEEK2, UHRSWORKORG, UHRSWORK1, UNION, SEX, HISPAN, RACE,
EDUC, AGE, STATEFIP, METRO, EMPSTAT.

To reproduce, request the extract from https://cps.ipums.org and place the
`.dat.gz` and `.xml` files in `data/ipums_data/`.

Also used: annual CPI-U-RS (`data/cpi_annual.csv`) and FRED state minimum
wages (`data/minimumwage_annual.csv`).

## Structure
- `notebooks/00_build_data.ipynb`: reads the IPUMS extract, keeps janitors
  and guards
- `notebooks/01_clean.ipynb`: sample restrictions and variable construction
- `notebooks/02_estimates.ipynb`: incidence, D&K validation, wage penalties,
  union mediation
- `notebooks/03_tables.ipynb`: publication tables
- `refs/`: specifications (cleaning rules, D&K model, extended model)
- `outputs/tables/`: tables (HTML, LaTeX, CSV)
- `data/comparisons/`: D&K published values and earlier replication output

## Citation
Data: Sarah Flood, Miriam King, Renae Rodgers, Steven Ruggles, J. Robert Warren, Daniel Backman, Etienne Breton, Grace Cooper, Julia A. Rivera Drew, Stephanie Richards, David Van Riper, and Kari C.W. Williams. IPUMS CPS: Version 13.0 [dataset]. Minneapolis, MN: IPUMS, 2025. https://doi.org/10.18128/D030.V13.0