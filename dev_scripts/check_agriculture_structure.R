# GCAM-China Agriculture Data Structure Check

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

# Check agriculture queries
cat("\n=== Checking Agriculture Queries ===\n")
ag_queries <- c(
  "ag production by crop type",
  "demand balances by crop commodity",
  "land allocation by crop and water source"
)

for (query in ag_queries) {
  cat("\nQuery:", query, "\n")

  tryCatch({
    data <- rgcam::getQuery(prj, query, "China60ref")

    if (!is.null(data)) {
      cat("  Columns:", paste(names(data), collapse=", "), "\n")

      # Check region column
      if ("region" %in% names(data)) {
        regions <- unique(data$region)
        cat("  Number of regions:", length(regions), "\n")
        cat("  Region list:", paste(head(regions, 10), collapse=", "), "\n")

        # Check for provincial data
        provinces <- c("AH","BJ","CQ","FJ","GD","GS","GX","GZ","HA","HB","HE","HI","HL",
                      "HN","JL","JS","JX","LN","NM","NX","QH","SC","SD","SH","SN","SX","TJ",
                      "XJ","XZ","YN","ZJ")
        has_provinces <- any(regions %in% provinces)
        has_china <- "China" %in% regions

        cat("  Has provincial data:", has_provinces, "\n")
        cat("  Has national China data:", has_china, "\n")
      }

      # Check crop types
      if ("sector" %in% names(data)) {
        crops <- unique(data$sector)
        cat("  Number of crops:", length(crops), "\n")
        cat("  Crop list:", paste(head(crops, 10), collapse=", "), "\n")
      }

      # Show data sample
      cat("  Number of rows:", nrow(data), "\n")
      if (nrow(data) > 0) {
        cat("  Data sample:\n")
        print(head(data, 3))
      }
    } else {
      cat("  Query returned NULL\n")
    }
  }, error = function(e) {
    cat("  Error:", e$message, "\n")
  })
}

cat("\n=== Completed ===\n")
