library(gcamreport)

# Load project
prj <- rgcam::loadProject('E:/GCAM/GCAM-China_v8/output/database_basexdb_v8_test.dat')
prj <<- prj

# Set desired_variables.global (required by filter_variables)
desired_variables.global <<- c("Primary Energy")

cat("=== Testing get_primary_energy ===\n\n")

# Get the query data
pe_data <- rgcam::getQuery(prj, "primary energy")
cat("Query returned", nrow(pe_data), "rows\n")
cat("Unique fuels:\n")
print(unique(pe_data$fuel))

# Load mapping
data('primary_energy_map_vGCAMChina8.0', package='gcamreport')
cat("\nMapping fuels:\n")
print(unique(primary_energy_map_vGCAMChina8.0$fuel))

# Try the join
library(dplyr)
joined <- pe_data %>%
  filter(!grepl("water", fuel), Units == "EJ") %>%
  left_join(primary_energy_map_vGCAMChina8.0, by = "fuel", multiple = "all")

cat("\nAfter join, rows:", nrow(joined), "\n")
cat("Rows with NoReported or NA var:\n")
print(table(is.na(joined$var3) | joined$var3 == "NoReported", useNA="always"))

cat("\nSample of joined data:\n")
print(head(joined[, c("fuel", "var1", "var2", "var3")], 20))
