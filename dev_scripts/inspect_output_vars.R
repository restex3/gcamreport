# Check what variables are actually in the output
library(data.table)

cat("Reading output file...\n")
out <- fread("E:/GCAM/GCAM-China_v8/output/database_basexdb_v8_test_standardized.csv", 
             select = "Variable", showProgress = FALSE)

out_vars <- unique(out$Variable)
cat("Total unique variables in output:", length(out_vars), "\n\n")

cat("First 50 variables:\n")
cat("-------------------\n")
for (i in 1:min(50, length(out_vars))) {
  cat(i, ".", out_vars[i], "\n")
}

cat("\n\nSearching for GAINS-related patterns...\n")
cat("----------------------------------------\n")

# Search for key patterns
patterns <- c(
  "Land Cover",
  "Agricultural Production",
  "Livestock",
  "Population",
  "Final Energy.*Residential",
  "Final Energy.*Industry",
  "Production.*Chemicals",
  "Production.*Steel",
  "Production.*Cement",
  "Resource.*Extraction",
  "Transportation"
)

for (pattern in patterns) {
  matches <- grep(pattern, out_vars, value = TRUE, ignore.case = TRUE)
  if (length(matches) > 0) {
    cat("\nPattern '", pattern, "' found ", length(matches), " matches:\n", sep = "")
    for (m in head(matches, 5)) {
      cat("  -", m, "\n")
    }
    if (length(matches) > 5) {
      cat("  ... and", length(matches) - 5, "more\n")
    }
  } else {
    cat("\nPattern '", pattern, "': NO MATCHES\n", sep = "")
  }
}
