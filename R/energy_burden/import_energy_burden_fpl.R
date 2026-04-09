# import_energy_burden_fpl

library(here)
library(janitor)
library(tidyverse)

fpl_files <- list.files(here("data", "raw", "energy_burden", "counties", "FPL"), full.names = TRUE)
fpl <- map(fpl_files, function(f) {
  read_csv(f, show_col_types = FALSE) |>
    clean_names() |>
    select(fip, name, state, fpl150, hincp_units, elep_units, gasp_units, fulp_units) |>
    mutate(fip = str_pad(as.character(fip), width = 5, pad = "0")) |>
    group_by(fip, name, state, fpl150) |>
    summarise(
      hincp_units = sum(hincp_units, na.rm = TRUE),
      elep_units = sum(elep_units, na.rm = TRUE),
      gasp_units = sum(gasp_units, na.rm = TRUE),
      fulp_units = sum(fulp_units, na.rm = TRUE),
      .groups = "drop"
    )
}) |> list_rbind()