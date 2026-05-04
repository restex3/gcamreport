# GCAM-China V8 GAINS Coverage Verification
# Date: 2026-05-04

suppressPackageStartupMessages({
  library(dplyr)
})

cat("\n")
cat("================================================================================\n")
cat("GCAM-China V8 GAINS Coverage Verification\n")
cat("================================================================================\n\n")

# Step 1: Read GAINS requirements
cat("Step 1: Read GAINS requirement variables\n")
cat("--------------------------------------------------------------------------------\n")

gains_map <- read.csv("E:/GCAM/GCAM_tools/gcam2gains/GCAM_GAINS_SEC_ACT_MAP_V8.csv", 
                      stringsAsFactors = FALSE)

required_vars <- unique(gains_map$SOURCE_VARIABLE)
required_vars <- required_vars[required_vars != ""]

cat("Total GAINS required variables:", length(required_vars), "\n")
cat("Sample variables:\n")
for (i in 1:min(5, length(required_vars))) {
  cat("  -", required_vars[i], "\n")
}
cat("\n")

# Classify by region
national_vars <- gains_map %>%
  filter(REGIONAL == "National") %>%
  pull(SOURCE_VARIABLE) %>%
  unique()

regional_vars <- gains_map %>%
  filter(REGIONAL == "Regional") %>%
  pull(SOURCE_VARIABLE) %>%
  unique()

cat("By region:\n")
cat("  National variables:", length(national_vars), "\n")
cat("  Regional variables:", length(regional_vars), "\n\n")

# Step 2: Check actual output
cat("================================================================================\n")
cat("Step 2: Check actual output coverage\n")
cat("--------------------------------------------------------------------------------\n")

output_file <- "E:/GCAM/GCAM-China_v8/output/database_basexdb_v8_test_standardized.csv"

if (!file.exists(output_file)) {
  cat("ERROR: Output file not found:", output_file, "\n")
  cat("Please run generate_report() first\n\n")
  quit(status = 1)
}

cat("Found output file\n")
cat("  File size:", round(file.info(output_file)$size / 1024^2, 1), "MB\n")
cat("  Modified:", format(file.info(output_file)$mtime), "\n\n")

cat("Reading output file (this may take a few seconds)...\n")
output_data <- read.csv(output_file, stringsAsFactors = FALSE)

cat("Successfully read\n")
cat("  Total rows:", format(nrow(output_data), big.mark = ","), "\n")
cat("  Columns:", ncol(output_data), "\n\n")

output_vars <- unique(output_data$Variable)
cat("Unique variables in output:", length(output_vars), "\n\n")

# Step 3: Calculate coverage
cat("================================================================================\n")
cat("Step 3: Calculate coverage\n")
cat("--------------------------------------------------------------------------------\n")

output_matched <- required_vars %in% output_vars
output_coverage <- sum(output_matched) / length(required_vars) * 100

cat("Actual output coverage:\n")
cat("  Matched variables:", sum(output_matched), "/", length(required_vars), "\n")
cat("  Coverage rate:", sprintf("%.1f%%", output_coverage), "\n\n")

# List missing variables
output_missing <- required_vars[!output_matched]
if (length(output_missing) > 0) {
  cat("Missing variables in output (", length(output_missing), "):\n")
  for (var in output_missing) {
    region_type <- ifelse(var %in% national_vars, "National", "Regional")
    cat("  -", var, "(", region_type, ")\n")
  }
  cat("\n")
} else {
  cat("SUCCESS: All GAINS variables are present in output!\n\n")
}

# Step 4: Analyze by category
cat("================================================================================\n")
cat("Step 4: Analyze by category\n")
cat("--------------------------------------------------------------------------------\n")

# National variables
national_matched <- national_vars %in% output_vars
national_coverage <- sum(national_matched) / length(national_vars) * 100

cat("National variables coverage:\n")
cat("  Matched:", sum(national_matched), "/", length(national_vars), "\n")
cat("  Coverage:", sprintf("%.1f%%", national_coverage), "\n")

if (sum(!national_matched) > 0) {
  cat("  Missing:\n")
  for (var in national_vars[!national_matched]) {
    cat("    -", var, "\n")
  }
}
cat("\n")

# Regional variables
regional_matched <- regional_vars %in% output_vars
regional_coverage <- sum(regional_matched) / length(regional_vars) * 100

cat("Regional variables coverage:\n")
cat("  Matched:", sum(regional_matched), "/", length(regional_vars), "\n")
cat("  Coverage:", sprintf("%.1f%%", regional_coverage), "\n")

if (sum(!regional_matched) > 0) {
  cat("  Missing:\n")
  for (var in regional_vars[!regional_matched]) {
    cat("    -", var, "\n")
  }
}
cat("\n")

# Step 5: Save detailed report
cat("================================================================================\n")
cat("Step 5: Save detailed report\n")
cat("--------------------------------------------------------------------------------\n")

comparison <- data.frame(
  Variable = required_vars,
  In_Output = required_vars %in% output_vars,
  Regional = ifelse(required_vars %in% national_vars, "National", "Regional"),
  stringsAsFactors = FALSE
)

comparison$Status <- ifelse(comparison$In_Output, "Covered", "Missing")

report_path <- "output/v8_gains_coverage_report.csv"
dir.create("output", showWarnings = FALSE, recursive = TRUE)
write.csv(comparison, report_path, row.names = FALSE)

cat("Detailed report saved to:\n")
cat("  ", report_path, "\n\n")

# Final summary
cat("================================================================================\n")
cat("FINAL SUMMARY\n")
cat("================================================================================\n\n")

cat("Total GAINS required variables:", length(required_vars), "\n")
cat("  - National:", length(national_vars), "\n")
cat("  - Regional:", length(regional_vars), "\n\n")

cat("Actual output coverage:\n")
cat("  Covered:", sum(output_matched), "\n")
cat("  Missing:", length(output_missing), "\n")
cat("  Total coverage:", sprintf("%.1f%%", output_coverage), "\n\n")

cat("Coverage by category:\n")
cat("  - National:", sprintf("%.1f%%", national_coverage), 
    "(", sum(national_matched), "/", length(national_vars), ")\n")
cat("  - Regional:", sprintf("%.1f%%", regional_coverage), 
    "(", sum(regional_matched), "/", length(regional_vars), ")\n\n")

# Evaluation
if (output_coverage >= 100) {
  cat("SUCCESS: 100% coverage of all GAINS variables!\n")
} else if (output_coverage >= 90) {
  cat("EXCELLENT: Output coverage >= 90%\n")
} else if (output_coverage >= 80) {
  cat("GOOD: Output coverage >= 80%\n")
} else {
  cat("WARNING: Output coverage < 80%, needs improvement\n")
}

cat("\n")
cat("================================================================================\n")
cat("Verification complete!\n")
cat("================================================================================\n\n")
