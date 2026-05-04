# Quick script to rebuild ag_demand_map_vGCAMChina8.0.rda
# This fixes the missing mappings for regional woodpulp and regional biomass

library(usethis)
library(tidyr)
library(dplyr)

rawDataFolder <- here::here()

# Read the CSV file
df <- readr::read_csv(
  file.path(rawDataFolder, "inst/extdata/mappings/GCAMChina8.0", "ag_demand_map.csv"),
  comment = "#", na = "", show_col_types = FALSE
)

cat("Original CSV dimensions:", nrow(df), "rows x", ncol(df), "columns\n")

# Process: gather all var columns into long format
ag_demand_map_vGCAMChina8.0 <- df %>%
  tidyr::gather(key = "var_num", value = "var", starts_with("var")) %>%
  dplyr::filter(!is.na(var)) %>%
  dplyr::select(input, sector, var, unit_conv)

cat("Processed dimensions:", nrow(ag_demand_map_vGCAMChina8.0), "rows x", ncol(ag_demand_map_vGCAMChina8.0), "columns\n")

# Check for the critical mappings
critical_mappings <- ag_demand_map_vGCAMChina8.0 %>%
  dplyr::filter(input %in% c("regional woodpulp", "regional biomass"))

cat("\nCritical mappings found:\n")
print(critical_mappings)

# Save the data object
use_data(ag_demand_map_vGCAMChina8.0, overwrite = TRUE)

cat("\n✅ ag_demand_map_vGCAMChina8.0.rda rebuilt successfully!\n")

