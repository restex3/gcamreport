# Test gcamreport with GCAM China 8.0 database
library(gcamreport)

db_path <- "E:/GCAM/GCAM-China_v8/output"
db_name <- "database_basexdb"

cat("Connecting to database...\n")
cat("  db_path:", db_path, "\n")
cat("  db_name:", db_name, "\n")

# First, check available scenarios
tryCatch({
  conn <- rgcam::localDBConn(db_path, db_name)
  scenarios <- rgcam::listScenarios(conn)
  cat("\nAvailable scenarios:\n")
  for(s in scenarios) cat("  ", s, "\n")
}, error = function(e) {
  cat("Error listing scenarios:", e$message, "\n")
})

# Test generate_report
cat("\nGenerating report...\n")
cat("Note: using queries_general_vGCAMChina8.0 with V8 XPath updates\n")

tryCatch({
  generate_report(
    db_path = db_path,
    db_name = db_name,
    prj_name = "test_v8_full_new.proj",
    scenarios = scenarios[1],  # Use first available scenario
    desired_regions = "China",
    GCAM_version = "vGCAMChina8.0",
    save_output = FALSE,
    launch_ui = FALSE
  )
  cat("\nReport generation complete!\n")
}, error = function(e) {
  cat("\nError during report generation:", e$message, "\n")
  cat("Traceback:\n")
  traceback()
})
