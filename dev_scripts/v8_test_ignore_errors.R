Sys.setlocale("LC_ALL", "C")
devtools::load_all(".", reset = TRUE, quiet = TRUE)

cat("=== V8 Test (ignore Ukraine error) ===\n\n")

dat_path <- "E:/GCAM/GCAM-China_v8/output/database_basexdb_v8_test.dat"

cat("Generating report (will ignore mapping errors)...\n")
options(warn = -1)  # Suppress warnings

tryCatch({
  report <- generate_report(
    prj_name = dat_path,
    scenarios = "Reference",
    GCAM_version = "vGCAMChina8.0",
    final_year = 2050
  )
  
  cat("\n✅ SUCCESS!\n")
  cat("Variables:", length(unique(report$Variable)), "\n")
  cat("Rows:", nrow(report), "\n")
  cat("Regions:", paste(unique(report$Region), collapse = ", "), "\n\n")
  
  save(report, file = "output/v8_report.RData")
  write.csv(report, "output/v8_report.csv", row.names = FALSE)
  writeLines(sort(unique(report$Variable)), "output/v8_variables.txt")
  
  cat("Saved!\n")
  
}, error = function(e) {
  cat("\n❌ FATAL ERROR:", conditionMessage(e), "\n")
})
