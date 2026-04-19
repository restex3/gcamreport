# Test Simplified Agriculture Allocation

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

# Test 1: Crop allocation with uniform distribution
cat("\n=== Test 1: Crop Allocation (Uniform) ===\n")
tryCatch({
  crop_provincial <- allocate_crop_production_simple(prj, "China60ref", allocation_method = "uniform")

  cat("\nCrop allocation completed!\n")
  cat("Number of rows:", nrow(crop_provincial), "\n")
  cat("Crops:", length(unique(crop_provincial$crop)), "\n")
  cat("Provinces:", length(unique(crop_provincial$region)), "\n")
  cat("Years:", paste(range(crop_provincial$year), collapse=" - "), "\n")

  cat("\nSample data:\n")
  print(head(crop_provincial, 5))

  # Check that provincial totals sum to national totals
  cat("\n--- Validation: Provincial Sum vs National Total ---\n")
  validation <- crop_provincial %>%
    dplyr::group_by(crop, year) %>%
    dplyr::summarise(
      national_total = dplyr::first(national_production),
      provincial_sum = sum(provincial_production, na.rm = TRUE),
      difference = provincial_sum - national_total,
      .groups = "drop"
    )

  cat("Max difference:", max(abs(validation$difference)), "\n")
  cat("Sample validation:\n")
  print(head(validation, 5))

}, error = function(e) {
  cat("Error:", e$message, "\n")
  print(traceback())
})

# Test 2: Livestock allocation with uniform distribution
cat("\n\n=== Test 2: Livestock Allocation (Uniform) ===\n")
tryCatch({
  livestock_provincial <- allocate_livestock_production_simple(prj, "China60ref", allocation_method = "uniform")

  cat("\nLivestock allocation completed!\n")
  cat("Number of rows:", nrow(livestock_provincial), "\n")
  cat("Livestock products:", length(unique(livestock_provincial$livestock)), "\n")
  cat("Provinces:", length(unique(livestock_provincial$region)), "\n")
  cat("Years:", paste(range(livestock_provincial$year), collapse=" - "), "\n")

  cat("\nSample data:\n")
  print(head(livestock_provincial, 5))

  # Check that provincial totals sum to national totals
  cat("\n--- Validation: Provincial Sum vs National Total ---\n")
  validation <- livestock_provincial %>%
    dplyr::group_by(livestock, year) %>%
    dplyr::summarise(
      national_total = dplyr::first(national_production),
      provincial_sum = sum(provincial_production, na.rm = TRUE),
      difference = provincial_sum - national_total,
      .groups = "drop"
    )

  cat("Max difference:", max(abs(validation$difference)), "\n")
  cat("Sample validation:\n")
  print(validation)

}, error = function(e) {
  cat("Error:", e$message, "\n")
  print(traceback())
})

# Test 3: Full agriculture conversion
cat("\n\n=== Test 3: Full Agriculture Conversion ===\n")
tryCatch({
  agriculture_gains <- convert_agriculture_to_gains(prj, "China60ref", allocation_method = "uniform")

  cat("\n--- Crop Data ---\n")
  cat("Rows:", nrow(agriculture_gains$crops), "\n")
  cat("Provinces:", length(unique(agriculture_gains$crops$province_code)), "\n")
  cat("Crops:", length(unique(agriculture_gains$crops$crop)), "\n")
  cat("\nSample:\n")
  print(head(agriculture_gains$crops, 5))

  cat("\n--- Livestock Data ---\n")
  cat("Rows:", nrow(agriculture_gains$livestock), "\n")
  cat("Provinces:", length(unique(agriculture_gains$livestock$province_code)), "\n")
  cat("Livestock:", length(unique(agriculture_gains$livestock$livestock)), "\n")
  cat("\nSample:\n")
  print(head(agriculture_gains$livestock, 5))

  # Get summary for 2020
  cat("\n--- Summary for 2020 ---\n")
  summary <- summarize_agriculture_gains(agriculture_gains, 2020)

  cat("\nTop 10 provinces by crop production (all equal with uniform allocation):\n")
  print(head(summary$crop_by_province, 10))

  cat("\nNational crop production by category:\n")
  print(summary$crop_national)

  cat("\nNational livestock production by category:\n")
  print(summary$livestock_national)

}, error = function(e) {
  cat("Error:", e$message, "\n")
  print(traceback())
})

# Test 4: Create templates for statistical data
cat("\n\n=== Test 4: Create Statistical Data Templates ===\n")
tryCatch({
  create_statistical_shares_template("output/crop_shares_template.csv")
  create_livestock_shares_template("output/livestock_shares_template.csv")

  cat("\nTemplates created successfully!\n")
  cat("Fill these templates with data from China Statistical Yearbook.\n")

}, error = function(e) {
  cat("Error:", e$message, "\n")
})

cat("\n=== All Tests Completed ===\n")
