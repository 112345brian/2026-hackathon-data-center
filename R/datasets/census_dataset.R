# census_dataset

# ensure a Census API key is available and registered
census_key <- Sys.getenv("CENSUS_API_KEY")

if (census_key == "") {
  default_key <- "b8f4e69bd8fdee3a5697c1528315ad923550659c"
  census_api_key(default_key, install = TRUE, overwrite = TRUE)
  readRenviron("~/.Renviron")
  census_key <- Sys.getenv("CENSUS_API_KEY")
}

if (census_key == "") {
  stop("No Census API key found")
}

census_data <- get_acs(
  geography = "county",
  variables = c(
    population = "B01003_001",
    median_income = "B19013_001",
    poverty = "B17001_002",
    gini = "B19083_001",
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
    total_employed = "C24030_001"
  ),
  year = 2022,
  survey = "acs5"
) |>
  clean_names() |>
  select(geoid, name, variable, estimate) |>
  pivot_wider(names_from = variable, values_from = estimate) |>
  mutate(geoid = as.character(geoid))
