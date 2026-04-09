# process_census

library(here)

# pivot wider
county_data <- county_data %>%
  select(GEOID, NAME, variable, estimate) %>%
  pivot_wider(
    names_from = variable,
    values_from = estimate
  )

colSums(is.na(county_data))
# very few NAs, can handle as needed

# join data
full_data <- county_data %>%
  left_join(
    im3_by_county %>% select(GEOID, data_center, n_data_centers),
    by = "GEOID"
  ) %>%
  mutate(
    data_center = if_else(is.na(data_center), 0, data_center),
    n_data_centers = if_else(is.na(n_data_centers), 0, n_data_centers)
  )