# import_census_API_setup
library(tidycensus)
library(here)

census_key <- "b8f4e69bd8fdee3a5697c1528315ad923550659c"

## private file guard
key <- Sys.getenv("CENSUS_API_KEY")


if (exists("census_key")) {
  census_api_key(census_key, install = TRUE, overwrite = TRUE)
  readRenviron("~/.Renviron")
  key <- Sys.getenv("CENSUS_API_KEY")
}


if (key == "") {
  stop("No Census API key found")
}
