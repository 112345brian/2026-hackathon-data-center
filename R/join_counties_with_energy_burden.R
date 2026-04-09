# join_counties_with_energy_burden

library(here)
library(janitor)
library(tidyverse)

counties_with_datacenters <- counties_with_datacenters |>
  clean_names() |>
  left_join(y = ami, by = c("geoid" = "fip"))
  
