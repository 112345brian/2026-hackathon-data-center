# import_imp3_and_fips

## import im3
imp3_path <- here("data", "raw", "im3.rds")
imp3_csv  <- here("data", "raw", "im3_open_source_data_center_atlas.csv")

if (!file.exists(imp3_path)) {
  im3 <- read_csv(imp3_csv)
  saveRDS(im3, imp3_path)
} else {
  im3 <- readRDS(imp3_path)
}

## import fips
fips <- fips_codes