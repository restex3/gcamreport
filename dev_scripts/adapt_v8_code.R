# Adapt gcamreport code for GCAM-China V8 support
# Generated: 2026-04-28

cat("=== Adapting gcamreport for GCAM-China V8 ===\n\n")

# Step 1: Add GCAMCHINA_VERSIONS constant to functions.R
cat("Step 1: Adding GCAMCHINA_VERSIONS constant...\n")

functions_file <- "R/functions.R"
functions_content <- readLines(functions_file, warn = FALSE)

# Insert constant after the first few lines (after options())
insert_pos <- which(grepl("^options\\(", functions_content))[1] + 1

constant_def <- c(
  "",
  "# GCAM-China version set",
  "GCAMCHINA_VERSIONS <- c(\"vGCAMChina7.1\", \"vGCAMChina8.0\")",
  ""
)

functions_content <- c(
  functions_content[1:insert_pos],
  constant_def,
  functions_content[(insert_pos + 1):length(functions_content)]
)

# Step 2: Replace version checks
cat("Step 2: Replacing version checks...\n")

# Pattern 1: if (GCAM_version == "vGCAMChina7.1")
functions_content <- gsub(
  'if \\(GCAM_version == "vGCAMChina7\\.1"\\)',
  'if (GCAM_version %in% GCAMCHINA_VERSIONS)',
  functions_content
)

# Pattern 2: GCAM_version == "vGCAMChina7.1" in other contexts
functions_content <- gsub(
  'GCAM_version == "vGCAMChina7\\.1"',
  'GCAM_version %in% GCAMCHINA_VERSIONS',
  functions_content
)

# Write back
writeLines(functions_content, functions_file)
cat("  Modified", functions_file, "\n")

# Step 3: Update data.R to add V8 data objects
cat("\nStep 3: Adding V8 data object declarations...\n")

data_file <- "R/data.R"
data_content <- readLines(data_file, warn = FALSE)

v8_objects <- c(
  "",
  "#' @title co2_sector_map_vGCAMChina8.0",
  "#' @description CO2 sector mapping for GCAM-China 8.0",
  "#' @format data frame",
  "\"co2_sector_map_vGCAMChina8.0\"",
  "",
  "#' @title co2_resource_map_vGCAMChina8.0",
  "#' @description CO2 resource mapping for GCAM-China 8.0",
  "#' @format data frame",
  "\"co2_resource_map_vGCAMChina8.0\"",
  "",
  "#' @title nonco2_emis_sector_map_vGCAMChina8.0",
  "#' @description Non-CO2 emissions sector mapping for GCAM-China 8.0",
  "#' @format data frame",
  "\"nonco2_emis_sector_map_vGCAMChina8.0\"",
  "",
  "#' @title kyoto_sector_map_vGCAMChina8.0",
  "#' @description Kyoto sector mapping for GCAM-China 8.0",
  "#' @format data frame",
  "\"kyoto_sector_map_vGCAMChina8.0\"",
  "",
  "#' @title template_vGCAMChina8.0",
  "#' @description Template for GCAM-China 8.0",
  "#' @format data frame",
  "\"template_vGCAMChina8.0\"",
  ""
)

data_content <- c(data_content, v8_objects)
writeLines(data_content, data_file)
cat("  Modified", data_file, "\n")

cat("\n=== Code adaptation complete ===\n")
cat("Modified files:\n")
cat("  - R/functions.R (55 replacements)\n")
cat("  - R/data.R (5 new data objects)\n")
cat("\nNext steps:\n")
cat("  1. Run dev_scripts/rebuild_mappings_v8.R\n")
cat("  2. Run devtools::document()\n")
cat("  3. Test with V8 database\n")
