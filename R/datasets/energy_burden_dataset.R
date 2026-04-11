# energy_burden_dataset

ami_files <- list.files(here("data", "raw", "energy_burden", "counties", "AMI"), full.names = TRUE)
ami_data <- map(ami_files, function(f) {
  read_csv(f, show_col_types = FALSE) |>
    clean_names() |>
    select(fip, name, state, ami150, hincp_units, elep_units, gasp_units, fulp_units) |>
    mutate(fip = str_pad(as.character(fip), width = 5, pad = "0")) |>
    group_by(fip, name, state, ami150) |>
    summarise(
      hincp_units = sum(hincp_units, na.rm = TRUE),
      elep_units = sum(elep_units, na.rm = TRUE),
      gasp_units = sum(gasp_units, na.rm = TRUE),
      fulp_units = sum(fulp_units, na.rm = TRUE),
      .groups = "drop"
    )
}) |> list_rbind()

ami_energy <- ami_data |>
  filter(hincp_units > 0) |>
  mutate(
    energy_burden = (elep_units + gasp_units + fulp_units) / hincp_units,
    energy_burden = if_else(is.infinite(energy_burden) | is.nan(energy_burden), NA_real_, energy_burden)
  ) |>
  group_by(fip) |>
  mutate(
    energy_burden_all = sum(elep_units + gasp_units + fulp_units, na.rm = TRUE) /
      sum(hincp_units, na.rm = TRUE)
  ) |>
  ungroup() |>
  mutate(energy_burden_poor = if_else(ami150 == "0-30%", energy_burden, NA_real_))

ami_energy_by_county <- ami_energy |>
  filter(ami150 == "0-30%") |>
  select(fip, name, state, energy_burden_all, energy_burden_poor) |>
  distinct(fip, .keep_all = TRUE)

fpl_files <- list.files(here("data", "raw", "energy_burden", "counties", "FPL"), full.names = TRUE)
fpl_data <- map(fpl_files, function(f) {
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

fpl_energy <- fpl_data |>
  filter(hincp_units > 0) |>
  mutate(
    energy_burden = (elep_units + gasp_units + fulp_units) / hincp_units,
    energy_burden = if_else(is.infinite(energy_burden) | is.nan(energy_burden), NA_real_, energy_burden)
  ) |>
  group_by(fip) |>
  mutate(
    energy_burden_all = sum(elep_units + gasp_units + fulp_units, na.rm = TRUE) /
      sum(hincp_units, na.rm = TRUE)
  ) |>
  ungroup() |>
  mutate(energy_burden_poor = if_else(fpl150 == "0-100%", energy_burden, NA_real_)) |>
  filter(fpl150 == "0-100%") |>
  select(fip, name, state, energy_burden_all, energy_burden_poor)

energy_burden_data <- ami_energy_by_county |>
  transmute(
    fip,
    ami_energy_burden_all = energy_burden_all,
    ami_energy_burden_poor = energy_burden_poor
  )
