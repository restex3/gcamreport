# Test Agriculture Allocation Algorithms

# Setup paths
repo_dir <- "E:/GCAM/GCAM_tools/gcamreport"
db_path <- "E:/GCAM/GCAM-China_v7.1/output"
db_name <- "China60Ref"
project_file <- file.path(db_path, paste0(db_name, "_gcamreport_China60ref.dat"))

# Load package
suppressWarnings(devtools::load_all(repo_dir, quiet = TRUE))

# Load project
cat("Loading project...\n")
prj <- rgcam::loadProject(project_file)

# Test 1: Crop production allocation
cat("\n=== Testing Crop Production Allocation ===\n")
tryCatch({
  crop_provincial <- allocate_crop_production(prj, "China60ref")

  cat("\nCrop allocation completed!\n")
  cat("Number of rows:", nrow(crop_provincial), "\n")
  cat("Crops:", length(unique(crop_provincial$crop)), "\n")
  cat("Provinces:", length(unique(crop_provincial$region)), "\n")
  cat("Years:", paste(range(crop_provincial$year), collapse=" - "), "\n")

  cat("\nSample data:\n")
  print(head(crop_provincial, 5))

  # Validate allocation
  cat("\n--- Validation Results ---\n")
  validation <- validate_crop_allocation(crop_provincial)
  cat(sprintf("Max relative error: %.6f (%.4f%%)\n",
              validation$max_relative_error,
              validation$max_relative_error * 100))
  cat(sprintf("Mean relative error: %.6f (%.4f%%)\n",
              validation$mean_relative_error,
              validation$mean_relative_error * 100))
  cat(sprintf("Number of crops: %d\n", validation$n_crops))
  cat(sprintf("Number of provinces: %d\n", validation$n_provinces))
  cat(sprintf("Number of years: %d\n", validation$n_years))
  cat(sprintf("Missing allocations: %d\n", validation$n_missing))
  cat(sprintf("Validation passed: %s\n", validation$is_valid))

  if (validation$n_missing > 0) {
    cat("\nMissing crops:\n")
    print(validation$missing_crops)
  }

  # Show validation table for a few crops
  cat("\nValidation table (first 10 rows):\n")
  print(head(validation$validation_table, 10))

  # Summary for 2020
  cat("\n--- Production Summary for 2020 ---\n")
  summary_2020 <- summarize_crop_production(crop_provincial, 2020)
  print(head(summary_2020, 10))

}, error = function(e) {
  cat("Error in crop allocation:", e$message, "\n")
  cat("Traceback:\n")
  print(traceback())
})

# Test 2: Livestock production allocation
cat("\n\n=== Testing Livestock Production Allocation ===\n")
tryCatch({
  livestock_provincial <- allocate_livestock_production(prj, "China60ref")

  cat("\nLivestock allocation completed!\n")
  cat("Number of rows:", nrow(livestock_provincial), "\n")
  cat("Livestock products:", length(unique(livestock_provincial$livestock)), "\n")
  cat("Provinces:", length(unique(livestock_provincial$region)), "\n")
  cat("Years:", paste(range(livestock_provincial$year), collapse=" - "), "\n")

  cat("\nSample data:\n")
  print(head(livestock_provincial, 5))

  # Validate allocation
  cat("\n--- Validation Results ---\n")
  validation <- validate_livestock_allocation(livestock_provincial)
  cat(sprintf("Max relative error: %.6f (%.4f%%)\n",
              validation$max_relative_error,
              validation$max_relative_error * 100))
  cat(sprintf("Mean relative error: %.6f (%.4f%%)\n",
              validation$mean_relative_error,
              validation$mean_relative_error * 100))
  cat(sprintf("Number of livestock: %d\n", validation$n_livestock))
  cat(sprintf("Number of provinces: %d\n", validation$n_provinces))
  cat(sprintf("Number of years: %d\n", validation$n_years))
  cat(sprintf("Missing allocations: %d\n", validation$n_missing))
  cat(sprintf("Validation passed: %s\n", validation$is_valid))

  if (validation$n_missing > 0) {
    cat("\nMissing livestock:\n")
    print(validation$missing_livestock)
  }

  # Show validation table
  cat("\nValidation table:\n")
  print(validation$validation_table)

  # Summary for 2020
  cat("\n--- Production Summary for 2020 ---\n")
  summary_2020 <- summarize_livestock_production(livestock_provincial, 2020)
  print(summary_2020)

}, error = function(e) {
  cat("Error in livestock allocation:", e$message, "\n")
  cat("Traceback:\n")
  print(traceback())
})

# Test 3: Full agriculture conversion
cat("\n\n=== Testing Full Agriculture Conversion ===\n")
tryCatch({
  agriculture_gains <- convert_agriculture_to_gains(prj, "China60ref")

  cat("\n--- Crop Data ---\n")
  cat("Rows:", nrow(agriculture_gains$crops), "\n")
  cat("Sample:\n")
  print(head(agriculture_gains$crops, 5))

  cat("\n--- Livestock Data ---\n")
  cat("Rows:", nrow(agriculture_gains$livestock), "\n")
  cat("Sample:\n")
  print(head(agriculture_gains$livestock, 5))

  # Get summary
  cat("\n--- Summary for 2020 ---\n")
  summary <- summarize_agriculture_gains(agriculture_gains, 2020)

  cat("\nTop 10 provinces by crop production:\n")
  print(head(summary$crop_by_province, 10))

  cat("\nTop 10 provinces by livestock production:\n")
  print(head(summary$livestock_by_province, 10))

  cat("\nNational crop production by category:\n")
  print(summary$crop_national)

  cat("\nNational livestock production by category:\n")
  print(summary$livestock_national)

}, error = function(e) {
  cat("Error in agriculture conversion:", e$message, "\n")
  cat("Traceback:\n")
  print(traceback())
})

cat("\n=== All Tests Completed ===\n")
