# process_im3

library(janitor)

im3 <- im3 |>
  clean_names()

# create column for full 5-digit FIPS
im3 <- im3 %>%
  mutate(fip = paste0(state_id, county_id))

# add data_center column with '1' for every entry (yes, has a data center)
im3<- mutate(im3, data_center = 1)

# need each county to have only 1 row; can drop other variables at this point,
# if using for descriptive purposes later will need full original dataset 
im3_by_county <- im3 %>%
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

im3 <- im3 %>% 
  filter(!state_abb %in% c("PR", "DC"))