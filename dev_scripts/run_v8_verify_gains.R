# Run V8 report generation with latest code and verify GAINS coverage
Sys.setlocale("LC_ALL", "C")

# Load latest code (not installed version)
devtools::load_all(".", reset = TRUE, quiet = TRUE)

cat("=== Generating V8 report from database ===\n")
cat("DB: E:/GCAM/GCAM-China_v8/output/database_basexdb_v8_test.dat\n")
cat("Version: vGCAMChina8.0\n\n")

report <- generate_report(
  prj_name = "E:/GCAM/GCAM-China_v8/output/database_basexdb_v8_test.dat",
  scenarios = "Reference",
  GCAM_version = "vGCAMChina8.0",
  final_year = 2050
)

cat("\n=== Report generated ===\n")
cat("Variables:", length(unique(report$Variable)), "\n")
cat("Rows:", nrow(report), "\n")
cat("Regions:", paste(sort(unique(report$Region)), collapse = ", "), "\n")

# Save
dir.create("output", showWarnings = FALSE)
save(report, file = "output/v8_report_latest.RData")
write.csv(report, "output/v8_report_latest.csv", row.names = FALSE)
cat("\nSaved to output/v8_report_latest.RData and .csv\n")

# Verify GAINS coverage
cat("\n=== GAINS Coverage Verification ===\n")

gains_map <- read.csv("E:/GCAM/GCAM_tools/gcam2gains/GCAM_GAINS_SEC_ACT_MAP.csv",
                       stringsAsFactors = FALSE, fileEncoding = "UTF-8")
required_vars <- sort(unique(gains_map$SOURCE_VARIABLE))
available_vars <- unique(report$Variable)

covered <- intersect(required_vars, available_vars)
missing <- setdiff(required_vars, available_vars)
extra <- setdiff(available_vars, required_vars)

cat("Required GAINS SOURCE_VARIABLEs:", length(required_vars), "\n")
cat("Covered:", length(covered), "\n")
cat("Missing:", length(missing), "\n")
cat("Coverage:", sprintf("%.1f%%", 100 * length(covered) / length(required_vars)), "\n")

if (length(missing) > 0) {
  cat("\n!!! MISSING VARIABLES !!!\n")
  for (v in sort(missing)) {
    cat("  X ", v, "\n")
  }
} else {
  cat("\n*** ALL 81 GAINS VARIABLES COVERED ***\n")
}

# List all 81 GAINS variables and their status
cat("\n=== Complete GAINS variable status ===\n")
all_status <- data.frame(
  Variable = required_vars,
  Status = ifelse(required_vars %in% covered, "OK", "MISSING"),
  stringsAsFactors = FALSE
)
for (i in seq_len(nrow(all_status))) {
  cat(sprintf("  [%s] %s\n", all_status$Status[i], all_status$Variable[i]))
}

cat("\nDone.\n")
