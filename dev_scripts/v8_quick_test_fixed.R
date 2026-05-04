# Quick V8 test with encoding fix
Sys.setlocale("LC_ALL", "Chinese")
options(encoding = "UTF-8")

library(gcamreport)

cat("=== Quick V8 Test (Encoding Fixed) ===\n\n")

db_path <- "E:/GCAM/GCAM-China_v8/output/"
db_name <- "database_basexdb"
prj_name <- "v8_quick_test.dat"

cat("Locale:", Sys.getlocale(), "\n")
cat("Testing with:", db_name, "\n\n")

tryCatch({
  report <- generate_report(
    db_path = db_path,
    db_name = db_name,
    prj_name = prj_name,
    scenarios = NULL,
    GCAM_version = "vGCAMChina8.0",
    final_year = 2050
  )
  
  cat("\n✅ SUCCESS!\n")
  cat("Variables:", length(unique(report$Variable)), "\n")
  cat("Rows:", nrow(report), "\n")
  
  save(report, file = "output/v8_quick_test.RData")
  writeLines(sort(unique(report$Variable)), "output/v8_quick_test_variables.txt")
  
}, error = function(e) {
  cat("\n❌ ERROR:", conditionMessage(e), "\n")
  traceback()
})
