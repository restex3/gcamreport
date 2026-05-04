# Quick GAINS Coverage Check - V8
# Uses data.table for fast reading

library(data.table)

cat("\n=== GCAM-China V8 GAINS Coverage Quick Check ===\n\n")

# Read GAINS requirements
gains_map <- fread("E:/GCAM/GCAM_tools/gcam2gains/GCAM_GAINS_SEC_ACT_MAP_V8.csv")
required_vars <- unique(gains_map$SOURCE_VARIABLE)
required_vars <- required_vars[required_vars != ""]

cat("GAINS required variables:", length(required_vars), "\n\n")

# Read output (only Variable column for speed)
cat("Reading output file (Variable column only)...\n")
output_data <- fread("E:/GCAM/GCAM-China_v8/output/database_basexdb_v8_test_standardized.csv",
                     select = "Variable")

output_vars <- unique(output_data$Variable)
cat("Output unique variables:", length(output_vars), "\n\n")

# Calculate coverage
matched <- required_vars %in% output_vars
coverage <- sum(matched) / length(required_vars) * 100

cat("=== RESULTS ===\n")
cat("Matched:", sum(matched), "/", length(required_vars), "\n")
cat("Coverage:", sprintf("%.1f%%", coverage), "\n\n")

# Show missing
missing <- required_vars[!matched]
if (length(missing) > 0) {
  cat("Missing variables (", length(missing), "):\n")
  for (v in missing) {
    cat("  -", v, "\n")
  }
} else {
  cat("SUCCESS: All GAINS variables covered!\n")
}

cat("\n")
