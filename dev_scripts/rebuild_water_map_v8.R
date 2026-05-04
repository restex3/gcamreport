# Rebuild water_map_vGCAMChina8.0.rda

library(usethis)
library(tidyr)
library(dplyr)

rawDataFolder <- here::here()

# Read the CSV file (note: file is named water.csv, not water_map.csv)
df <- readr::read_csv(
  file.path(rawDataFolder, "inst/extdata/mappings/GCAMChina8.0", "water.csv"),
  comment = "#", na = "", show_col_types = FALSE
)

cat("Original CSV dimensions:", nrow(df), "rows x", ncol(df), "columns\n")

# Process: gather all var columns into long format
water_map_vGCAMChina8.0 <- df %>%
  tidyr::gather(key = "var_num", value = "var", starts_with("var")) %>%
  dplyr::filter(!is.na(var)) %>%
  dplyr::select(-var_num)

cat("Processed dimensions:", nrow(water_map_vGCAMChina8.0), "rows x", ncol(water_map_vGCAMChina8.0), "columns\n")

# Save the data object
use_data(water_map_vGCAMChina8.0, overwrite = TRUE)

cat("\n✅ water_map_vGCAMChina8.0.rda rebuilt successfully!\n")
