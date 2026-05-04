# Save GAINS coverage to file
library(data.table)

# Read GAINS requirements
gains <- fread("E:/GCAM/GCAM_tools/gcam2gains/GCAM_GAINS_SEC_ACT_MAP_V8.csv")
req <- unique(gains$SOURCE_VARIABLE[gains$SOURCE_VARIABLE != ""])

# Read output
out <- fread("E:/GCAM/GCAM-China_v8/output/database_basexdb_v8_test_standardized.csv", select = "Variable")
out_vars <- unique(out$Variable)

# Calculate
matched <- sum(req %in% out_vars)
total <- length(req)
coverage <- matched / total * 100
missing <- req[!req %in% out_vars]

# Save to file
sink("output/v8_gains_coverage_result.txt")
cat("=== GCAM-China V8 GAINS Coverage Report ===\n")
cat("Date:", format(Sys.time()), "\n\n")
cat("Required variables:", total, "\n")
cat("Matched variables:", matched, "\n")
cat("Missing variables:", length(missing), "\n")
cat("Coverage rate:", sprintf("%.1f%%", coverage), "\n\n")

if (length(missing) > 0) {
  cat("Missing variables list:\n")
  cat("------------------------\n")
  for (v in missing) {
    cat(v, "\n")
  }
}
sink()

# Also print to console
cat("\n=== V8 GAINS Coverage ===\n")
cat("Required:", total, "\n")
cat("Matched:", matched, "\n")
cat("Coverage:", sprintf("%.1f%%", coverage), "\n")
cat("Missing:", length(missing), "\n")
cat("\nFull report saved to: output/v8_gains_coverage_result.txt\n\n")
