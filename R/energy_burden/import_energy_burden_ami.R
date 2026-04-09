# import_energy_burden_ami

library(here)
library(janitor)
library(tidyverse)

ami_files <- list.files(here("data", "raw", "energy_burden", "counties", "AMI"), full.names = TRUE)
ami <- map(ami_files, function(f) {
  read_csv(f, show_col_types = FALSE) |>
    clean_names() |>
    select(fip, name, state, ami150, hincp_units, elep_units, gasp_units, fulp_units) |>
    group_by(fip, name, state, ami150) |>
    summarise( # the data are in super granular combinations. this aggregates them
      hincp_units = sum(hincp_units, na.rm = TRUE),
      elep_units = sum(elep_units, na.rm = TRUE),
      gasp_units = sum(gasp_units, na.rm = TRUE),
      fulp_units = sum(fulp_units, na.rm = TRUE),
      .groups = "drop"
    )
}) |> list_rbind()
