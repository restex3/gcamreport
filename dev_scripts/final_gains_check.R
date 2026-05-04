# Final GAINS coverage check - save to file
cat("Starting GAINS coverage check...\n")

# Read output
cat("Reading output file...\n")
all_data <- read.csv("E:/GCAM/GCAM-China_v8/output/database_basexdb_v8_test_standardized.csv",
                     stringsAsFactors = FALSE)
out_vars <- unique(all_data$Variable)
cat("Output variables:", length(out_vars), "\n")

# Read GAINS requirements
cat("Reading GAINS requirements...\n")
gains <- read.csv("E:/GCAM/GCAM_tools/gcam2gains/GCAM_GAINS_SEC_ACT_MAP_V8.csv",
                  stringsAsFactors = FALSE)
req <- unique(gains$SOURCE_VARIABLE[gains$SOURCE_VARIABLE != ""])
cat("Required variables:", length(req), "\n")

# Calculate coverage
matched <- req %in% out_vars
n_matched <- sum(matched)
n_missing <- sum(!matched)
coverage <- n_matched / length(req) * 100

# Classify by region
national <- unique(gains[gains$REGIONAL == "National", ]$SOURCE_VARIABLE)
regional <- unique(gains[gains$REGIONAL == "Regional", ]$SOURCE_VARIABLE)
national_matched <- sum(national %in% out_vars)
regional_matched <- sum(regional %in% out_vars)

# Save results
sink("output/v8_gains_final_result.txt")
cat("================================================================================\n")
cat("GCAM-China V8 GAINS Coverage - Final Report\n")
cat("================================================================================\n")
cat("Date:", format(Sys.time()), "\n\n")

cat("SUMMARY\n")
cat("-------\n")
cat("Total required variables:", length(req), "\n")
cat("Matched variables:", n_matched, "\n")
cat("Missing variables:", n_missing, "\n")
cat("Coverage rate:", sprintf("%.1f%%", coverage), "\n\n")

cat("BY REGION\n")
cat("---------\n")
cat("National:", national_matched, "/", length(national), 
    sprintf("(%.1f%%)", national_matched/length(national)*100), "\n")
cat("Regional:", regional_matched, "/", length(regional), 
    sprintf("(%.1f%%)", regional_matched/length(regional)*100), "\n\n")

if (n_matched > 0) {
  cat("MATCHED VARIABLES (", n_matched, ")\n")
  cat(paste(rep("=", 80), collapse = ""), "\n")
  for (v in req[matched]) {
    region_type <- ifelse(v %in% national, "National", "Regional")
    cat("[", region_type, "]", v, "\n")
  }
  cat("\n")
}

if (n_missing > 0) {
  cat("MISSING VARIABLES (", n_missing, ")\n")
  cat(paste(rep("=", 80), collapse = ""), "\n")
  for (v in req[!matched]) {
    region_type <- ifelse(v %in% national, "National", "Regional")
    cat("[", region_type, "]", v, "\n")
  }
  cat("\n")
}

cat("================================================================================\n")
cat("VERDICT\n")
cat("================================================================================\n")
if (coverage >= 100) {
  cat("SUCCESS: 100% coverage achieved!\n")
} else if (coverage >= 90) {
  cat("EXCELLENT: Coverage >= 90%\n")
} else if (coverage >= 80) {
  cat("GOOD: Coverage >= 80%\n")
} else if (coverage >= 50) {
  cat("MODERATE: Coverage >= 50%, needs improvement\n")
} else {
  cat("POOR: Coverage < 50%, significant work needed\n")
}
sink()

# Print to console
cat("\n=== RESULTS ===\n")
cat("Required:", length(req), "\n")
cat("Matched:", n_matched, "\n")
cat("Coverage:", sprintf("%.1f%%", coverage), "\n")
cat("\nFull report saved to: output/v8_gains_final_result.txt\n\n")
