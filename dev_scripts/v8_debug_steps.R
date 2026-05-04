Sys.setlocale("LC_ALL", "Chinese")
devtools::load_all(".", reset = TRUE)

cat("=== V8 Debug Step by Step ===\n\n")

cat("Step 1: Load project...\n")
prj <- rgcam::loadProject("E:/GCAM/GCAM-China_v8/output/database_basexdb_v8_test.dat")
cat("  ✅ Project loaded\n")
cat("  Scenarios:", rgcam::listScenarios(prj), "\n\n")

cat("Step 2: Get template...\n")
template <- get("template_vGCAMChina8.0")
cat("  ✅ Template loaded, rows:", nrow(template), "\n\n")

cat("Step 3: Get var_fun_map...\n")
var_fun_map <- get("var_fun_map_vGCAMChina8.0")
cat("  ✅ var_fun_map loaded, rows:", nrow(var_fun_map), "\n\n")

cat("Step 4: Try data_query (first query)...\n")
tryCatch({
  result <- data_query(
    prj = prj,
    query_name = "GDP by region",
    GCAM_version = "vGCAMChina8.0"
  )
  cat("  ✅ data_query works, rows:", nrow(result), "\n\n")
}, error = function(e) {
  cat("  ❌ ERROR:", conditionMessage(e), "\n\n")
})

cat("Step 5: Try full generate_report with verbose...\n")
options(warn = 1)  # Print warnings immediately
tryCatch({
  report <- generate_report(
    prj_name = "E:/GCAM/GCAM-China_v8/output/database_basexdb_v8_test.dat",
    scenarios = "Reference",
    GCAM_version = "vGCAMChina8.0",
    final_year = 2050
  )
  cat("\n✅ SUCCESS!\n")
  cat("Variables:", length(unique(report$Variable)), "\n")
}, error = function(e) {
  cat("\n❌ ERROR:", conditionMessage(e), "\n")
  traceback()
})
