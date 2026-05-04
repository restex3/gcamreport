# GCAM-China V7.1 vs V8.0 Mapping Difference Analysis
# Generated: 2026-04-28

library(dplyr)
library(readr)

base_path <- "E:/GCAM/GCAM_tools/gcamreport/inst/extdata/mappings"

# Files with differences
diff_files <- c(
  "ag_production_map.csv",
  "primary_energy_map.csv", 
  "final_energy_map_gcamchina.csv",
  "production_map.csv"
)

cat("=== GCAM-China V7.1 vs V8.0 Mapping Difference Analysis ===\n\n")

for (file in diff_files) {
  cat("\n", strrep("=", 80), "\n")
  cat("FILE:", file, "\n")
  cat(strrep("=", 80), "\n\n")
  
  v71_path <- file.path(base_path, "GCAMChina7.1", file)
  v8_path <- file.path(base_path, "GCAMChina8.0", file)
  
  v71 <- read_csv(v71_path, show_col_types = FALSE)
  v8 <- read_csv(v8_path, show_col_types = FALSE)
  
  cat("V7.1 rows:", nrow(v71), "\n")
  cat("V8.0 rows:", nrow(v8), "\n")
  cat("Difference:", nrow(v8) - nrow(v71), "\n\n")
  
  # Find removed rows
  if (ncol(v71) > 0 && ncol(v8) > 0) {
    key_col <- names(v71)[1]
    removed <- anti_join(v71, v8, by = key_col)
    added <- anti_join(v8, v71, by = key_col)
    
    if (nrow(removed) > 0) {
      cat("REMOVED in V8 (", nrow(removed), " rows):\n", sep = "")
      print(removed, n = 20)
      cat("\n")
    }
    
    if (nrow(added) > 0) {
      cat("ADDED in V8 (", nrow(added), " rows):\n", sep = "")
      print(added, n = 20)
      cat("\n")
    }
    
    if (nrow(removed) == 0 && nrow(added) == 0) {
      cat("No key differences found (possible value changes only)\n\n")
    }
  }
}

cat("\n", strrep("=", 80), "\n")
cat("Analysis complete\n")
cat(strrep("=", 80), "\n")
