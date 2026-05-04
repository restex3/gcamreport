Sys.setlocale("LC_ALL", "Chinese")

# Add Java to PATH
java_path <- "C:/Program Files/Java/jre-1.8/bin"
Sys.setenv(PATH = paste(java_path, Sys.getenv("PATH"), sep = ";"))

library(gcamreport)

cat("=== V8 Test with Java PATH fixed ===\n\n")

cat("Step 1: Connecting to database...\n")
prj <- rgcam::localDBConn(
  dbPath = "E:/GCAM/GCAM-China_v8/output/",
  dbFile = "database_basexdb"
)

cat("Step 2: List scenarios...\n")
scenarios <- rgcam::listScenarios(prj)
print(scenarios)

cat("\nStep 3: Generate report...\n")
report <- generate_report(
  prj = prj,
  scenarios = scenarios[1],
  GCAM_version = "vGCAMChina8.0",
  final_year = 2050
)

cat("\n✅ SUCCESS!\n")
cat("Variables:", length(unique(report$Variable)), "\n")
cat("Rows:", nrow(report), "\n")

save(report, file = "output/v8_test_success.RData")
writeLines(sort(unique(report$Variable)), "output/v8_variables.txt")
