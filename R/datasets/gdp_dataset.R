# gdp_dataset

gdp_data <- read_csv(here("data", "raw", "CAGDP1__ALL_AREAS_2001_2024.csv"), show_col_types = FALSE) |>
  rename(geoid = "GeoFIPS", yr_2023 = "2023") |>
  select(geoid, Description, yr_2023) |>
  mutate(geoid = str_remove_all(geoid, "'")) |>
  pivot_wider(names_from = "Description", values_from = "yr_2023") |>
  select(-matches("^NA$")) |>
  clean_names() |>
  mutate(geoid = str_pad(geoid, width = 5, pad = "0"))
