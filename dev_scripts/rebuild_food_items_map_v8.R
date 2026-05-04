# Rebuild food_items_map_vGCAMChina8.0.rda

library(usethis)
library(readr)
library(dplyr)

rawDataFolder <- here::here()

# Read the CSV file
food_items_map_vGCAMChina8.0 <- read_csv(
  file.path(rawDataFolder, "inst/extdata/mappings/GCAMChina8.0", "food_items_map.csv"),
  comment = "#", show_col_types = FALSE
)

cat("Rows in food_items_map_vGCAMChina8.0:", nrow(food_items_map_vGCAMChina8.0), "\n")

# Check for biomass mappings
biomass_mappings <- food_items_map_vGCAMChina8.0 %>%
  filter(item == "biomass")

cat("\nBiomass mappings:\n")
print(biomass_mappings)

# Save the data object
use_data(food_items_map_vGCAMChina8.0, overwrite = TRUE)

cat("\n✅ food_items_map_vGCAMChina8.0.rda rebuilt successfully!\n")
