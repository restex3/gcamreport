# Create complete V8 GAINS mapping

library(dplyr)

cat("=== Creating Complete V8 GAINS Mapping ===\n\n")

# Load data
report_v8 <- read.csv("E:/GCAM/GCAM-China_v8/output/database_basexdb_v8_test_standardized.csv",
                      stringsAsFactors = FALSE)
gains_map_v71 <- read.csv("E:/GCAM/GCAM_tools/gcam2gains/GCAM_GAINS_SEC_ACT_MAP.csv",
                          stringsAsFactors = FALSE)

v8_vars <- unique(report_v8$Variable)

# Complete mapping rules
mapping_rules <- list(
  # Agricultural Production
  "Agricultural Production|Non-Energy|Livestock|Beef" = "Agricultural Production|Livestock|Ruminant|Meat",
  "Agricultural Production|Non-Energy|Livestock|Dairy" = "Agricultural Production|Livestock|Ruminant|Dairy",
  "Agricultural Production|Non-Energy|Livestock|SheepGoat" = "Agricultural Production|Livestock|Ruminant|Meat",
  "Agricultural Production|Non-Energy|Livestock|Pork" = "Agricultural Production|Livestock|Non-Ruminant|Meat|Pig",
  "Agricultural Production|Non-Energy|Livestock|Poultry" = "Agricultural Production|Livestock|Non-Ruminant|Meat|Poultry",

  # Land Cover
  "Land Cover|Cropland|Otherarable" = "Land Cover|Cropland",
  "Land Cover|Cropland|Crops" = "Land Cover|Cropland",
  "Land Cover|Forest|Managed" = "Land Cover|Forest",
  "Land Cover|Pasture|Grazed" = "Land Cover|Pasture",

  # Steel -> Iron and Steel (some don't exist in V8)
  "Final Energy|Industry|Steel|Electricity" = NA,  # Doesn't exist in V8
  "Final Energy|Industry|Steel|Gases" = "Final Energy|Industry|Iron and Steel|Gases",
  "Final Energy|Industry|Steel|Liquids" = "Final Energy|Industry|Iron and Steel|Liquids",
  "Final Energy|Industry|Steel|Solids|Coal" = NA,  # Doesn't exist in V8
  "Feedstock|Industry|Steel|Coke" = NA,  # Feedstock category doesn't exist in V8
  "Production|Steel|Blast Furnace" = "Production|Iron and Steel|Steel",
  "Production|Steel|EAF-scrap" = "Production|Iron and Steel|Steel",
  "Production|Steel|EAF-DRI" = "Production|Iron and Steel|Steel",
  "Production|Steel|Hydrogen-DRI" = "Production|Iron and Steel|Steel",

  # Cement
  "Production|Cement" = "Production|Non-Metallic Minerals|Cement",

  # Chemicals/Fertilizer
  "Production|Chemicals|Nitrogen Fertilizer" = "Production|Chemicals|Ammonia",
  "Production|Chemicals|Fertilizer" = "Production|Chemicals|Ammonia",

  # Non-Energy Use - use aggregate level (more detailed paths exist but use parent)
  "Final Energy|Non-Energy Use|Biomass" = "Final Energy|Non-Energy Use|Solids",
  "Final Energy|Non-Energy Use|Coal" = "Final Energy|Non-Energy Use|Solids|Coal",
  "Final Energy|Non-Energy Use|Oil" = "Final Energy|Non-Energy Use|Liquids",
  "Final Energy|Non-Energy Use|Gas" = "Final Energy|Non-Energy Use|Gases",

  # Primary Energy - many don't exist in V8, mark as NA
  "Primary Energy|Coal|Convert" = NA,
  "Primary Energy|Gas|Convert" = NA,
  "Primary Energy|Oil|Convert" = NA,
  "Primary Energy|Biomass|Convert" = NA,
  "Primary Energy|Oil|Liquids" = NA,

  # Primary Energy Electricity - keep old structure (V7.1 format)
  # These will be removed since they don't match V8 structure
  "Primary Energy|Electricity|Coal|w/o CCS" = NA,
  "Primary Energy|Electricity|Coal|w/ CCS" = NA,
  "Primary Energy|Electricity|Gas|w/o CCS" = NA,
  "Primary Energy|Electricity|Gas|w/ CCS" = NA,
  "Primary Energy|Electricity|Oil|w/o CCS" = NA,
  "Primary Energy|Electricity|Oil|w/ CCS" = NA,
  "Primary Energy|Electricity|Biomass|w/o CCS" = NA,
  "Primary Energy|Electricity|Biomass|w/ CCS" = NA,
  "Primary Energy|Electricity|Nuclear" = NA,
  "Primary Energy|Electricity|Hydro" = NA,
  "Primary Energy|Electricity|Wind" = NA,
  "Primary Energy|Electricity|Solar" = NA,
  "Primary Energy|Electricity|Geothermal" = NA,

  # Transportation
  "Final Energy|Transportation|Electricity" = NA,

  # Off-road Construction - doesn't exist in V8
  "Final Energy|Industry|Off-road|Construction" = NA,
  "Final Energy|Industry|Off-road|Construction|Electricity" = NA,
  "Final Energy|Industry|Off-road|Construction|Gases" = NA,
  "Final Energy|Industry|Off-road|Construction|Hydrogen" = NA,
  "Final Energy|Industry|Off-road|Construction|Liquids" = NA
)

# Apply mapping
gains_map_v8 <- gains_map_v71
removed_count <- 0

for (i in nrow(gains_map_v8):1) {  # Reverse order for safe removal
  old_var <- gains_map_v8$SOURCE_VARIABLE[i]

  if (old_var %in% names(mapping_rules)) {
    new_var <- mapping_rules[[old_var]]

    if (!is.na(new_var)) {
      gains_map_v8$SOURCE_VARIABLE[i] <- new_var
    } else {
      # Remove rows for variables that don't exist in V8
      gains_map_v8 <- gains_map_v8[-i, ]
      removed_count <- removed_count + 1
    }
  }
}

cat("Removed", removed_count, "rows for non-existent V8 variables\n\n")

# Verify coverage
required_vars <- unique(gains_map_v8$SOURCE_VARIABLE)
matched <- sum(required_vars %in% v8_vars)
missing <- required_vars[!required_vars %in% v8_vars]
coverage <- 100 * matched / length(required_vars)

cat("=== V8 GAINS Mapping Coverage ===\n")
cat("Total required:", length(required_vars), "\n")
cat("Matched:", matched, "\n")
cat("Missing:", length(missing), "\n")
cat("Coverage:", round(coverage, 1), "%\n\n")

if (length(missing) > 0) {
  cat("Still missing:\n")
  for (v in missing) {
    cat("  -", v, "\n")
  }
}

# Save
output_file <- "E:/GCAM/GCAM_tools/gcam2gains/GCAM_GAINS_SEC_ACT_MAP_V8.csv"
write.csv(gains_map_v8, output_file, row.names = FALSE)
cat("\n✅ Saved to:", output_file, "\n")
cat("   Rows:", nrow(gains_map_v8), "\n")
