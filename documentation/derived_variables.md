# Derived Variable Documentation

This document describes each derived feature created by the refactored data pipeline in `R/` and the logic used to compute it. All scripts referenced below are sourced through `R/main.R`.

## IM3 (Data Centers)
Script: `R/datasets/im3_dataset.R`

- **`fip`** – Every facility row receives a 5-digit FIPS code. When the raw file exposes `state_id` + `county_id`, they are concatenated and zero-padded; otherwise the provided `fip` column is padded. Observations in Puerto Rico or the District of Columbia are dropped.
- **`data_center`** – Indicator set to `1` for every facility record. After aggregating, counties without facilities later receive `0`.
- **`n_data_centers`** – Count of IM3 facilities per county (`group_by(fip)` + `n()`).
- **`im3_by_county`** – One record per county containing `fip`, `state`, `county`, `n_data_centers`, and `data_center = 1`. This table feeds the matching logic.

## Census / ACS
Script: `R/datasets/census_dataset.R`

- Pulls 2022 ACS 5-year estimates for demographic, education, housing, and economic variables.
- The **`median_house_age`** variable is derived from `B25035_001` (“Median Year Structure Built”). We convert that median year into “years old” by computing `2022 - median_year_structure_built`, giving the median house age relative to the 2022 reference year.
- The **`median_resident_age`** variable comes directly from ACS table `B01002_001`; it captures the median age of residents in each county.
- All ACS estimates are reshaped to one row per county (`pivot_wider`) and keyed by `geoid` (character).

## Energy Burden (AMI + FPL)
Script: `R/datasets/energy_burden_dataset.R`

Each CSV is read, cleaned, and reduced to county-level totals.

- **`energy_burden`** – For every income bracket: `(elep_units + gasp_units + fulp_units) / hincp_units`, with `Inf`/`NaN` coerced to `NA`.
- **`energy_burden_all`** – County-wide burden computed by summing costs and incomes across brackets before dividing.
- **`energy_burden_poor`** – Burden restricted to the lowest bracket (`AMI 0–30%` or `FPL 0–100%`).
- **`ami_energy_burden_all` / `ami_energy_burden_poor`** – Final columns carried into the master dataset (currently sourced from the AMI files).

## GDP (BEA CAGDP1)
Script: `R/datasets/gdp_dataset.R`

- Loads the BEA county GDP file as Latin-1 text, strips the footnote section, and reads all fields as strings.
- **`value_2023`** – Numeric version of the 2023 column using `parse_number`, treating suppression codes such as `(D)`, `(S)`, `(NM)`, `(C)`, etc., as `NA`.
- The wide pivot maps each BEA description (e.g., “Current-dollar GDP…”) into its own numeric column, all keyed by zero-padded `geoid`.

## Urbanicity
Script: `R/datasets/urbanicity_dataset.R`

- Transforms the USDA Rural–Urban Continuum Code file so each county has:
  - **`rucc_2023`** – Rural/urban code.
  - **`metro_description`** – Text description of the metro/non-metro classification.

## Final Dataset Assembly
Script: `R/build_analysis_dataset.R`

1. **`analysis_dataset`** begins with the ACS table and joins the per-county IM3 counts. Counties without an IM3 record have `data_center` and `n_data_centers` set to zero, so every county appears exactly once.
2. The dataset then left-joins:
   - **`energy_burden_data`** (AMI burden columns, keyed by `fip`).
   - **`gdp_data`** (2023 GDP metrics per BEA description).
   - **`urbanicity_data`** (RUCC code and metro description).
3. After the joins we call `distinct(geoid, .keep_all = TRUE)` so each county appears only once, drop any rows without `ami_energy_burden_all`, and strip legacy matching columns (`pair_id`, `group`, `pop_diff`, `treated_geoid`) so the dataset only contains per-county attributes.
4. The resulting county-level table is saved to `data/output/analysis_dataset.rds` and exposed as the `counties` object for downstream analysis.

## Derived Variables Used Only in Analysis

While not stored back to disk, the Quarto regression file (`R/analysis/analysis_regression.qmd`) derives the following controls at render time:

- **`state`** – First two digits of `geoid`, used for fixed effects.
- **`metro`** – Indicator inferred from `metro_description` (`1` if the text contains “metro”, `0` if it contains “nonmetro”).

These derived controls ensure the regression outputs documented in the Quarto report rely on reproducible transformations tied to the master dataset.
