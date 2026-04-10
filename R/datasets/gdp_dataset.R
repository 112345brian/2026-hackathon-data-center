# gdp_dataset

gdp_lines <- read_lines(
  here("data", "raw", "CAGDP1__ALL_AREAS_2001_2024.csv"),
  locale = locale(encoding = "latin1"),
  progress = FALSE
)

note_idx <- which(str_detect(gdp_lines, '^"Note:'))
if (length(note_idx) > 0) {
  gdp_lines <- gdp_lines[seq_len(note_idx[1] - 1)]
}

gdp_raw <- read_csv(
  I(paste(gdp_lines, collapse = "\n")),
  col_types = cols(.default = col_character()),
  locale = locale(encoding = "latin1"),
  progress = FALSE,
  show_col_types = FALSE
)

gdp_data <- gdp_raw |>
  transmute(
    geoid = str_pad(str_remove_all(GeoFIPS, "'"), width = 5, pad = "0"),
    Description,
    value_2023 = parse_number(
      `2023`,
      na = c("", "NA", "(NA)", "(D)", "(L)", "(S)", "(C)", "(NM)", "NM")
    )
  ) |>
  pivot_wider(names_from = Description, values_from = value_2023) |>
  clean_names()
