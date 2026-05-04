Sys.setlocale("LC_ALL", "Chinese")
library(gcamreport)

cat("Step 1: Loading project...\n")
prj <- tryCatch({
  rgcam::localDBConn(
    dbPath = "E:/GCAM/GCAM-China_v8/output/",
    dbFile = "database_basexdb"
  )
}, error = function(e) {
  cat("ERROR in localDBConn:", conditionMessage(e), "\n")
  NULL
})

if (!is.null(prj)) {
  cat("Step 2: List scenarios...\n")
  scenarios <- rgcam::listScenarios(prj)
  print(scenarios)
  
  cat("\nStep 3: List queries...\n")
  queries <- rgcam::listQueries(prj)
  print(head(queries, 20))
  
  cat("\nStep 4: Test one query...\n")
  test_data <- rgcam::getQuery(prj, "GDP by region")
  cat("Rows:", nrow(test_data), "\n")
  print(head(test_data))
}
