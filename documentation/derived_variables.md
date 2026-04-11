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

## Matching + Final Dataset
Script: `R/build_analysis_dataset.R`

1. **`analysis_base`** joins ACS data with IM3 per-county counts. Counties without data centers have `data_center`/`n_data_centers` set to zero.
2. Treated counties (`data_center == 1`) are matched to control counties from the same state with the closest population.
3. The final matched table exposes:
   - **`pair_id`** – The treated county’s `geoid`, assigned to both treated and matched control rows.
   - **`group`** – Categorical flag with the values `"treated"` or `"control"` to identify the matched unit type.
4. The matched frame is saved twice: once as **`counties_with_datacenters`** (for legacy compatibility) and once as **`analysis_dataset`**, which also joins:
   - **`energy_burden_data`** (AMI burden columns).
   - **`gdp_data`** (2023 GDP metrics per BEA description).
   - **`urbanicity_data`** (RUCC code and metro description).
5. The combined output filters to rows where `ami_energy_burden_all` is present and is persisted to `data/output/analysis_dataset.rds` (and the legacy `analysis.rds`).

## Derived Variables Used Only in Analysis

While not stored back to disk, the Quarto regression file (`R/analysis/analysis_regression.qmd`) derives the following controls at render time:

- **`state`** – First two digits of `geoid`, used for fixed effects.
- **`metro`** – Indicator inferred from `metro_description` (`1` if the text contains “metro”, `0` if it contains “nonmetro”).

These derived controls ensure the regression outputs documented in the Quarto report rely on reproducible transformations tied to the master dataset.
