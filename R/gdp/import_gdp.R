# load and clean gdp data
gdp <- read_csv(here("data", "raw", "CAGDP1__ALL_AREAS_2001_2024.csv")) %>%
  rename(geoid = 'GeoFIPS', yr_2023 = '2023') %>%
  select(geoid, Description, yr_2023) %>%
  pivot_wider(names_from = "Description", values_from = 'yr_2023') %>%
  select(-'NA')

# merge to main dataframe
counties_with_datacenters <- counties_with_datacenters %>%
  left_join(y = gdp, by = 'geoid')
