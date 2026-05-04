Sys.setlocale("LC_ALL", "Chinese")
devtools::load_all(".", reset = TRUE)

cat("=== V8 Test from DAT file ===\n\n")

report <- generate_report(
  prj_name = "E:/GCAM/GCAM-China_v8/output/database_basexdb_v8_test.dat",
  scenarios = "Reference",
  GCAM_version = "vGCAMChina8.0",
  final_year = 2050
)

cat("\n✅ SUCCESS!\n")
cat("Variables:", length(unique(report$Variable)), "\n")
cat("Rows:", nrow(report), "\n")

save(report, file = "output/v8_report.RData")
write.csv(report, "output/v8_report.csv", row.names = FALSE)
writeLines(sort(unique(report$Variable)), "output/v8_variables.txt")
cat("\nSaved!\n")
