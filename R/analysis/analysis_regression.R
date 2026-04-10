# analysis_regression

counties_with_datacenters_and_fips <- counties |>
  clean_names()

data_center_on_burden <- lm(ami_energy_burden_all ~ data_center + as.factor(state), data = counties_with_datacenters_and_fips)

data_center_on_median_income <- lm(median_income ~ data_center + as.factor(state), data = counties_with_datacenters_and_fips)

data_center_on_gini <- lm(gini ~ data_center + as.factor(state), data = counties_with_datacenters_and_fips)

data_center_on_gdp <- lm(current_dollar_gdp_thousands_of_current_dollars ~ data_center + as.factor(state), data = counties_with_datacenters_and_fips, na.rm = TRUE)

summary(data_center_on_gdp)