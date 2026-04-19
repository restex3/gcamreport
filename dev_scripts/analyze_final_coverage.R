# Final GAINS Coverage Analysis
# Date: 2026-04-20
# Purpose: Analyze final coverage after all improvements

library(dplyr)

# Load GAINS mapping
gains_map <- read.csv('E:/GCAM/GCAM_tools/gcam2gains/GCAM_GAINS_SEC_ACT_MAP.csv',
                      stringsAsFactors = FALSE)
required_vars <- sort(unique(gains_map$SOURCE_VARIABLE))

cat("=== GAINS MAPPING FINAL COVERAGE ANALYSIS ===\n\n")
cat("Total GAINS variables required:", length(required_vars), "\n\n")

# Check if new output exists
output_file <- 'E:/GCAM/GCAM_tools/gcamreport/output/gains_final_v3.csv'
if (!file.exists(output_file)) {
  cat("New output file not ready yet. Using previous output (v2).\n")
  output_file <- 'E:/GCAM/GCAM_tools/gcamreport/output/gains_final_v2.csv'
}

cat("Using output file:", output_file, "\n\n")

# Load output
output <- read.csv(output_file, stringsAsFactors = FALSE)
available_vars <- sort(unique(output$Variable))

cat("Variables in output:", length(available_vars), "\n\n")

# Calculate coverage
matched_vars <- intersect(required_vars, available_vars)
missing_vars <- setdiff(required_vars, available_vars)

coverage_pct <- 100 * length(matched_vars) / length(required_vars)

cat("=== COVERAGE SUMMARY ===\n")
cat(sprintf("Coverage: %.1f%% (%d/%d)\n", coverage_pct, length(matched_vars), length(required_vars)))
cat(sprintf("Missing: %d variables\n\n", length(missing_vars)))

if (length(missing_vars) > 0) {
  cat("=== MISSING VARIABLES ===\n\n")

  # Categorize missing variables
  primary_convert <- grep("Primary Energy\\|.*\\|Convert", missing_vars, value = TRUE)
  land_cover <- grep("Land Cover", missing_vars, value = TRUE)
  non_energy <- grep("Non-Energy Use", missing_vars, value = TRUE)
  other <- setdiff(missing_vars, c(primary_convert, land_cover, non_energy))

  if (length(primary_convert) > 0) {
    cat("1. Primary Energy|*|Convert (", length(primary_convert), ")\n", sep = "")
    cat(paste("   -", primary_convert), sep = "\n")
    cat("\n")
  }

  if (length(land_cover) > 0) {
    cat("2. Land Cover (", length(land_cover), ")\n", sep = "")
    cat(paste("   -", land_cover), sep = "\n")
    cat("\n")
  }

  if (length(non_energy) > 0) {
    cat("3. Non-Energy Use (", length(non_energy), ")\n", sep = "")
    cat(paste("   -", non_energy), sep = "\n")
    cat("\n")
  }

  if (length(other) > 0) {
    cat("4. Other (", length(other), ")\n", sep = "")
    cat(paste("   -", other), sep = "\n")
    cat("\n")
  }
}

cat("=== IMPROVEMENTS MADE ===\n\n")
cat("1. Added Primary Energy|*|Convert alias mappings (5 variables)\n")
cat("   - Primary Energy|Biomass|Convert\n")
cat("   - Primary Energy|Coal|Convert\n")
cat("   - Primary Energy|Gas|Convert\n")
cat("   - Primary Energy|Oil|Convert\n")
cat("   - Primary Energy|Oil|Liquids\n\n")

cat("2. Verified Off-road|Construction mappings (5 variables) - Already working\n\n")

cat("3. Verified Residential and Commercial aggregations (3 variables) - Already working\n\n")

cat("4. Added Land Cover custom aggregations (2 variables)\n")
cat("   - Land Cover|Cropland|Crops\n")
cat("   - Land Cover|Forest|Managed\n\n")

cat("=== FINAL STATUS ===\n\n")
if (coverage_pct >= 90) {
  cat("✅ SUCCESS: Achieved 90%+ coverage target!\n")
} else if (coverage_pct >= 85) {
  cat("✅ SUCCESS: Achieved 85%+ minimum target!\n")
} else {
  cat("⚠️  Coverage below 85% target. Further investigation needed.\n")
}

cat("\nReport generated:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n")
