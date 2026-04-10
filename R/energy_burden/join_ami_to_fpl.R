`# join_ami_to_fpl

library(tidyverse)

energy_burden <- ami3 |>
  full_join(y = fpl3, by = "fip")
