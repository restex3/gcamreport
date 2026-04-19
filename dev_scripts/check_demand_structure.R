# Check actual demand data structure

repo_dir <- "E:/GCAM/GCAM_tools/gcamreport"
db_path <- "E:/GCAM/GCAM-China_v7.1/output"
db_name <- "China60Ref"
project_file <- file.path(db_path, paste0(db_name, "_gcamreport_China60ref.dat"))

suppressWarnings(devtools::load_all(repo_dir, quiet = TRUE))

cat("Loading project...\n")
prj <- rgcam::loadProject(project_file)

# Get provincial demand data
cat("\n=== Provincial Crop Demand Structure ===\n")
provincial_demand <- rgcam::getQuery(prj, "demand balances by crop commodity", "China60ref")

provinces <- c("AH","BJ","CQ","FJ","GD","GS","GX","GZ","HA","HB","HE","HI","HL",
              "HN","JL","JS","JX","LN","NM","NX","QH","SC","SD","SH","SN","SX","TJ",
              "XJ","XZ","YN","ZJ")

prov_demand <- provincial_demand %>% dplyr::filter(region %in% provinces)

cat("Columns:", paste(names(prov_demand), collapse=", "), "\n")
cat("\nUnique sectors:\n")
print(unique(prov_demand$sector))

cat("\nUnique inputs:\n")
print(unique(prov_demand$input))

cat("\nSample data (first 20 rows):\n")
print(head(prov_demand, 20))

# Check if input column contains the demand categories
cat("\n=== Checking 'input' column for demand categories ===\n")
demand_categories <- c("FoodDemand_Staples", "FoodDemand_NonStaples", "FeedCrops", "NonFoodDemand_Crops")
for (cat_name in demand_categories) {
  matching <- prov_demand %>% dplyr::filter(grepl(cat_name, input, ignore.case = TRUE))
  cat(sprintf("%s: %d rows\n", cat_name, nrow(matching)))
  if (nrow(matching) > 0) {
    cat("  Sample inputs:\n")
    print(head(unique(matching$input), 5))
  }
}

# Check national demand for comparison
cat("\n=== National Demand Structure ===\n")
national_demand <- provincial_demand %>% dplyr::filter(region == "China")
cat("National demand rows:", nrow(national_demand), "\n")
if (nrow(national_demand) > 0) {
  cat("National sectors:\n")
  print(unique(national_demand$sector))
  cat("\nNational inputs:\n")
  print(head(unique(national_demand$input), 10))
}

cat("\n=== Complete ===\n")
