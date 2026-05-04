Sys.setlocale("LC_ALL", "Chinese")
java_path <- "C:/Program Files/Java/jre-1.8/bin"
Sys.setenv(PATH = paste(java_path, Sys.getenv("PATH"), sep = ";"))

library(gcamreport)

cat("=== V8 Full Test ===\n\n")

report <- generate_report(
  db_path = "E:/GCAM/GCAM-China_v8/output/",
  db_name = "database_basexdb",
  prj_name = "v8_test.dat",
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

cat("\nSaved:\n")
cat("  - output/v8_report.RData\n")
cat("  - output/v8_report.csv\n")
cat("  - output/v8_variables.txt\n")
