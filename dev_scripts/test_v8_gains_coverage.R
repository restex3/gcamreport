# Test GAINS coverage with V8 report

library(gcamreport)
library(dplyr)

cat("=== Testing GAINS Coverage with V8 Report ===\n\n")

# Load the V8 report (assuming it was generated)
report_file <- "E:/GCAM/GCAM-China_v8/output/database_basexdb_v8_test_standardized.csv"

if (!file.exists(report_file)) {
  cat("Error: V8 report not found at:", report_file, "\n")
  cat("Please run v8_FINAL.R first to generate the report.\n")
  quit(status = 1)
}

cat("Loading V8 report...\n")
report_v8 <- read.csv(report_file, stringsAsFactors = FALSE)

cat("Report dimensions:", nrow(report_v8), "rows x", ncol(report_v8), "columns\n")
cat("Unique variables:", length(unique(report_v8$Variable)), "\n\n")

# Load GAINS mapping
gains_map_file <- "E:/GCAM/GCAM_tools/gcam2gains/GCAM_GAINS_SEC_ACT_MAP.csv"
if (!file.exists(gains_map_file)) {
  cat("Warning: GAINS mapping file not found at:", gains_map_file, "\n")
  cat("Skipping detailed coverage check.\n")
} else {
  gains_map <- read.csv(gains_map_file, stringsAsFactors = FALSE)
  
  # Get required variables from GAINS map
  required_vars <- unique(gains_map$SOURCE_VARIABLE)
  cat("Required GAINS variables:", length(required_vars), "\n")
  
  # Check which variables are in the V8 report
  report_vars <- unique(report_v8$Variable)
  matched <- required_vars[required_vars %in% report_vars]
  missing <- required_vars[!required_vars %in% report_vars]
  
  cat("\nCoverage Analysis:\n")
  cat("  Matched:", length(matched), "/", length(required_vars), "\n")
  cat("  Missing:", length(missing), "\n")
  cat("  Coverage:", round(100 * length(matched) / length(required_vars), 1), "%\n")
  
  if (length(missing) > 0) {
    cat("\nMissing variables:\n")
    for (var in missing) {
      cat("  -", var, "\n")
    }
  }
  
  # Compare with V7.1 expected coverage (97.5% = 79/81)
  expected_coverage <- 97.5
  actual_coverage <- 100 * length(matched) / length(required_vars)
  
  cat("\n")
  if (actual_coverage >= expected_coverage) {
    cat("✅ GAINS coverage maintained or improved!\n")
    cat("   V7.1 baseline: 97.5% (79/81)\n")
    cat("   V8 actual:", round(actual_coverage, 1), "%\n")
  } else {
    cat("⚠️  GAINS coverage decreased\n")
    cat("   V7.1 baseline: 97.5%\n")
    cat("   V8 actual:", round(actual_coverage, 1), "%\n")
  }
}

cat("\n✅ Test complete!\n")
