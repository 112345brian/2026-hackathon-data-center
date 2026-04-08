# matched data

# create treated and control groups
treated <- full_data %>% filter(data_center == 1)
control_pool <- full_data %>% filter(data_center == 0)

table(full_data$data_center)

# Find a pair county in same state, the one with the closest population match
matched_controls <- treated %>%
  mutate(treated_geoid = GEOID) %>%   # track original
  rowwise() %>%
  do({
    t <- .
    
    t_state <- substr(t$GEOID, 1, 2)
    
    control_pool %>%
      filter(substr(GEOID, 1, 2) == t_state) %>%
      mutate(
        pop_diff = abs(population - t$population),
        treated_geoid = t$GEOID
      ) %>%
      arrange(pop_diff) %>%
      slice(1)
  }) %>%
  ungroup()

# combine matches
treated <- treated %>%
  mutate(pair_id = GEOID)

matched_controls <- matched_controls %>%
  mutate(pair_id = treated_geoid)

matched_data <- bind_rows(
  treated %>% mutate(group = "treated"),
  matched_controls %>% mutate(group = "control")
)

# check
n_distinct(matched_controls$treated_geoid)
nrow(treated)

# did matching work? 
matched_data %>%
  group_by(pair_id) %>%
  summarise(
    treated_pop = population[group == "treated"],
    control_pop = population[group == "control"],
    diff = abs(treated_pop - control_pop)
  ) %>%
  summary()