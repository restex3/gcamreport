# Debug Agriculture Allocation

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

# Step 1: Check national crop production
cat("\n=== Step 1: National Crop Production ===\n")
national_prod <- rgcam::getQuery(prj, "ag production by crop type", "China60ref")
cat("Total rows:", nrow(national_prod), "\n")
cat("Regions:", paste(unique(national_prod$region), collapse=", "), "\n")
cat("Columns:", paste(names(national_prod), collapse=", "), "\n")

china_prod <- national_prod %>% dplyr::filter(region == "China")
cat("\nChina production rows:", nrow(china_prod), "\n")
cat("Crops:", paste(unique(china_prod$sector), collapse=", "), "\n")
cat("\nSample:\n")
print(head(china_prod, 5))

# Step 2: Check provincial crop demand
cat("\n=== Step 2: Provincial Crop Demand ===\n")
provincial_demand <- rgcam::getQuery(prj, "demand balances by crop commodity", "China60ref")
cat("Total rows:", nrow(provincial_demand), "\n")
cat("Columns:", paste(names(provincial_demand), collapse=", "), "\n")

provinces <- c("AH","BJ","CQ","FJ","GD","GS","GX","GZ","HA","HB","HE","HI","HL",
              "HN","JL","JS","JX","LN","NM","NX","QH","SC","SD","SH","SN","SX","TJ",
              "XJ","XZ","YN","ZJ")

prov_demand <- provincial_demand %>% dplyr::filter(region %in% provinces)
cat("\nProvincial demand rows:", nrow(prov_demand), "\n")
cat("Provinces found:", length(unique(prov_demand$region)), "\n")
cat("Demand sectors:", paste(unique(prov_demand$sector), collapse=", "), "\n")
cat("\nSample:\n")
print(head(prov_demand, 5))

# Step 3: Test mapping
cat("\n=== Step 3: Test Crop-Demand Mapping ===\n")
crop_to_demand_mapping <- data.frame(
  production_sector = c("Corn", "Rice", "Wheat", "OtherGrain"),
  demand_sector = c("FoodDemand_Staples", "FoodDemand_Staples", "FoodDemand_Staples", "FoodDemand_Staples"),
  stringsAsFactors = FALSE
)
print(crop_to_demand_mapping)

# Step 4: Test join
cat("\n=== Step 4: Test Join ===\n")
test_join <- china_prod %>%
  dplyr::filter(year == 2020, sector %in% c("Corn", "Rice", "Wheat")) %>%
  dplyr::left_join(
    crop_to_demand_mapping,
    by = c("sector" = "production_sector")
  )
cat("Join result:\n")
print(test_join)

# Step 5: Calculate demand shares for one sector
cat("\n=== Step 5: Calculate Demand Shares ===\n")
staples_demand <- prov_demand %>%
  dplyr::filter(sector == "FoodDemand_Staples", year == 2020)

cat("Staples demand rows:", nrow(staples_demand), "\n")
cat("Provinces:", length(unique(staples_demand$region)), "\n")
cat("\nSample:\n")
print(head(staples_demand, 5))

if (nrow(staples_demand) > 0) {
  demand_shares <- staples_demand %>%
    dplyr::mutate(
      national_demand = sum(value, na.rm = TRUE),
      provincial_share = value / national_demand
    )

  cat("\nDemand shares calculated:\n")
  print(head(demand_shares, 5))
  cat("\nSum of shares:", sum(demand_shares$provincial_share), "\n")
}

cat("\n=== Debug Complete ===\n")
