# urbanicity_dataset

urbanicity_data <- read_csv(here("data", "raw", "Ruralurbancontinuumcodes2023.csv"), show_col_types = FALSE) |>
  pivot_wider(names_from = "Attribute", values_from = "Value") |>
  rename(geoid = "FIPS", metro_description = "Description") |>
  mutate(geoid = str_pad(as.character(geoid), width = 5, pad = "0")) |>
  select(geoid, rucc_2023 = RUCC_2023, metro_description)
