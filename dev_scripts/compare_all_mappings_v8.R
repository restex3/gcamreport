# System-wide comparison of GCAM 8.2 and GCAMChina 8.0 mappings
# This script identifies all missing mappings that need to be added

library(dplyr)
library(readr)

cat("=== GCAM 8.2 vs GCAMChina 8.0 Mapping Comparison ===\n\n")

base_82 <- "inst/extdata/mappings/GCAM8.2"
base_80 <- "inst/extdata/mappings/GCAMChina8.0"

# Get list of CSV files
files_82 <- list.files(base_82, pattern = "\\.csv$", full.names = FALSE)
files_80 <- list.files(base_80, pattern = "\\.csv$", full.names = FALSE)

# Files only in 8.2
only_82 <- setdiff(files_82, files_80)
if (length(only_82) > 0) {
  cat("Files only in GCAM 8.2 (", length(only_82), "):\n")
  cat(paste("  -", only_82), sep = "\n")
  cat("\n")
}

# Files only in 8.0
only_80 <- setdiff(files_80, files_82)
if (length(only_80) > 0) {
  cat("Files only in GCAMChina 8.0 (", length(only_80), "):\n")
  cat(paste("  -", only_80), sep = "\n")
  cat("\n")
}

# Compare common files
common_files <- intersect(files_82, files_80)
cat("Common files to compare:", length(common_files), "\n\n")

results <- list()
summary_data <- data.frame(
  file = character(),
  rows_82 = integer(),
  rows_80 = integer(),
  diff = integer(),
  status = character(),
  stringsAsFactors = FALSE
)

for (file in common_files) {
  tryCatch({
    df_82 <- read_csv(file.path(base_82, file), comment = "#", show_col_types = FALSE)
    df_80 <- read_csv(file.path(base_80, file), comment = "#", show_col_types = FALSE)

    rows_82 <- nrow(df_82)
    rows_80 <- nrow(df_80)
    diff <- rows_82 - rows_80

    # Determine status
    status <- if (diff == 0) {
      "✅ Equal"
    } else if (diff > 0) {
      if (diff <= 5) "⚠️ Small gap" else if (diff <= 50) "⚠️ Medium gap" else "🔴 Large gap"
    } else {
      "✅ China extended"
    }

    summary_data <- rbind(summary_data, data.frame(
      file = file,
      rows_82 = rows_82,
      rows_80 = rows_80,
      diff = diff,
      status = status,
      stringsAsFactors = FALSE
    ))

    # For files with missing rows, try to identify them
    if (diff > 0 && diff <= 100 && ncol(df_82) == ncol(df_80)) {
      # Try to find missing rows
      missing <- anti_join(df_82, df_80, by = names(df_82))

      if (nrow(missing) > 0) {
        results[[file]] <- list(
          file = file,
          rows_82 = rows_82,
          rows_80 = rows_80,
          diff = diff,
          missing_count = nrow(missing),
          missing_rows = missing
        )
      }
    }
  }, error = function(e) {
    cat("Error processing", file, ":", conditionMessage(e), "\n")
  })
}

# Sort by diff (descending)
summary_data <- summary_data %>% arrange(desc(abs(diff)))

# Print summary table
cat("\n=== Summary Table ===\n\n")
print(summary_data, n = Inf)

# Write detailed report
report_file <- "output/v8_missing_mappings_report.txt"
sink(report_file)

cat("=== GCAM 8.2 vs GCAMChina 8.0 Missing Mappings Report ===\n")
cat("Generated:", Sys.time(), "\n\n")

cat("=== Summary Statistics ===\n")
cat("Total common files:", length(common_files), "\n")
cat("Files with gaps (8.2 > 8.0):", sum(summary_data$diff > 0), "\n")
cat("Files equal:", sum(summary_data$diff == 0), "\n")
cat("Files extended in China:", sum(summary_data$diff < 0), "\n\n")

cat("=== Priority Files (gaps > 0) ===\n\n")
priority <- summary_data %>% filter(diff > 0) %>% arrange(desc(diff))
print(priority, n = Inf)

cat("\n\n=== Detailed Missing Rows ===\n\n")

for (result in results) {
  cat(sprintf("\n\n===============================================================================\n"))
  cat(sprintf("FILE: %s\n", result$file))
  cat(sprintf("===============================================================================\n\n"))
  cat(sprintf("GCAM 8.2 rows: %d\n", result$rows_82))
  cat(sprintf("GCAMChina 8.0 rows: %d\n", result$rows_80))
  cat(sprintf("Missing rows: %d\n\n", result$missing_count))

  cat("MISSING ROWS:\n")
  print(result$missing_rows, n = Inf)
  cat("\n")
}

sink()

cat("\n✅ Report saved to:", report_file, "\n")
cat("\n=== Priority Actions ===\n\n")

priority_files <- summary_data %>%
  filter(diff > 0, diff <= 50) %>%
  arrange(desc(diff))

if (nrow(priority_files) > 0) {
  cat("Files that should be updated (gap ≤ 50 rows):\n")
  for (i in 1:nrow(priority_files)) {
    cat(sprintf("  %d. %s (missing %d rows)\n",
                i, priority_files$file[i], priority_files$diff[i]))
  }
} else {
  cat("No priority files found.\n")
}

cat("\nFiles with large gaps (> 50 rows) - need manual review:\n")
large_gaps <- summary_data %>% filter(diff > 50)
if (nrow(large_gaps) > 0) {
  for (i in 1:nrow(large_gaps)) {
    cat(sprintf("  - %s (gap: %d rows)\n", large_gaps$file[i], large_gaps$diff[i]))
  }
} else {
  cat("  None\n")
}

cat("\n✅ Comparison complete!\n")
