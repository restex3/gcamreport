Sys.setlocale("LC_ALL", "C")
devtools::load_all(".", reset = TRUE, quiet = TRUE)

cat("=== V8 Test (filter China regions only) ===\n\n")

# Load project
prj <- rgcam::loadProject("E:/GCAM/GCAM-China_v8/output/database_basexdb_v8_test.dat")
cat("Project loaded\n")

# Get all regions
all_regions <- rgcam::getQuery(prj, "GDP by region")$region %>% unique()
cat("All regions in database:", length(all_regions), "\n")
cat("Sample:", head(all_regions, 10), "\n\n")

# Filter China regions only (China + provinces)
china_regions <- all_regions[grepl("^(China|[A-Z]{2})$", all_regions)]
cat("China regions:", length(china_regions), "\n")
print(china_regions)

cat("\nNow generating report with China regions only...\n")
# This won't work directly, but shows the concept
# Need to modify generate_report to accept region filter
