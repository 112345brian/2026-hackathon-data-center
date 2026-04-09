# process_join_county_data_and_im3

county_and_im3 <- county_data %>%
  left_join(
    im3_by_county %>% select(fip, data_center, n_data_centers),
    by = c("geoid" = "fip")
  ) %>%
  mutate(
    data_center = if_else(is.na(data_center), 0, data_center),
    n_data_centers = if_else(is.na(n_data_centers), 0, n_data_centers)
  )