# Ultra-fast GAINS coverage check
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

# Results
cat("\n=== V8 GAINS Coverage ===\n")
cat("Required:", total, "\n")
cat("Matched:", matched, "\n")
cat("Coverage:", sprintf("%.1f%%", coverage), "\n")
cat("Missing:", total - matched, "\n\n")

# List missing
missing <- req[!req %in% out_vars]
if (length(missing) > 0) {
  cat("Missing variables:\n")
  writeLines(paste("  -", missing))
}
