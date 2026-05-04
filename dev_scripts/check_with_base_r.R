# Use base R to read the file
cat("Reading output file with base R...\n")

# Read first few rows to check structure
sample <- read.csv("E:/GCAM/GCAM-China_v8/output/database_basexdb_v8_test_standardized.csv", 
                   nrows = 10, stringsAsFactors = FALSE)

cat("Column names:\n")
print(names(sample))
cat("\n")

cat("First few rows:\n")
print(head(sample[, 1:5], 3))
cat("\n")

# Now read just the Variable column
cat("Reading all Variable values...\n")
all_data <- read.csv("E:/GCAM/GCAM-China_v8/output/database_basexdb_v8_test_standardized.csv",
                     stringsAsFactors = FALSE)

out_vars <- unique(all_data$Variable)
cat("Total unique variables:", length(out_vars), "\n\n")

cat("First 30 variables:\n")
for (i in 1:min(30, length(out_vars))) {
  cat(sprintf("%2d. %s\n", i, out_vars[i]))
}

# Now check GAINS coverage
cat("\n\n=== Checking GAINS Coverage ===\n")
gains <- read.csv("E:/GCAM/GCAM_tools/gcam2gains/GCAM_GAINS_SEC_ACT_MAP_V8.csv",
                  stringsAsFactors = FALSE)
req <- unique(gains$SOURCE_VARIABLE[gains$SOURCE_VARIABLE != ""])

matched <- req %in% out_vars
cat("Required:", length(req), "\n")
cat("Matched:", sum(matched), "\n")
cat("Coverage:", sprintf("%.1f%%", sum(matched) / length(req) * 100), "\n")

if (sum(matched) > 0) {
  cat("\nMatched variables:\n")
  for (v in req[matched]) {
    cat("  +", v, "\n")
  }
}
