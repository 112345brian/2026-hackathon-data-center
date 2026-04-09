# process_census

library(here)

# pivot wider
county_data <- county_data %>%
  select(GEOID, NAME, variable, estimate) %>%
  pivot_wider(names_from = variable, values_from = estimate) %>%
  clean_names() %>%
  mutate(geoid = as.character(geoid))