# join_counties_with_energy_burden

library(here)
library(janitor)
library(tidyverse)

counties <- counties_with_datacenters |>
  left_join(y = ami |> select(-name, -state), by = c("geoid" = "fip"))
  
