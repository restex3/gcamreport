# Rebuild primary_energy_map_vGCAMChina8.0.rda

library(usethis)
library(tidyr)
library(dplyr)

rawDataFolder <- here::here()

# Read the CSV file
df <- readr::read_csv(
  file.path(rawDataFolder, "inst/extdata/mappings/GCAMChina8.0", "primary_energy_map.csv"),
  comment = "#", na = "", show_col_types = FALSE
)

cat("Original CSV dimensions:", nrow(df), "rows x", ncol(df), "columns\n")

# Process: gather all var columns into long format
primary_energy_map_vGCAMChina8.0 <- df %>%
  tidyr::gather(key = "var_num", value = "var", starts_with("var")) %>%
  dplyr::filter(!is.na(var)) %>%
  dplyr::select(fuel, var, unit_conv)

cat("Processed dimensions:", nrow(primary_energy_map_vGCAMChina8.0), "rows x", ncol(primary_energy_map_vGCAMChina8.0), "columns\n")

# Check for the critical mappings
critical_mappings <- primary_energy_map_vGCAMChina8.0 %>%
  dplyr::filter(fuel %in% c("H2 industrial", "regional biomass", "regional biomassOil",
                             "regional corn for ethanol", "wholesale gas", "woodpulp_energy"))

cat("\nCritical mappings found:\n")
print(critical_mappings)

# Save the data object
use_data(primary_energy_map_vGCAMChina8.0, overwrite = TRUE)

cat("\n✅ primary_energy_map_vGCAMChina8.0.rda rebuilt successfully!\n")
