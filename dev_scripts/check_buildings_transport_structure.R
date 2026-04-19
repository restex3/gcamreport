# GCAM-China Buildings and Transport Data Structure Check

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

# List all available queries
cat("\n=== Listing All Available Queries ===\n")
all_queries <- rgcam::listQueries(prj)

# Filter buildings and transport related queries
buildings_related <- grep("building|residential|commercial|heating|cooling",
                         all_queries, value = TRUE, ignore.case = TRUE)
transport_related <- grep("transport|vehicle|passenger|freight|aviation|shipping",
                         all_queries, value = TRUE, ignore.case = TRUE)

cat("\nBuildings related queries:\n")
print(buildings_related)

cat("\nTransport related queries:\n")
print(transport_related)

# Check buildings queries
cat("\n\n=== Checking Buildings Queries ===\n")

for (query in buildings_related) {
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
        cat("  Sector list:", paste(head(sectors, 10), collapse=", "), "\n")
      }

      cat("  Number of rows:", nrow(data), "\n")
      cat("  Data sample:\n")
      print(head(data, 3))
    }
  }, error = function(e) {
    cat("  Error:", e$message, "\n")
  })
}

# Check transport queries
cat("\n\n=== Checking Transport Queries ===\n")

for (query in transport_related) {
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
        cat("  Sector list:", paste(head(sectors, 10), collapse=", "), "\n")
      }

      # Check modes
      if ("mode" %in% names(data)) {
        modes <- unique(data$mode)
        cat("  Number of modes:", length(modes), "\n")
        cat("  Mode list:", paste(head(modes, 10), collapse=", "), "\n")
      }

      cat("  Number of rows:", nrow(data), "\n")
      cat("  Data sample:\n")
      print(head(data, 3))
    }
  }, error = function(e) {
    cat("  Error:", e$message, "\n")
  })
}

cat("\n=== Completed ===\n")
