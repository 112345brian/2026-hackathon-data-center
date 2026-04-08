### im3 dataset exploration

setwd("C:\\Users\\706cb\\OneDrive\\Documents\\Kristin's Stuff\\JHU\\26_Hackathon")

library(tidyverse)
im3 <- read_csv("C:\\Users\\706cb\\OneDrive\\Documents\\Kristin's Stuff\\JHU\\26_Hackathon\\im3_open_source_data_center_atlas.csv")

dim(im3)
names(im3)

library(tidycensus)
fips <- fips_codes

# i think state id and county id are actually FIPS codes
im3 %>%
  anti_join(
    fips,
    by = c("state_id" = "state_code",
           "county_id" = "county_code")
  ) %>%
  nrow()
# yup

# create column for full 5-digit FIPS
im3 <- im3 %>%
  mutate(GEOID = paste0(state_id, county_id))

# add data_center column with '1' for every entry (yes, has a data center)
im3<- mutate(im3, data_center = 1)

# need each county to have only 1 row; can drop other variables at this point,
# if using for descriptive purposes later will need full original dataset 
im3_by_county <- im3 %>%
  group_by(GEOID) %>%
  summarise(
    n_data_centers = n(),
    data_center = 1,
    state = first(state),
    county = first(county),
    .groups = "drop"
  )

nrow(im3_by_county)
n_distinct(im3_by_county$GEOID)

# now have one county per row, all labeled as containing data centers
unique(im3_by_county$state)

# drop OCONUS in both IM3 and IM3_by_county
im3_by_county <- im3_by_county %>%
  filter(!state %in% c("Puerto Rico", "District of Columbia"))

im3 <- im3 %>% 
  filter(!state_abb %in% c("PR", "DC"))

nrow(im3_by_county)
# only one row dropped, PR

# no na
any(is.na(im3_by_county))
names(im3_by_county)


################## census data
Sys.getenv("CENSUS_API_KEY")

census_vars <- load_variables(2022, "acs5", cache = TRUE)
view(census_vars)

county_data <- get_acs(
  geography = "county",
  variables = c(
    # basics
    population = "B01003_001",
    median_income = "B19013_001",
    poverty = "B17001_002",
    gini = "B19083_001",
    
    # race
    white = "B02001_002",
    black = "B02001_003",
    hispanic = "B03003_003",
    total_race = "B02001_001",
    
    # education
    bachelors = "B15003_022",
    graduate = "B15003_023",
    total_edu = "B15003_001",
    
    # housing
    median_home_value = "B25077_001",
    median_rent = "B25064_001",
    
    # commute
    mean_commute = "B08303_001",
    
    # industry
    agriculture = "C24030_003",
    construction = "C24030_004",
    manufacturing = "C24030_005",
    retail = "C24030_006",
    information = "C24030_007",
    finance = "C24030_008",
    total_employed = "C24030_001"
  ),
  year = 2022,
  survey = "acs5"
)

head(county_data)
names(county_data)

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

