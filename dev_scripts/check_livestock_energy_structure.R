# GCAM-China Livestock and Agriculture Energy Data Structure Check

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

provinces <- c("AH","BJ","CQ","FJ","GD","GS","GX","GZ","HA","HB","HE","HI","HL",
              "HN","JL","JS","JX","LN","NM","NX","QH","SC","SD","SH","SN","SX","TJ",
              "XJ","XZ","YN","ZJ")

# Check all available queries
cat("\n=== Listing All Available Queries ===\n")
all_queries <- rgcam::listQueries(prj)
cat("Total queries available:", length(all_queries), "\n")

# Filter agriculture and livestock related queries
ag_related <- grep("ag|crop|livestock|animal|meat|dairy|feed|food",
                   all_queries, value = TRUE, ignore.case = TRUE)
cat("\nAgriculture/Livestock related queries:\n")
print(ag_related)

# Check specific queries
cat("\n=== Checking Livestock and Energy Queries ===\n")

queries_to_check <- c(
  # Try to find livestock production query
  "ag production by crop type",  # May include livestock
  "demand balances by crop commodity",  # May include livestock demand
  # Try to find energy queries
  "building final energy by aggregate service",
  "industry final energy by fuel",
  "transport final energy by aggregate mode"
)

for (query in queries_to_check) {
  if (query %in% all_queries) {
    cat("\n--- Query:", query, "---\n")

    tryCatch({
      data <- rgcam::getQuery(prj, query, "China60ref")

      if (!is.null(data)) {
        cat("  Columns:", paste(names(data), collapse=", "), "\n")

        # Check region column
        if ("region" %in% names(data)) {
          regions <- unique(data$region)
          cat("  Number of regions:", length(regions), "\n")

          has_provinces <- any(regions %in% provinces)
          has_china <- "China" %in% regions

          cat("  Has provincial data:", has_provinces, "\n")
          cat("  Has national China data:", has_china, "\n")

          if (has_provinces) {
            prov_count <- sum(regions %in% provinces)
            cat("  Number of provinces:", prov_count, "\n")
          }
        }

        # Check sectors
        if ("sector" %in% names(data)) {
          sectors <- unique(data$sector)
          cat("  Number of sectors:", length(sectors), "\n")

          # Check for livestock sectors
          livestock_sectors <- grep("beef|dairy|pork|poultry|sheep|goat|meat|livestock",
                                   sectors, value = TRUE, ignore.case = TRUE)
          if (length(livestock_sectors) > 0) {
            cat("  Livestock sectors found:", paste(livestock_sectors, collapse=", "), "\n")
          }

          # Check for agriculture energy sectors
          ag_energy_sectors <- grep("agricultural|farm",
                                   sectors, value = TRUE, ignore.case = TRUE)
          if (length(ag_energy_sectors) > 0) {
            cat("  Agriculture energy sectors found:", paste(ag_energy_sectors, collapse=", "), "\n")
          }
        }

        cat("  Number of rows:", nrow(data), "\n")
        cat("  Data sample:\n")
        print(head(data, 3))
      }
    }, error = function(e) {
      cat("  Error:", e$message, "\n")
    })
  } else {
    cat("\n--- Query not found:", query, "---\n")
  }
}

# Specifically check for livestock in ag production
cat("\n=== Detailed Check: Livestock in Agriculture Production ===\n")
tryCatch({
  ag_prod <- rgcam::getQuery(prj, "ag production by crop type", "China60ref")

  if ("sector" %in% names(ag_prod)) {
    all_sectors <- unique(ag_prod$sector)
    livestock_in_ag <- grep("beef|dairy|pork|poultry|sheep|goat|meat",
                           all_sectors, value = TRUE, ignore.case = TRUE)

    if (length(livestock_in_ag) > 0) {
      cat("Livestock products in ag production:\n")
      print(livestock_in_ag)

      # Check if livestock has provincial data
      livestock_data <- ag_prod %>% filter(sector %in% livestock_in_ag)
      livestock_regions <- unique(livestock_data$region)

      cat("\nLivestock regions:", paste(head(livestock_regions, 10), collapse=", "), "\n")
      cat("Has provincial livestock data:", any(livestock_regions %in% provinces), "\n")
    } else {
      cat("No livestock products found in ag production query\n")
      cat("All sectors in ag production:\n")
      print(all_sectors)
    }
  }
}, error = function(e) {
  cat("Error checking livestock:", e$message, "\n")
})

cat("\n=== Completed ===\n")
