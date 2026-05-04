# Rebuild the gcamreport package with all GCAM-China 8.0 updates
# Run this script after making changes to functions.R, variables_functions_mapping.csv,
# or template .rda files.

library(devtools)

# Step 1: Rebuild template_vGCAMChina8.0.rda from the source data
# (if the template was modified via direct .rda editing)
cat("Step 1: Verifying template...\n")
load("data/template_vGCAMChina8.0.rda")
cat("  Template has", nrow(template_vGCAMChina8.0), "rows\n")

# Check that Feedstock|Industry|Steel|Coke has the right Internal_variable
target_var <- "Feedstock|Industry|Steel|Coke"
iv <- template_vGCAMChina8.0[template_vGCAMChina8.0$Variable == target_var, "Internal_variable"]
cat("  Internal_variable for", target_var, ":", as.character(iv), "\n")
if (as.character(iv) == "iron_steel_inputs_clean") {
  cat("  OK - Internal_variable correctly set\n")
} else {
  cat("  FIXING Internal_variable...\n")
  template_vGCAMChina8.0[template_vGCAMChina8.0$Variable == target_var, "Internal_variable"] <- "iron_steel_inputs_clean"
  save(template_vGCAMChina8.0, file = "data/template_vGCAMChina8.0.rda", compress = "xz")
  cat("  Fixed and saved.\n")
}

# Step 2: Rebuild the package
cat("\nStep 2: Building and installing package...\n")
# First, regenerate all data objects from mapping files
source("dev_scripts/rebuild_mappings_v8.R")

# Install the package
install_local(".", force = TRUE, quiet = FALSE)

# Step 3: Verify the installed package
cat("\nStep 3: Verifying installed package...\n")
library(gcamreport)

# Test that the new function exists
if (exists("get_iron_steel_inputs", envir = asNamespace("gcamreport"))) {
  cat("  get_iron_steel_inputs() - LOADED\n")
} else {
  cat("  get_iron_steel_inputs() - NOT FOUND!\n")
}

# Test that the template has the correct mapping
template <- get("template_vGCAMChina8.0", envir = asNamespace("gcamreport"))
iv2 <- template[template$Variable == "Feedstock|Industry|Steel|Coke", "Internal_variable"]
cat("  Template Feedstock|Industry|Steel|Coke Internal_variable:", as.character(iv2), "\n")

# Test the variable-function mapping
vf <- get_runtime_var_fun_map("vGCAMChina8.0")
if ("iron_steel_inputs_clean" %in% vf$name) {
  cat("  iron_steel_inputs_clean in var_fun_map - LOADED\n")
  cat("    fun:", vf[vf$name == "iron_steel_inputs_clean", "fun"], "\n")
  cat("    queries:", vf[vf$name == "iron_steel_inputs_clean", "queries"][[1]][[1]], "\n")
} else {
  cat("  iron_steel_inputs_clean in var_fun_map - NOT FOUND!\n")
}

cat("\nRebuild complete. Run dev_scripts/check_coverage_postfix.R to verify coverage.\n")
