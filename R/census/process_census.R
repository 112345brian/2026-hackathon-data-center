# process_census

library(here)

# pivot wider
county_data <- county_data %>%
  clean_names() %>%
  select(geoid, name, variable, estimate) %>%
  pivot_wider(names_from = variable, values_from = estimate) %>%
  mutate(geoid = as.character(geoid))