# gdp_dataset

gdp_raw <- read_csv(
  here("data", "raw", "CAGDP1__ALL_AREAS_2001_2024.csv"),
  col_types = cols(.default = col_character()),
  progress = FALSE,
  show_col_types = FALSE
)

gdp_data <- gdp_raw |>
  transmute(
    geoid = str_pad(str_remove_all(GeoFIPS, "'"), width = 5, pad = "0"),
    Description,
    value_2023 = as.numeric(`2023`)
  ) |>
  pivot_wider(names_from = Description, values_from = value_2023) |>
  clean_names()
