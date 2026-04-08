# import_census_API_setup

## private file guard
key <- Sys.getenv("CENSUS_API_KEY")

if (key == "" && exists("census_key")) {
  census_api_key(census_key, install = TRUE, overwrite = TRUE)
  readRenviron("~/.Renviron")
  key <- Sys.getenv("CENSUS_API_KEY")
}

if (key == "") {
  stop("No Census API key found")
}
