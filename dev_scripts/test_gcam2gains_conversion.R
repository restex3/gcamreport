# Test GCAM2GAINS Conversion Functions

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

# Test 1: Buildings conversion
cat("\n=== Testing Buildings Conversion ===\n")
tryCatch({
  buildings_data <- convert_buildings_to_gains(prj, "China60ref")

  cat("Buildings data converted successfully!\n")
  cat("Number of rows:", nrow(buildings_data), "\n")
  cat("Provinces:", length(unique(buildings_data$province_code)), "\n")
  cat("Subsectors:", length(unique(buildings_data$subsector)), "\n")
  cat("Years:", paste(range(buildings_data$year), collapse=" - "), "\n")
  cat("\nSample data:\n")
  print(head(buildings_data, 5))

  # Validate
  cat("\nValidation results:\n")
  gcam_raw <- rgcam::getQuery(prj, "building total final energy by service", "China60ref")
  validation <- validate_gains_conversion(buildings_data, gcam_raw)
  print(validation)

}, error = function(e) {
  cat("Error in buildings conversion:", e$message, "\n")
})

# Test 2: Transport conversion
cat("\n\n=== Testing Transport Conversion ===\n")
tryCatch({
  transport_data <- convert_transport_to_gains(prj, "China60ref")

  cat("Transport data converted successfully!\n")
  cat("Number of rows:", nrow(transport_data), "\n")
  cat("Provinces:", length(unique(transport_data$province_code)), "\n")
  cat("Subsectors:", length(unique(transport_data$subsector)), "\n")
  cat("Fuels:", length(unique(transport_data$fuel)), "\n")
  cat("Years:", paste(range(transport_data$year), collapse=" - "), "\n")
  cat("\nSample data:\n")
  print(head(transport_data, 5))

  # Get service output for comparison
  cat("\nTransport service output:\n")
  service_output <- get_transport_service_output(prj, "China60ref")
  cat("Service output rows:", nrow(service_output), "\n")
  print(head(service_output, 3))

}, error = function(e) {
  cat("Error in transport conversion:", e$message, "\n")
})

# Test 3: Industry conversion
cat("\n\n=== Testing Industry Conversion ===\n")
tryCatch({
  industry_data <- convert_industry_to_gains(prj, "China60ref")

  cat("Industry data converted successfully!\n")
  cat("Number of rows:", nrow(industry_data), "\n")
  cat("Provinces:", length(unique(industry_data$province_code)), "\n")
  cat("Subsectors:", length(unique(industry_data$subsector)), "\n")
  cat("Fuels:", length(unique(industry_data$fuel)), "\n")
  cat("Years:", paste(range(industry_data$year), collapse=" - "), "\n")
  cat("\nSample data:\n")
  print(head(industry_data, 5))

  # Get industry output for comparison
  cat("\nIndustry primary output:\n")
  industry_output <- get_industry_output(prj, "China60ref")
  cat("Output rows:", nrow(industry_output), "\n")
  print(head(industry_output, 3))

  # Get steel production
  cat("\nSteel production by technology:\n")
  steel_prod <- get_steel_production(prj, "China60ref")
  cat("Steel production rows:", nrow(steel_prod), "\n")
  print(head(steel_prod, 3))

}, error = function(e) {
  cat("Error in industry conversion:", e$message, "\n")
})

# Test 4: Check mapping files
cat("\n\n=== Testing Mapping Files ===\n")
mapping_files <- c(
  "buildings_services",
  "transport_modes",
  "fuels",
  "industry_sectors",
  "crops",
  "livestock",
  "provinces"
)

for (mapping_name in mapping_files) {
  tryCatch({
    mapping <- load_gcam2gains_mapping(mapping_name)
    cat(sprintf("✓ %s: %d rows\n", mapping_name, nrow(mapping)))
  }, error = function(e) {
    cat(sprintf("✗ %s: %s\n", mapping_name, e$message))
  })
}

cat("\n=== All Tests Completed ===\n")
