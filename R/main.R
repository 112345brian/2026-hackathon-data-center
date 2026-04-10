# main

## dependencies
if (!requireNamespace("renv", quietly = TRUE)) {
  install.packages("renv")
}

renv::restore(prompt = FALSE)

library(here)
source(here("R", "packages.R"))

## import modules
source(here("R", "import.R")) # make sure you put your census API key in data/private/private_data.R

## process the modules
source(here("R", "process.R"))

## join the data together
source(here("R", "join.R"))

getwd()
write.csv(counties_with_datacenters, "outputdata/counties_with_datacenters.csv")
