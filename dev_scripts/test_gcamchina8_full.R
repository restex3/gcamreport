# Full test for GCAM-China V8 support
# Generated: 2026-04-28

library(gcamreport)

cat("=== Testing GCAM-China V8 Support ===\n\n")

# Test parameters
db_path <- "E:/GCAM/GCAM-China_v8/output/"
db_name <- "test1"
prj_name <- "gcamchina_v8_test.dat"
scenarios <- "reference"
GCAM_version <- "vGCAMChina8.0"

cat("Configuration:\n")
cat("  Database:", file.path(db_path, paste0(db_name, ".basex")), "\n")
cat("  Project:", prj_name, "\n")
cat("  Scenarios:", scenarios, "\n")
cat("  GCAM Version:", GCAM_version, "\n\n")

# Generate report
cat("Generating V8 report...\n")
start_time <- Sys.time()

tryCatch({
  report_v8 <- generate_report(
    db_path = db_path,
    db_name = db_name,
    prj_name = prj_name,
    scenarios = scenarios,
    GCAM_version = GCAM_version,
    final_year = 2100
  )
  
  end_time <- Sys.time()
  elapsed <- difftime(end_time, start_time, units = "mins")
  
  cat("\n=== Report Generation Successful ===\n")
  cat("Time elapsed:", round(elapsed, 2), "minutes\n\n")
  
  # Summary statistics
  cat("Report Summary:\n")
  cat("  Total rows:", nrow(report_v8), "\n")
  cat("  Unique variables:", length(unique(report_v8$Variable)), "\n")
  cat("  Unique regions:", length(unique(report_v8$Region)), "\n")
  cat("  Unique scenarios:", length(unique(report_v8$Scenario)), "\n")
  cat("  Year range:", min(report_v8$Year), "-", max(report_v8$Year), "\n\n")
  
  # Top variables by row count
  cat("Top 10 variables by row count:\n")
  var_counts <- report_v8 %>%
    group_by(Variable) %>%
    summarise(n = n(), .groups = "drop") %>%
    arrange(desc(n)) %>%
    head(10)
  print(var_counts)
  
  # Save outputs
  cat("\nSaving outputs...\n")
  save(report_v8, file = "output/gcamchina_v8_report.RData")
  write.csv(report_v8, "output/gcamchina_v8_report.csv", row.names = FALSE)
  cat("  - output/gcamchina_v8_report.RData\n")
  cat("  - output/gcamchina_v8_report.csv\n")
  
  # Variable list
  vars_v8 <- sort(unique(report_v8$Variable))
  writeLines(vars_v8, "output/gcamchina_v8_variables.txt")
  cat("  - output/gcamchina_v8_variables.txt\n")
  
  cat("\n=== Test Complete ===\n")
  
}, error = function(e) {
  cat("\n!!! ERROR !!!\n")
  cat("Message:", conditionMessage(e), "\n")
  cat("Call:", deparse(conditionCall(e)), "\n")
  stop(e)
})
