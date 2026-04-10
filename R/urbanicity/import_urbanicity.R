# load rucc data
rucc <- read_csv(here("data", "raw", "Ruralurbancontinuumcodes2023.csv")) %>% 
  pivot_wider(names_from = 'Attribute', values_from = 'Value') %>%
  rename(geoid = "FIPS", metro_description = "Description")

# left join to main dataframe
counties_with_datacenters <- counties_with_datacenters %>%
  left_join(y = rucc %>% select(geoid, RUCC_2023, metro_description), by = "geoid")

