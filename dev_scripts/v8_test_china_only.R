Sys.setlocale("LC_ALL", "C")
options(encoding = "UTF-8")

devtools::load_all(".", reset = TRUE, quiet = TRUE)

cat("=== V8 Test (China only) ===\n\n")

dat_path <- "E:/GCAM/GCAM-China_v8/output/database_basexdb_v8_test.dat"

cat("Generating report for China region only...\n")
tryCatch({
  report <- generate_report(
    prj_name = dat_path,
    scenarios = "Reference",
    GCAM_version = "vGCAMChina8.0",
    final_year = 2050,
    reg_cont = data.frame(region = "China", continent = "Asia")  # Only China
  )
  
  cat("\n✅ SUCCESS!\n")
  cat("Variables:", length(unique(report$Variable)), "\n")
  cat("Rows:", nrow(report), "\n")
  cat("Regions:", unique(report$Region), "\n\n")
  
  save(report, file = "output/v8_report.RData")
  write.csv(report, "output/v8_report.csv", row.names = FALSE)
  writeLines(sort(unique(report$Variable)), "output/v8_variables.txt")
  
  cat("Saved to output/\n")
  
}, error = function(e) {
  cat("\n❌ ERROR:", conditionMessage(e), "\n")
  print(e)
})
