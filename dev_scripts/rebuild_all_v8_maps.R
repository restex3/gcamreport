# Batch rebuild all GCAMChina8.0 data objects
# This ensures all CSV mappings are properly converted to .rda files

library(usethis)
library(tidyr)
library(dplyr)
library(readr)

rawDataFolder <- here::here()
mapping_dir <- file.path(rawDataFolder, "inst/extdata/mappings/GCAMChina8.0")

cat("=== Batch Rebuilding GCAMChina8.0 Data Objects ===\n\n")

# Helper function to gather mapping files
gather_map <- function(df) {
  n_cols <- ncol(df)
  df %>%
    tidyr::gather(key = "var_num", value = "var", starts_with("var")) %>%
    dplyr::filter(!is.na(var)) %>%
    dplyr::select(-var_num)
}

# List of simple mapping files (2 columns: input/fuel -> var)
simple_maps <- c("food_items_map")

# List of complex mapping files (need gathering)
complex_maps <- c(
  "ag_demand_map",
  "primary_energy_map",
  "water_map"
)

# Rebuild simple maps
for (map_name in simple_maps) {
  tryCatch({
    cat(sprintf("Rebuilding %s_vGCAMChina8.0...\n", map_name))

    df <- read_csv(
      file.path(mapping_dir, paste0(map_name, ".csv")),
      comment = "#", show_col_types = FALSE
    )

    obj_name <- paste0(map_name, "_vGCAMChina8.0")
    assign(obj_name, df)

    do.call(use_data, list(as.name(obj_name), overwrite = TRUE))
    cat(sprintf("  ✅ %s: %d rows\n", obj_name, nrow(df)))
  }, error = function(e) {
    cat(sprintf("  ❌ Error: %s\n", conditionMessage(e)))
  })
}

# Rebuild complex maps
for (map_name in complex_maps) {
  tryCatch({
    cat(sprintf("\nRebuilding %s_vGCAMChina8.0...\n", map_name))

    df <- read_csv(
      file.path(mapping_dir, paste0(map_name, ".csv")),
      comment = "#", na = "", show_col_types = FALSE
    )

    cat(sprintf("  CSV: %d rows x %d columns\n", nrow(df), ncol(df)))

    # Process based on first column name
    first_col <- names(df)[1]
    processed <- df %>%
      tidyr::gather(key = "var_num", value = "var", starts_with("var")) %>%
      dplyr::filter(!is.na(var)) %>%
      dplyr::select(-var_num)

    obj_name <- paste0(map_name, "_vGCAMChina8.0")
    assign(obj_name, processed)

    do.call(use_data, list(as.name(obj_name), overwrite = TRUE))
    cat(sprintf("  ✅ %s: %d rows\n", obj_name, nrow(processed)))
  }, error = function(e) {
    cat(sprintf("  ❌ Error: %s\n", conditionMessage(e)))
  })
}

cat("\n✅ Batch rebuild complete!\n")
