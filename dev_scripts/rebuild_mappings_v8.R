# Rebuild package data for GCAM-China V8
# Generated: 2026-04-28

library(dplyr)
library(readr)

cat("=== Rebuilding package data for GCAM-China V8 ===\n\n")

mapping_base <- "inst/extdata/mappings/GCAMChina8.0"

# Load V8 mappings
cat("Loading V8 mappings...\n")

co2_sector_map_vGCAMChina8.0 <- read_csv(
  file.path(mapping_base, "CO2_sector_map.csv"),
  show_col_types = FALSE
)
cat("  - CO2 sector map:", nrow(co2_sector_map_vGCAMChina8.0), "rows\n")

co2_resource_map_vGCAMChina8.0 <- read_csv(
  file.path(mapping_base, "CO2_resource_map.csv"),
  show_col_types = FALSE
)
cat("  - CO2 resource map:", nrow(co2_resource_map_vGCAMChina8.0), "rows\n")

nonco2_emis_sector_map_vGCAMChina8.0 <- read_csv(
  file.path(mapping_base, "nonCO2_emissions_sector_map.csv"),
  show_col_types = FALSE
)
cat("  - Non-CO2 emissions sector map:", nrow(nonco2_emis_sector_map_vGCAMChina8.0), "rows\n")

kyoto_sector_map_vGCAMChina8.0 <- read_csv(
  file.path(mapping_base, "Kyotogas_sector.csv"),
  show_col_types = FALSE
)
cat("  - Kyoto sector map:", nrow(kyoto_sector_map_vGCAMChina8.0), "rows\n")

# Load template (use V7.1 as base, will be same structure)
template_vGCAMChina8.0 <- read_csv(
  "inst/extdata/template/GCAM7.1/common-definitions-template.csv",
  show_col_types = FALSE
)
cat("  - Template:", nrow(template_vGCAMChina8.0), "rows\n")

# Save to data/
cat("\nSaving to data/...\n")

usethis::use_data(
  co2_sector_map_vGCAMChina8.0,
  co2_resource_map_vGCAMChina8.0,
  nonco2_emis_sector_map_vGCAMChina8.0,
  kyoto_sector_map_vGCAMChina8.0,
  template_vGCAMChina8.0,
  overwrite = TRUE,
  compress = "xz"
)

cat("\n=== Data rebuild complete ===\n")
cat("Created data objects:\n")
cat("  - co2_sector_map_vGCAMChina8.0\n")
cat("  - co2_resource_map_vGCAMChina8.0\n")
cat("  - nonco2_emis_sector_map_vGCAMChina8.0\n")
cat("  - kyoto_sector_map_vGCAMChina8.0\n")
cat("  - template_vGCAMChina8.0\n")
cat("\nNext: Run devtools::document()\n")

# Add queries_general for V8 (same as V7.1)
cat("\nAdding queries_general_vGCAMChina8.0...\n")
queries_general_vGCAMChina8.0 <- queries_general_vGCAMChina7.1
cat("  - Queries:", length(queries_general_vGCAMChina8.0), "\n")

usethis::use_data(
  queries_general_vGCAMChina8.0,
  overwrite = TRUE,
  compress = "xz"
)

cat("\nUpdated! Now run devtools::document()\n")
