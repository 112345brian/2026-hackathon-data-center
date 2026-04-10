# process_im3

library(janitor)

im3_process <- im3_import |>
  clean_names()

# create column for full 5-digit FIPS
im3_process <- im3_process %>%
  mutate(fip = paste0(state_id, county_id))

# add data_center column with '1' for every entry (yes, has a data center)
im3_process <- mutate(im3_process, data_center = 1)

# need each county to have only 1 row; can drop other variables at this point,
# if using for descriptive purposes later will need full original dataset 
im3_by_county <- im3_process %>%
  group_by(fip) %>%
  summarise(
    n_data_centers = n(),
    data_center = 1,
    state = first(state),
    county = first(county),
    .groups = "drop"
  )

# drop OCONUS in both IM3 and IM3_by_county
im3_by_county <- im3_by_county %>%
  filter(!state %in% c("Puerto Rico", "District of Columbia"))

im3_process <- im3_process %>% 
  filter(!state_abb %in% c("PR", "DC"))