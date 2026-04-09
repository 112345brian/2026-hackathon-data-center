# join_ami_to_fpl

library(tidyverse)

energy_burden <- ami |>
  full_join(y = fpl, by = "fip")