library(gcamreport)

# Load project
prj <- rgcam::loadProject('E:/GCAM/GCAM-China_v8/output/database_basexdb_v8_test.dat')
prj <<- prj

# Set desired_variables.global
desired_variables.global <<- c("Primary Energy")

cat("=== Step 1: Test get_primary_energy_electricity ===\n")
tryCatch({
  get_primary_energy_electricity('vGCAMChina8.0')
  cat("SUCCESS! Generated", nrow(primary_energy_electricity_clean), "rows\n")
  cat("Variables:\n")
  print(unique(primary_energy_electricity_clean$var))
}, error = function(e) {
  cat("ERROR:", conditionMessage(e), "\n")
})

cat("\n=== Step 2: Test get_primary_energy ===\n")
tryCatch({
  get_primary_energy('vGCAMChina8.0')
  cat("SUCCESS! Generated", nrow(primary_energy_clean), "rows\n")
  cat("Sample variables:\n")
  print(head(unique(primary_energy_clean$var), 20))
}, error = function(e) {
  cat("ERROR:", conditionMessage(e), "\n")
  cat("Traceback:\n")
  print(sys.calls())
})
