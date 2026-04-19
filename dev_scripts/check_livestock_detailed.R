# Check livestock production query specifically

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

# Check meat and dairy production
cat("\n=== Meat and Dairy Production ===\n")
livestock_prod <- rgcam::getQuery(prj, "meat and dairy production by type", "China60ref")

cat("Columns:", paste(names(livestock_prod), collapse=", "), "\n")

if ("region" %in% names(livestock_prod)) {
  regions <- unique(livestock_prod$region)
  cat("Number of regions:", length(regions), "\n")
  cat("Region list:", paste(head(regions, 15), collapse=", "), "\n")

  has_provinces <- any(regions %in% provinces)
  has_china <- "China" %in% regions

  cat("Has provincial data:", has_provinces, "\n")
  cat("Has national China data:", has_china, "\n")

  if (has_provinces) {
    prov_count <- sum(regions %in% provinces)
    cat("Number of provinces:", prov_count, "\n")
  }
}

if ("sector" %in% names(livestock_prod)) {
  sectors <- unique(livestock_prod$sector)
  cat("Livestock types:", paste(sectors, collapse=", "), "\n")
}

cat("Number of rows:", nrow(livestock_prod), "\n")
cat("\nData sample:\n")
print(head(livestock_prod, 5))

# Check meat and dairy demand
cat("\n\n=== Meat and Dairy Demand ===\n")
livestock_demand <- rgcam::getQuery(prj, "demand balances by meat and dairy commodity", "China60ref")

cat("Columns:", paste(names(livestock_demand), collapse=", "), "\n")

if ("region" %in% names(livestock_demand)) {
  regions <- unique(livestock_demand$region)
  cat("Number of regions:", length(regions), "\n")

  has_provinces <- any(regions %in% provinces)
  has_china <- "China" %in% regions

  cat("Has provincial data:", has_provinces, "\n")
  cat("Has national China data:", has_china, "\n")

  if (has_provinces) {
    prov_count <- sum(regions %in% provinces)
    cat("Number of provinces:", prov_count, "\n")
  }
}

cat("Number of rows:", nrow(livestock_demand), "\n")
cat("\nData sample:\n")
print(head(livestock_demand, 5))

cat("\n=== Completed ===\n")
