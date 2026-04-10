# process_energy_burden_fpl

## give the energy scores
fpl2 <- fpl |>
  filter(hincp_units > 0) |> # remove negative income
  ### bracket-level energy burden
  mutate(energy_burden = (elep_units + gasp_units + fulp_units) / hincp_units,
         energy_burden = if_else(is.infinite(energy_burden) | is.nan(energy_burden), 
                                 NA, 
                                 energy_burden)) |>
  ### county-level aggregated energy burden
  group_by(fip) |>
  mutate(energy_burden_all = sum(elep_units + gasp_units + fulp_units, na.rm = TRUE) / 
           sum(hincp_units, na.rm = TRUE)) |>
  ungroup() |>
  ### poorest households only
  mutate(energy_burden_poor = ifelse(fpl150 == "0-100%", energy_burden, NA))
## give it as counties
fpl3 <- fpl2 |>
  filter(fpl150 == "0-100%") |>
  select(fip, name, state, energy_burden_all, energy_burden_poor)%>%
  rename(energy_burden_all_fpl = energy_burden_all,
        energy_burden_poor_fpl = energy_burden_poor)
