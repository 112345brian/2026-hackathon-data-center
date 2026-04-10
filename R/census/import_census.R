# import_census

source(here("R", "census", "import_census_API_setup.R"))

census_vars <- load_variables(2022, "acs5", cache = TRUE)

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

