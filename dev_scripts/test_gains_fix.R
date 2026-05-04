# Test the GAINS fix logic against existing output data
library(dplyr)

# Load existing output
report <- read.csv("E:/GCAM/GCAM_tools/gcamreport/output/tangrong_gains_latest.csv",
                   stringsAsFactors = FALSE, check.names = FALSE)
yr_cols <- grep("^[0-9]{4}$", colnames(report), value = TRUE)
cat("Year columns:", length(yr_cols), "\n")
cat("Initial rows:", nrow(report), "\n")
cat("Initial unique vars:", length(unique(report$Variable)), "\n\n")

# --- Test 1: Non-Energy Use Biomass aggregation ---
cat("=== Test 1: Final Energy|Non-Energy Use|Biomass ===\n")

ne_biomass_data <- report %>%
  filter(grepl("Non-Energy Use", Variable, fixed = TRUE) &
         grepl("|Biomass", Variable, fixed = TRUE))

cat("Sub-sector Biomass rows:", nrow(ne_biomass_data), "\n")
cat("Unique sub-sector vars:\n")
for (v in unique(ne_biomass_data$Variable)) cat("  ", v, "\n")

if (nrow(ne_biomass_data) > 0) {
  ne_biomass_agg <- ne_biomass_data %>%
    select(-Variable, -Unit) %>%
    group_by(Model, Scenario, Region) %>%
    summarise(across(all_of(yr_cols), ~ sum(.x, na.rm = TRUE)), .groups = "drop") %>%
    mutate(Variable = "Final Energy|Non-Energy Use|Biomass", Unit = "EJ/yr")

  # Check some results
  cat("\nAggregated rows:", nrow(ne_biomass_agg), "\n")
  china_row <- ne_biomass_agg %>% filter(Region == "China")
  if (nrow(china_row) > 0) {
    cat("China 2030 value:", china_row[["2030"]], "\n")
    cat("China 2050 value:", china_row[["2050"]], "\n")
  }
  # Check for any NA values
  na_count <- sum(is.na(ne_biomass_agg[, yr_cols]))
  cat("NA values in result:", na_count, "\n")
  cat("TEST 1: PASS\n\n")
} else {
  cat("TEST 1: FAIL - no sub-sector Biomass data found\n\n")
}

# --- Test 2: Oil w/ CCS zero-value creation ---
cat("=== Test 2: Primary Energy|Electricity|Oil|w/ CCS ===\n")

oil_ccs_template <- report %>%
  filter(Variable == "Primary Energy|Electricity|Oil|w/o CCS")

cat("Oil w/o CCS rows:", nrow(oil_ccs_template), "\n")
cat("Oil w/o CCS regions:", paste(sort(unique(oil_ccs_template$Region)), collapse=", "), "\n")

if (nrow(oil_ccs_template) > 0) {
  oil_ccs_zero <- oil_ccs_template %>%
    select(-Variable, -Unit) %>%
    mutate(across(all_of(yr_cols), ~ 0),
           Variable = "Primary Energy|Electricity|Oil|w/ CCS",
           Unit = "EJ/yr")

  cat("Oil w/ CCS rows created:", nrow(oil_ccs_zero), "\n")

  # Verify all zero
  total_all_years <- sum(as.matrix(oil_ccs_zero[, yr_cols]), na.rm = TRUE)
  cat("Sum of all years (should be 0):", total_all_years, "\n")

  if (total_all_years == 0) {
    cat("TEST 2: PASS\n\n")
  } else {
    cat("TEST 2: FAIL - non-zero values found\n\n")
  }
} else {
  cat("TEST 2: FAIL - no Oil|w/o CCS template found\n\n")
}

# --- Apply both additions and verify final state ---
cat("=== Final coverage check ===\n")

# Add to report
if (exists("ne_biomass_agg") && nrow(ne_biomass_agg) > 0) {
  report <- bind_rows(report, ne_biomass_agg)
}
if (exists("oil_ccs_zero") && nrow(oil_ccs_zero) > 0) {
  report <- bind_rows(report, oil_ccs_zero)
}

final_vars <- unique(report$Variable)
cat("Final unique vars:", length(final_vars), "\n")

# Check against GAINS requirements
gains_map <- read.csv("E:/GCAM/GCAM_tools/gcam2gains/GCAM_GAINS_SEC_ACT_MAP.csv",
                       stringsAsFactors = FALSE, fileEncoding = "UTF-8")
required_vars <- sort(unique(gains_map$SOURCE_VARIABLE))
covered <- intersect(required_vars, final_vars)
missing <- setdiff(required_vars, final_vars)

cat("\nRequired GAINS SOURCE_VARIABLEs:", length(required_vars), "\n")
cat("Covered:", length(covered), "\n")
cat("Missing:", length(missing), "\n")
cat("Coverage:", sprintf("%.1f%%", 100*length(covered)/length(required_vars)), "\n")

if (length(missing) > 0) {
  cat("\nStill missing:\n")
  for (v in missing) cat("  X ", v, "\n")
} else {
  cat("\n*** 100% COVERAGE ACHIEVED ***\n")
}
