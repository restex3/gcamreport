# Create V8-specific GAINS mapping based on actual V8 variables

library(dplyr)
library(readr)

cat("=== Creating V8 GAINS Mapping ===\n\n")

# Load V8 report
report_v8 <- read.csv("E:/GCAM/GCAM-China_v8/output/database_basexdb_v8_test_standardized.csv", 
                      stringsAsFactors = FALSE)

# Load original V7.1 GAINS mapping
gains_map_v71 <- read.csv("E:/GCAM/GCAM_tools/gcam2gains/GCAM_GAINS_SEC_ACT_MAP.csv",
                          stringsAsFactors = FALSE)

cat("Original mapping rows:", nrow(gains_map_v71), "\n")
cat("Required variables:", length(unique(gains_map_v71$SOURCE_VARIABLE)), "\n\n")

# Get all V8 variables
v8_vars <- unique(report_v8$Variable)

# Create mapping rules for V8
mapping_rules <- list(
  # Agricultural Production - remove |Non-Energy| layer
  "Agricultural Production|Non-Energy|Livestock|Beef" = 
    "Agricultural Production|Livestock|Ruminant|Meat",
  "Agricultural Production|Non-Energy|Livestock|Dairy" = 
    "Agricultural Production|Livestock|Ruminant|Dairy",
  "Agricultural Production|Non-Energy|Livestock|SheepGoat" = 
    "Agricultural Production|Livestock|Ruminant|Meat",
  "Agricultural Production|Non-Energy|Livestock|Pork" = 
    "Agricultural Production|Livestock|Non-Ruminant|Meat|Pig",
  "Agricultural Production|Non-Energy|Livestock|Poultry" = 
    "Agricultural Production|Livestock|Non-Ruminant|Meat|Poultry",
  
  # Land Cover - check actual V8 structure
  "Land Cover|Cropland|Otherarable" = "Land Cover|Cropland",
  "Land Cover|Cropland|Crops" = "Land Cover|Cropland",
  "Land Cover|Forest|Managed" = "Land Cover|Forest",
  "Land Cover|Pasture|Grazed" = "Land Cover|Pasture",
  
  # Primary Energy - Convert variables may not exist in V8
  "Primary Energy|Coal|Convert" = NA,
  "Primary Energy|Gas|Convert" = NA,
  "Primary Energy|Oil|Convert" = NA,
  "Primary Energy|Biomass|Convert" = NA,
  
  # Primary Energy - Electricity (structure changed)
  "Primary Energy|Electricity|Coal|w/o CCS" = "Primary Energy|Coal|Electricity|w/o CCS",
  "Primary Energy|Electricity|Coal|w/ CCS" = "Primary Energy|Coal|Electricity|w/ CCS",
  "Primary Energy|Electricity|Gas|w/o CCS" = "Primary Energy|Gas|Electricity|w/o CCS",
  "Primary Energy|Electricity|Gas|w/ CCS" = "Primary Energy|Gas|Electricity|w/ CCS",
  "Primary Energy|Electricity|Oil|w/o CCS" = "Primary Energy|Oil|Electricity|w/o CCS",
  "Primary Energy|Electricity|Oil|w/ CCS" = "Primary Energy|Oil|Electricity|w/ CCS",
  "Primary Energy|Electricity|Biomass|w/o CCS" = "Primary Energy|Biomass|Electricity|w/o CCS",
  "Primary Energy|Electricity|Biomass|w/ CCS" = "Primary Energy|Biomass|Electricity|w/ CCS",
  "Primary Energy|Electricity|Nuclear" = "Primary Energy|Nuclear|Electricity",
  "Primary Energy|Electricity|Hydro" = "Primary Energy|Hydro|Electricity",
  "Primary Energy|Electricity|Wind" = "Primary Energy|Wind|Electricity",
  "Primary Energy|Electricity|Solar" = "Primary Energy|Solar|Electricity",
  "Primary Energy|Electricity|Geothermal" = "Primary Energy|Geothermal|Electricity"
)

# Create V8 mapping by updating SOURCE_VARIABLE
gains_map_v8 <- gains_map_v71

for (i in 1:nrow(gains_map_v8)) {
  old_var <- gains_map_v8$SOURCE_VARIABLE[i]
  
  if (old_var %in% names(mapping_rules)) {
    new_var <- mapping_rules[[old_var]]
    
    if (!is.na(new_var)) {
      gains_map_v8$SOURCE_VARIABLE[i] <- new_var
      cat("Mapped:", old_var, "->", new_var, "\n")
    } else {
      cat("Skipped (not in V8):", old_var, "\n")
    }
  }
}

# Verify coverage
required_vars <- unique(gains_map_v8$SOURCE_VARIABLE)
matched <- sum(required_vars %in% v8_vars)
coverage <- 100 * matched / length(required_vars)

cat("\n=== V8 Mapping Coverage ===\n")
cat("Required:", length(required_vars), "\n")
cat("Matched:", matched, "\n")
cat("Coverage:", round(coverage, 1), "%\n")

# Save V8 mapping
output_file <- "E:/GCAM/GCAM_tools/gcam2gains/GCAM_GAINS_SEC_ACT_MAP_V8.csv"
write.csv(gains_map_v8, output_file, row.names = FALSE)
cat("\n✅ Saved to:", output_file, "\n")

