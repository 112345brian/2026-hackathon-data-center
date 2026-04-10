# main

## dependencies
if (!requireNamespace("renv", quietly = TRUE)) {
  install.packages("renv")
}

renv::restore(prompt = FALSE)

library(here)
source(here("R", "packages.R"))

## create individual datasets
source(here("R", "datasets", "im3_dataset.R"))
source(here("R", "datasets", "census_dataset.R"))
source(here("R", "datasets", "energy_burden_dataset.R"))
source(here("R", "datasets", "gdp_dataset.R"))
source(here("R", "datasets", "urbanicity_dataset.R"))

## assemble the analysis dataset
source(here("R", "build_analysis_dataset.R"))
