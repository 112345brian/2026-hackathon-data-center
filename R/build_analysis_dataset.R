# build_analysis_dataset

analysis_dataset <- census_data |>
  left_join(
    im3_by_county |>
      select(fip, data_center, n_data_centers),
    by = c("geoid" = "fip")
  ) |>
  mutate(
    data_center = if_else(is.na(data_center), 0, data_center),
    n_data_centers = if_else(is.na(n_data_centers), 0, n_data_centers)
  ) |>
  left_join(energy_burden_data, by = c("geoid" = "fip")) |>
  left_join(gdp_data, by = "geoid") |>
  left_join(urbanicity_data, by = "geoid") |>
  distinct(geoid, .keep_all = TRUE) |>
  filter(!is.na(ami_energy_burden_all)) |>
  select(-any_of(c("pair_id", "group", "pop_diff", "treated_geoid")))

counties <- analysis_dataset

saveRDS(analysis_dataset, here("data", "output", "analysis_dataset.rds"))
