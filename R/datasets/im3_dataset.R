# im3_dataset

# convert IM3 raw data into a per-county summary table
imp3_path <- here("data", "raw", "im3.rds")
imp3_csv  <- here("data", "raw", "im3_open_source_data_center_atlas.csv")

if (file.exists(imp3_path)) {
  im3_facilities <- readRDS(imp3_path)
} else {
  im3_facilities <- read_csv(imp3_csv, show_col_types = FALSE)
  saveRDS(im3_facilities, imp3_path)
}

im3_facilities <- im3_facilities |>
  clean_names() |>
  mutate(
    fip = if ("state_id" %in% names(.)) {
      str_pad(paste0(state_id, county_id), width = 5, pad = "0")
    } else {
      fip
    },
    data_center = 1
  ) |>
  filter(!state %in% c("Puerto Rico", "District of Columbia"),
         !state_abb %in% c("PR", "DC"))

im3_by_county <- im3_facilities |>
  group_by(fip) |>
  summarise(
    n_data_centers = n(),
    data_center = 1,
    state = first(state),
    county = first(county),
    .groups = "drop"
  )
