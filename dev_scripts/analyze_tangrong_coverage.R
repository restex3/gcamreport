suppressPackageStartupMessages({
  library(dplyr)
})

mapping_file <- "E:/GCAM/GCAM_tools/gcam2gains/GCAM_GAINS_SEC_ACT_MAP.csv"
input_file <- "E:/GCAM/GCAM_tools/gcamreport/output/tangrong_gains_latest.csv"
report_file <- "E:/GCAM/GCAM_tools/gcamreport/output/tangrong_coverage_report.txt"
expected_missing <- c(
  "Final Energy|Non-Energy Use|Biomass",
  "Primary Energy|Electricity|Oil|w/ CCS"
)

if (!file.exists(mapping_file)) {
  stop(sprintf("Mapping file not found: %s", mapping_file))
}

if (!file.exists(input_file)) {
  stop(sprintf("Tangrong upstream file not found: %s", input_file))
}

gains_map <- read.csv(mapping_file, stringsAsFactors = FALSE)
required_vars <- sort(unique(gains_map$SOURCE_VARIABLE))

output <- read.csv(input_file, stringsAsFactors = FALSE)
available_vars <- sort(unique(output$Variable))

matched_vars <- intersect(required_vars, available_vars)
missing_vars <- sort(setdiff(required_vars, available_vars))
coverage_pct <- 100 * length(matched_vars) / length(required_vars)
expected_ok <- identical(missing_vars, sort(expected_missing))

lines <- c(
  "=== TANGRONG COVERAGE REPORT ===",
  sprintf("timestamp=%s", format(Sys.time(), "%Y-%m-%d %H:%M:%S")),
  sprintf("input_file=%s", input_file),
  sprintf("mapping_file=%s", mapping_file),
  sprintf("required_total=%d", length(required_vars)),
  sprintf("matched_total=%d", length(matched_vars)),
  sprintf("missing_total=%d", length(missing_vars)),
  sprintf("coverage_pct=%.1f", coverage_pct),
  sprintf("expected_missing_only=%s", ifelse(expected_ok, "TRUE", "FALSE")),
  "",
  "Missing variables:"
)

if (length(missing_vars) == 0) {
  lines <- c(lines, "  <none>")
} else {
  lines <- c(lines, paste0("  - ", missing_vars))
}

writeLines(lines, report_file)
cat(paste(lines, collapse = "\n"))
cat("\n")

if (length(matched_vars) != 79 || length(required_vars) != 81 || !expected_ok) {
  stop("Tangrong coverage regression failed.")
}
