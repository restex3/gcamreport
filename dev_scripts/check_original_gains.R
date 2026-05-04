# Check coverage against ORIGINAL GAINS map (81 variables)
cat("Checking against ORIGINAL GCAM_GAINS_SEC_ACT_MAP.csv\n\n")

# Read ORIGINAL GAINS requirements (not V8 version)
gains <- read.csv("E:/GCAM/GCAM_tools/gcam2gains/GCAM_GAINS_SEC_ACT_MAP.csv",
                  stringsAsFactors = FALSE)
req <- unique(gains$SOURCE_VARIABLE[gains$SOURCE_VARIABLE != ""])
cat("ORIGINAL GAINS required variables:", length(req), "\n")

# Read V8 output
out <- read.csv("E:/GCAM/GCAM-China_v8/output/database_basexdb_v8_test_standardized.csv",
                stringsAsFactors = FALSE)
out_vars <- unique(out$Variable)
cat("V8 output variables:", length(out_vars), "\n\n")

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
sink("output/v8_vs_original_gains_coverage.txt")
cat("================================================================================\n")
cat("GCAM-China V8 vs ORIGINAL GAINS Map Coverage\n")
cat("================================================================================\n")
cat("Date:", format(Sys.time()), "\n\n")

cat("SUMMARY\n")
cat("-------\n")
cat("ORIGINAL GAINS required:", length(req), "\n")
cat("V8 matched:", n_matched, "\n")
cat("V8 missing:", n_missing, "\n")
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
  cat("SUCCESS: 100% coverage!\n")
} else if (coverage >= 90) {
  cat("EXCELLENT: >= 90%\n")
} else if (coverage >= 80) {
  cat("GOOD: >= 80%\n")
} else {
  cat("NEEDS WORK: < 80%\n")
}
sink()

# Console output
cat("=== V8 vs ORIGINAL GAINS ===\n")
cat("Required:", length(req), "\n")
cat("Matched:", n_matched, "\n")
cat("Missing:", n_missing, "\n")
cat("Coverage:", sprintf("%.1f%%", coverage), "\n\n")
cat("Report saved to: output/v8_vs_original_gains_coverage.txt\n\n")
