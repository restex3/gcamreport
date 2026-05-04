# GAINS Coverage Check - Fixed version
library(data.table)

cat("\n=== Reading GAINS requirements ===\n")
gains <- fread("E:/GCAM/GCAM_tools/gcam2gains/GCAM_GAINS_SEC_ACT_MAP_V8.csv")
req <- unique(gains$SOURCE_VARIABLE[gains$SOURCE_VARIABLE != ""])
cat("Required variables:", length(req), "\n")

# Classify by region
national <- unique(gains[REGIONAL == "National"]$SOURCE_VARIABLE)
regional <- unique(gains[REGIONAL == "Regional"]$SOURCE_VARIABLE)
cat("  National:", length(national), "\n")
cat("  Regional:", length(regional), "\n\n")

cat("=== Reading output file ===\n")
out <- fread("E:/GCAM/GCAM-China_v8/output/database_basexdb_v8_test_standardized.csv", 
             select = "Variable", showProgress = FALSE)
out_vars <- unique(out$Variable)
cat("Output variables:", length(out_vars), "\n\n")

cat("=== Calculating coverage ===\n")
matched <- req %in% out_vars
n_matched <- sum(matched)
n_missing <- sum(!matched)
coverage <- n_matched / length(req) * 100

cat("Matched:", n_matched, "/", length(req), "\n")
cat("Coverage:", sprintf("%.1f%%", coverage), "\n")
cat("Missing:", n_missing, "\n\n")

# Analyze by region
national_matched <- sum(national %in% out_vars)
regional_matched <- sum(regional %in% out_vars)
national_cov <- national_matched / length(national) * 100
regional_cov <- regional_matched / length(regional) * 100

cat("=== By Region ===\n")
cat("National:", national_matched, "/", length(national), 
    sprintf("(%.1f%%)", national_cov), "\n")
cat("Regional:", regional_matched, "/", length(regional), 
    sprintf("(%.1f%%)", regional_cov), "\n\n")

# List missing
missing <- req[!matched]
if (n_missing > 0) {
  cat("=== Missing Variables (", n_missing, ") ===\n")
  for (v in missing) {
    region_type <- ifelse(v %in% national, "National", "Regional")
    cat("  [", region_type, "]", v, "\n")
  }
  cat("\n")
}

# Save detailed report
dir.create("output", showWarnings = FALSE, recursive = TRUE)
report <- data.frame(
  Variable = req,
  Covered = matched,
  Region = ifelse(req %in% national, "National", "Regional")
)
fwrite(report, "output/v8_gains_coverage_detail.csv")

# Save summary
sink("output/v8_gains_coverage_summary.txt")
cat("GCAM-China V8 GAINS Coverage Report\n")
cat("====================================\n")
cat("Date:", format(Sys.time()), "\n\n")
cat("Total required:", length(req), "\n")
cat("Matched:", n_matched, "\n")
cat("Missing:", n_missing, "\n")
cat("Coverage:", sprintf("%.1f%%", coverage), "\n\n")
cat("By Region:\n")
cat("  National:", national_matched, "/", length(national), 
    sprintf("(%.1f%%)", national_cov), "\n")
cat("  Regional:", regional_matched, "/", length(regional), 
    sprintf("(%.1f%%)", regional_cov), "\n\n")
if (n_missing > 0) {
  cat("Missing Variables:\n")
  cat("------------------\n")
  for (v in missing) {
    region_type <- ifelse(v %in% national, "National", "Regional")
    cat("[", region_type, "]", v, "\n")
  }
}
sink()

cat("=== Reports Saved ===\n")
cat("  output/v8_gains_coverage_summary.txt\n")
cat("  output/v8_gains_coverage_detail.csv\n\n")

# Final verdict
cat("=== FINAL VERDICT ===\n")
if (coverage >= 100) {
  cat("SUCCESS: 100% coverage!\n")
} else if (coverage >= 90) {
  cat("EXCELLENT: Coverage >= 90%\n")
} else if (coverage >= 80) {
  cat("GOOD: Coverage >= 80%\n")
} else {
  cat("NEEDS IMPROVEMENT: Coverage < 80%\n")
}
cat("\n")
