Sys.setlocale("LC_ALL", "C")  # Use C locale
options(encoding = "UTF-8")

devtools::load_all(".", reset = TRUE, quiet = TRUE)

cat("=== V8 Debug (C locale) ===\n\n")

dat_path <- "E:/GCAM/GCAM-China_v8/output/database_basexdb_v8_test.dat"
cat("DAT path:", dat_path, "\n")
cat("File exists:", file.exists(dat_path), "\n\n")

cat("Step 1: Load project...\n")
tryCatch({
  prj <- rgcam::loadProject(dat_path)
  cat("  ✅ Loaded\n")
  cat("  Scenarios:", rgcam::listScenarios(prj), "\n\n")
  
  cat("Step 2: Generate report...\n")
  report <- generate_report(
    prj_name = dat_path,
    scenarios = "Reference",
    GCAM_version = "vGCAMChina8.0",
    final_year = 2050
  )
  
  cat("\n✅ SUCCESS!\n")
  cat("Variables:", length(unique(report$Variable)), "\n")
  cat("Rows:", nrow(report), "\n")
  
  save(report, file = "output/v8_report.RData")
  write.csv(report, "output/v8_report.csv", row.names = FALSE)
  cat("\nSaved!\n")
  
}, error = function(e) {
  cat("\n❌ ERROR:", conditionMessage(e), "\n")
  print(e)
})
