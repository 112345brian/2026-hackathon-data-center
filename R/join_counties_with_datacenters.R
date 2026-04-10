# join_counties_with_datacenters
# returns the dataset for the treated and not treated counties

# create treated and control groups
treated <- county_and_im3 %>% filter(data_center == 1)
control_pool <- county_and_im3 %>% filter(data_center == 0)

table(county_and_im3$data_center)

# find a pair county in same state, the one with the closest population match
matched_controls <- treated %>%
  mutate(treated_geoid = geoid) %>%   # track original
  rowwise() %>%
  do({
    t <- .
    
    t_state <- substr(t$geoid, 1, 2)
    
    control_pool %>%
      filter(substr(geoid, 1, 2) == t_state) %>%
      mutate(
        pop_diff = abs(population - t$population),
        treated_geoid = t$geoid
      ) %>%
      arrange(pop_diff) %>%
      slice(1)
  }) %>%
  ungroup()

# combine matches
treated <- treated %>%
  mutate(pair_id = geoid)

matched_controls <- matched_controls %>%
  mutate(pair_id = treated_geoid)

counties_with_datacenters <- bind_rows(
  treated %>% mutate(group = "treated"),
  matched_controls %>% mutate(group = "control")
)

saveRDS(
  counties_with_datacenters,
  here("data", "output", "analysis.rds")
)