census_data <- get_acs(
  geography = "county",
  variables = c(
    population = "B01003_001",
    median_income = "B19013_001",
    poverty = "B17001_002",
    gini = "B19083_001",
    median_resident_age = "B01002_001",
    white = "B02001_002",
    black = "B02001_003",
    hispanic = "B03003_003",
    total_race = "B02001_001",
    bachelors = "B15003_022",
    graduate = "B15003_023",
    total_edu = "B15003_001",
    median_home_value = "B25077_001",
    median_rent = "B25064_001",
    mean_commute = "B08303_001",
    agriculture = "C24030_003",
    construction = "C24030_004",
    manufacturing = "C24030_005",
    retail = "C24030_006",
    information = "C24030_007",
    finance = "C24030_008",
    total_employed = "C24030_001",
    median_year_structure_built = "B25035_001"
  ),
  year = 2022,
  survey = "acs5"
) |>
  clean_names() |>
  select(geoid, name, variable, estimate) |>
  pivot_wider(names_from = variable, values_from = estimate) |>
  mutate(
    geoid = as.character(geoid),
    median_house_age = 2022 - median_year_structure_built
  )
