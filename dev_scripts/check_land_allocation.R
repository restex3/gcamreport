# Check land allocation data for agriculture allocation

repo_dir <- "E:/GCAM/GCAM_tools/gcamreport"
db_path <- "E:/GCAM/GCAM-China_v7.1/output"
db_name <- "China60Ref"
project_file <- file.path(db_path, paste0(db_name, "_gcamreport_China60ref.dat"))

suppressWarnings(devtools::load_all(repo_dir, quiet = TRUE))

cat("Loading project...\n")
prj <- rgcam::loadProject(project_file)

provinces <- c("AH","BJ","CQ","FJ","GD","GS","GX","GZ","HA","HB","HE","HI","HL",
              "HN","JL","JS","JX","LN","NM","NX","QH","SC","SD","SH","SN","SX","TJ",
              "XJ","XZ","YN","ZJ")

# Check land allocation data
cat("\n=== Land Allocation Data ===\n")
land_data <- rgcam::getQuery(prj, "land allocation by crop and water source", "China60ref")

cat("Total rows:", nrow(land_data), "\n")
cat("Columns:", paste(names(land_data), collapse=", "), "\n")

# Check for provincial data
cat("\nRegions in data:\n")
regions <- unique(land_data$region)
cat("Number of regions:", length(regions), "\n")
cat("First 10 regions:", paste(head(regions, 10), collapse=", "), "\n")

has_provinces <- any(regions %in% provinces)
cat("\nHas provincial data:", has_provinces, "\n")

if (has_provinces) {
  prov_land <- land_data %>% dplyr::filter(region %in% provinces)
  cat("Provincial land rows:", nrow(prov_land), "\n")
  cat("Provinces found:", length(unique(prov_land$region)), "\n")

  cat("\nLand types (sectors):\n")
  print(unique(prov_land$sector))

  cat("\nSample data:\n")
  print(head(prov_land, 10))

  # Check for specific crops
  cat("\n=== Checking for Crop-Specific Land ===\n")
  crop_names <- c("Corn", "Rice", "Wheat", "Soybean")
  for (crop in crop_names) {
    crop_land <- prov_land %>% dplyr::filter(grepl(crop, sector, ignore.case = TRUE))
    cat(sprintf("%s: %d rows\n", crop, nrow(crop_land)))
    if (nrow(crop_land) > 0) {
      cat("  Sectors:", paste(unique(crop_land$sector), collapse=", "), "\n")
    }
  }

  # Summary by province for 2020
  cat("\n=== Land Area by Province (2020) ===\n")
  land_2020 <- prov_land %>%
    dplyr::filter(year == 2020) %>%
    dplyr::group_by(region) %>%
    dplyr::summarise(
      total_land = sum(value, na.rm = TRUE),
      n_sectors = dplyr::n_distinct(sector),
      .groups = "drop"
    ) %>%
    dplyr::arrange(dplyr::desc(total_land))

  print(land_2020)

} else {
  cat("\nNo provincial land data found!\n")
  cat("Available regions:", paste(regions, collapse=", "), "\n")
}

# Check national land data
cat("\n=== National Land Data ===\n")
china_land <- land_data %>% dplyr::filter(region == "China")
cat("China land rows:", nrow(china_land), "\n")
if (nrow(china_land) > 0) {
  cat("Sectors:\n")
  print(unique(china_land$sector))
  cat("\nSample:\n")
  print(head(china_land, 10))
}

cat("\n=== Complete ===\n")
