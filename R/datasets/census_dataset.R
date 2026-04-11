census_data <- get_acs(
  geography = "county",
  variables = c(
    population = "B01003_001",
    median_income = "B19013_001",
    poverty = "B17001_002",
    gini = "B19083_001",
    median_age = "B01002_001",
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
    
    # housing age (B25034)
    year_built_2014_plus = "B25034_002",
    year_built_2010_2013 = "B25034_003",
    year_built_2000_2009 = "B25034_004",
    year_built_1990_1999 = "B25034_005",
    year_built_1980_1989 = "B25034_006",
    year_built_1970_1979 = "B25034_007",
    year_built_1960_1969 = "B25034_008",
    year_built_1950_1959 = "B25034_009",
    year_built_1940_1949 = "B25034_010",
    year_built_1939_or_earlier = "B25034_011",
    total_housing = "B25034_001"
  ),
  year = 2022,
  survey = "acs5"
) |>
  clean_names() |>
  select(geoid, name, variable, estimate) |>
  pivot_wider(names_from = variable, values_from = estimate) |>
  mutate(
    geoid = as.character(geoid),
    
    avg_house_age =
      (
        year_built_2014_plus * 5 +
          year_built_2010_2013 * 10 +
          year_built_2000_2009 * 18 +
          year_built_1990_1999 * 28 +
          year_built_1980_1989 * 38 +
          year_built_1970_1979 * 48 +
          year_built_1960_1969 * 58 +
          year_built_1950_1959 * 68 +
          year_built_1940_1949 * 78 +
          year_built_1939_or_earlier * 90
      ) / total_housing
  )
