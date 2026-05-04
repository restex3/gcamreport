# Check Non-Energy Use Biomass structure
output <- read.csv("E:/GCAM/GCAM_tools/gcamreport/output/tangrong_gains_latest.csv",
                    stringsAsFactors = FALSE)
vars <- unique(output$Variable)

# Find all Non-Energy Use variables ending with Biomass
bio_ne <- vars[grepl("Non-Energy Use", vars, fixed = TRUE) & grepl("Biomass", vars, fixed = TRUE)]
cat("=== All Non-Energy Use Biomass variables ===\n")
cat("Count:", length(bio_ne), "\n")
for (v in sort(bio_ne)) cat("  ", v, "\n")

# Check top-level Non-Energy Use fuel breakdown
cat("\n=== Check for expected top-level fuels ===\n")
expected <- c(
  "Final Energy|Non-Energy Use|Coal",
  "Final Energy|Non-Energy Use|Gas",
  "Final Energy|Non-Energy Use|Oil",
  "Final Energy|Non-Energy Use|Biomass",
  "Final Energy|Non-Energy Use|Solids",
  "Final Energy|Non-Energy Use|Gases",
  "Final Energy|Non-Energy Use|Liquids",
  "Final Energy|Non-Energy Use|Heat",
  "Final Energy|Non-Energy Use|Hydrogen",
  "Final Energy|Non-Energy Use|Electricity"
)
for (v in expected) {
  if (v %in% vars) {
    cat(sprintf("  [EXISTS]  %s\n", v))
  } else {
    cat(sprintf("  [MISSING] %s\n", v))
  }
}

# Check how many segments in each Non-Energy Use Biomass path
cat("\n=== Segment breakdown of Non-Energy Use Biomass paths ===\n")
for (v in sort(bio_ne)) {
  parts <- strsplit(v, "\\|")[[1]]
  cat(sprintf("  %d segments: %s\n", length(parts), v))
}

# Check one sample entry to see data values
cat("\n=== Sample data for one Biomass NE variable ===\n")
if (length(bio_ne) > 0) {
  sample_var <- bio_ne[1]
  sample_data <- output[output$Variable == sample_var, ]
  cat("Variable:", sample_var, "\n")
  cat("Rows:", nrow(sample_data), "\n")
  cat("Regions:", paste(unique(sample_data$Region), collapse=", "), "\n")
  # Sum across all regions to check if data is non-zero
  yr_cols <- grep("^X?[0-9]{4}$", colnames(output), value = TRUE)
  if (length(yr_cols) > 0) {
    total <- sum(sample_data[[yr_cols[1]]], na.rm = TRUE)
    cat(sprintf("Sum of %s: %g\n", yr_cols[1], total))
  }
}

# Check Oil w/ CCS comprehensively
cat("\n=== Oil CCS check ===\n")
oil_ccs_all <- vars[grepl("Oil", vars, fixed = TRUE) & grepl("CCS", vars, fixed = TRUE)]
cat("All Oil CCS variables:", length(oil_ccs_all), "\n")
for (v in oil_ccs_all) cat("  ", v, "\n")

# Check Primary Energy|Electricity structure for all fuels
cat("\n=== Primary Energy|Electricity|*|w/ CCS status ===\n")
pe_ccs <- vars[grepl("Primary Energy", vars, fixed = TRUE) & grepl("Electricity", vars, fixed = TRUE) & grepl("w/ CCS", vars, fixed = TRUE)]
cat("Existing PE|Elec|*|w/ CCS:\n")
for (v in pe_ccs) cat("  ", v, "\n")

pe_noccs <- vars[grepl("Primary Energy", vars, fixed = TRUE) & grepl("Electricity", vars, fixed = TRUE) & grepl("w/o CCS", vars, fixed = TRUE)]
cat("\nExisting PE|Elec|*|w/o CCS:\n")
for (v in pe_noccs) cat("  ", v, "\n")
