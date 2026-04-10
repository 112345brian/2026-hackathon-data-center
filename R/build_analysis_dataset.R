# build_analysis_dataset

analysis_base <- census_data |>
  left_join(
    im3_by_county |>
      select(fip, data_center, n_data_centers),
    by = c("geoid" = "fip")
  ) |>
  mutate(
    data_center = if_else(is.na(data_center), 0, data_center),
    n_data_centers = if_else(is.na(n_data_centers), 0, n_data_centers)
  )

treated <- analysis_base |>
  filter(data_center == 1)

control_pool <- analysis_base |>
  filter(data_center == 0)

matched_controls <- treated |>
  mutate(treated_geoid = geoid) |>
  rowwise() |>
  do({
    t <- .
    t_state <- substr(t$geoid, 1, 2)

    control_pool |>
      filter(substr(geoid, 1, 2) == t_state) |>
      mutate(
        pop_diff = abs(population - t$population),
        treated_geoid = t$geoid
      ) |>
      arrange(pop_diff) |>
      slice_head(n = 1)
  }) |>
  ungroup()

matched_counties <- bind_rows(
  treated |>
    mutate(pair_id = geoid, group = "treated"),
  matched_controls |>
    mutate(pair_id = treated_geoid, group = "control")
)

counties_with_datacenters <- matched_counties

analysis_dataset <- matched_counties |>
  left_join(energy_burden_data, by = c("geoid" = "fip")) |>
  left_join(gdp_data, by = "geoid") |>
  left_join(urbanicity_data, by = "geoid") |>
  filter(!is.na(ami_energy_burden_all))

counties <- analysis_dataset

saveRDS(analysis_dataset, here("data", "output", "analysis_dataset.rds"))
saveRDS(analysis_dataset, here("data", "output", "analysis.rds"))
saveRDS(counties_with_datacenters, here("data", "output", "matched_counties.rds"))
