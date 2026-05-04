# Verify GAINS variable coverage in latest output
# Run: Rscript --encoding=UTF-8 dev_scripts/verify_gains_coverage.R

# Load GAINS requirements
gains_map <- read.csv("E:/GCAM/GCAM_tools/gcam2gains/GCAM_GAINS_SEC_ACT_MAP.csv",
                       stringsAsFactors = FALSE, fileEncoding = "UTF-8")
required_vars <- sort(unique(gains_map$SOURCE_VARIABLE))
required_det <- sort(unique(gains_map$SOURCE_VARIABLE_DET))

cat("=== GAINS REQUIREMENT FILE ===\n")
cat("Total rows:", nrow(gains_map), "\n")
cat("Unique SOURCE_VARIABLEs:", length(required_vars), "\n")
cat("Unique SOURCE_VARIABLE_DETs:", length(required_det), "\n\n")

# Load outputs
latest_files <- c(
  "tangrong_gains_latest.csv"  = "E:/GCAM/GCAM_tools/gcamreport/output/tangrong_gains_latest.csv",
  "gains_final_v3.csv"         = "E:/GCAM/GCAM_tools/gcamreport/output/gains_final_v3.csv"
)

for (i in seq_along(latest_files)) {
  csv_path <- latest_files[i]
  label <- names(latest_files)[i]

  output <- read.csv(csv_path, stringsAsFactors = FALSE, check.names = FALSE)
  available_vars <- unique(output$Variable)

  cat("=== OUTPUT:", label, "===\n")
  cat("Total rows:", nrow(output), "\n")
  cat("Unique variables:", length(available_vars), "\n\n")

  # Coverage by SOURCE_VARIABLE
  covered <- intersect(required_vars, available_vars)
  missing <- setdiff(required_vars, available_vars)

  cat("--- SOURCE_VARIABLE Coverage ---\n")
  cat("Required:", length(required_vars), "\n")
  cat("Covered:", length(covered), "\n")
  cat("Missing:", length(missing), "\n")
  cat("Rate:", sprintf("%.1f%%", 100 * length(covered) / length(required_vars)), "\n\n")

  if (length(missing) > 0) {
    cat("--- MISSING SOURCE_VARIABLEs ---\n")
    for (v in sort(missing)) {
      deps <- gains_map[gains_map$SOURCE_VARIABLE == v, ]
      secs <- unique(deps$SEC_ABB)
      acts <- unique(deps$ACT_ABB)
      cat(sprintf("  X %-60s [SEC: %-20s] [ACT: %s]\n",
                  v, paste(secs, collapse=","), paste(acts, collapse=",")))
    }
    cat("\n")
  }

  # Coverage by SOURCE_VARIABLE_DET
  covered_det <- intersect(required_det, available_vars)
  missing_det <- setdiff(required_det, available_vars)

  cat("--- SOURCE_VARIABLE_DET Coverage ---\n")
  cat("Required DET:", length(required_det), "\n")
  cat("Covered DET:", length(covered_det), "\n")
  cat("Missing DET:", length(missing_det), "\n")
  cat("Rate:", sprintf("%.1f%%", 100 * length(covered_det) / length(required_det)), "\n\n")

  if (length(missing_det) > 0) {
    cat("--- MISSING SOURCE_VARIABLE_DETs ---\n")
    for (v in sort(missing_det)) {
      deps <- gains_map[gains_map$SOURCE_VARIABLE_DET == v, ]
      src_var <- unique(deps$SOURCE_VARIABLE)
      secs <- unique(deps$SEC_ABB)
      acts <- unique(deps$ACT_ABB)
      cat(sprintf("  X %-60s <- %-40s [SEC: %s]\n",
                  v, paste(src_var, collapse=", "), paste(secs, collapse=",")))
    }
    cat("\n")
  }
}

# Category summary of missing SOURCE_VARIABLEs
cat("\n=== CATEGORY BREAKDOWN OF MISSING SOURCE_VARIABLEs ===\n\n")

# Check against latest
output <- read.csv(latest_files["tangrong_gains_latest.csv"], stringsAsFactors = FALSE, check.names = FALSE)
available_vars <- unique(output$Variable)
missing <- setdiff(required_vars, available_vars)

categories <- list(
  "Primary Energy Convert"    = grep("Convert", missing, value = TRUE),
  "Primary Energy Elec CCS"   = grep("w/ CCS", missing, value = TRUE),
  "Primary Energy Elec noCCS" = grep("w/o CCS", missing, value = TRUE),
  "Primary Energy Liquids"    = grep("Liquids", missing, value = TRUE),
  "Non-Energy Use"            = grep("Non-Energy Use", missing, value = TRUE),
  "Transportation"            = grep("Transportation", missing, value = TRUE),
  "Residential & Commercial"  = grep("Residential and Commercial", missing, value = TRUE),
  "Feedstock"                 = grep("Feedstock", missing, value = TRUE),
  "Land Cover"                = grep("Land Cover", missing, value = TRUE),
  "Production"                = grep("Production", missing, value = TRUE),
  "Final Energy|Industry"     = grep("Final Energy", missing, value = TRUE),
  "GDP|MER"                   = grep("GDP", missing, value = TRUE),
  "Secondary Energy"          = grep("Secondary Energy", missing, value = TRUE),
  "Resource Extraction"       = grep("Resource", missing, value = TRUE),
  "Population"                = grep("Population", missing, value = TRUE),
  "Agricultural Production"   = grep("Agricultural Production", missing, value = TRUE),
  "Final Energy|Heat"         = grep("Heat", missing, value = TRUE)
)

for (cat_name in names(categories)) {
  vars <- categories[[cat_name]]
  if (length(vars) > 0) {
    cat(sprintf("  [%s] (%d):\n", cat_name, length(vars)))
    for (v in vars) cat("    - ", v, "\n")
    cat("\n")
  }
}

# Fallback: show any uncategorized
all_categorized <- unique(unlist(categories))
uncat <- setdiff(missing, all_categorized)
if (length(uncat) > 0) {
  cat(sprintf("  [UNCATEGORIZED] (%d):\n", length(uncat)))
  for (v in uncat) cat("    - ", v, "\n")
  cat("\n")
}

cat("Done.\n")
