# Update GAINS mapping for V8 - Stage 3: Non-Energy Use aggregation

library(dplyr)

cat("=== Updating GAINS Mapping for V8 ===\n\n")

# Load original GAINS mapping
gains_map <- read.csv("E:/GCAM/GCAM_tools/gcam2gains/GCAM_GAINS_SEC_ACT_MAP.csv",
                      stringsAsFactors = FALSE)

cat("Original mapping rows:", nrow(gains_map), "\n")
cat("Unique SOURCE_VARIABLE:", length(unique(gains_map$SOURCE_VARIABLE)), "\n\n")

# Create V8-specific mapping by updating SOURCE_VARIABLE
gains_map_v8 <- gains_map

# Stage 3: Non-Energy Use aggregation
non_energy_mapping <- list(
  "Final Energy|Non-Energy Use|Biomass" = "Final Energy|Non-Energy Use|Solids",
  "Final Energy|Non-Energy Use|Coal" = "Final Energy|Non-Energy Use|Solids|Coal",
  "Final Energy|Non-Energy Use|Oil" = "Final Energy|Non-Energy Use|Liquids",
  "Final Energy|Non-Energy Use|Gas" = "Final Energy|Non-Energy Use|Gases"
)

cat("=== Stage 3: Non-Energy Use Mapping ===\n")
for (old_var in names(non_energy_mapping)) {
  new_var <- non_energy_mapping[[old_var]]
  rows_updated <- sum(gains_map_v8$SOURCE_VARIABLE == old_var)
  if (rows_updated > 0) {
    gains_map_v8$SOURCE_VARIABLE[gains_map_v8$SOURCE_VARIABLE == old_var] <- new_var
    cat("✅ Updated", rows_updated, "rows:", old_var, "->", new_var, "\n")
  }
}

# Save V8 mapping
output_file <- "E:/GCAM/GCAM_tools/gcam2gains/GCAM_GAINS_SEC_ACT_MAP_V8.csv"
write.csv(gains_map_v8, output_file, row.names = FALSE)
cat("\n✅ Saved to:", output_file, "\n")
cat("   Rows:", nrow(gains_map_v8), "\n")
