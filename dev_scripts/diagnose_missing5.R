# Diagnose the 5 missing GAINS variables in actual v8 output
output <- read.csv("E:/GCAM/GCAM-China_v8/output/database_basexdb_v8_test_standardized.csv",
                    stringsAsFactors = FALSE, check.names = FALSE)
vars <- unique(output$Variable)

# ---- Problem 1: Primary Energy|Electricity|Coal|Gas w/ CCS ----
cat("=== PROBLEM 1: CCS variables ===\n")

# Show all Primary Energy|Electricity|* variables
pe_elec <- vars[grepl("Primary Energy", vars, fixed = TRUE) & grepl("Electricity", vars, fixed = TRUE)]
cat("All PE|Electricity variables:\n")
for (v in sort(pe_elec)) cat("  ", v, "\n")

# Check what primary_energy_electricity_clean generates
cat("\nMissing specifically:\n")
for (v in c("Primary Energy|Electricity|Coal|w/ CCS", "Primary Energy|Electricity|Gas|w/ CCS",
            "Primary Energy|Electricity|Biomass|w/ CCS")) {
  if (v %in% vars) {
    cat(sprintf("  [OK] %s\n", v))
  } else {
    cat(sprintf("  [XX] %s\n", v))
  }
}

# Get all w/ CCS vars across the board
cat("\nAll w/ CCS variables in output:\n")
ccs_all <- vars[grepl("w/ CCS", vars, fixed = TRUE)]
for (v in sort(ccs_all)) cat("  ", v, "\n")

# ---- Problem 2: Transportation Electricity ----
cat("\n=== PROBLEM 2: Transportation Electricity ===\n")

# Show Transportation final energy top-level structure
transp_vars <- vars[grepl("Final Energy|Transportation", vars, fixed = TRUE)]
cat("Total Transportation variables:", length(transp_vars), "\n")

# Check for Electricity in Transportation
transp_elec <- transp_vars[grepl("Electricity", transp_vars, fixed = TRUE)]
cat("Transportation + Electricity variables:", length(transp_elec), "\n")
for (v in sort(transp_elec)) cat("  ", v, "\n")

# Check fe_transportation structure - what fuels exist?
cat("\nTransportation top-level fuels:\n")
for (fuel in c("Electricity", "Gases", "Hydrogen", "Liquids", "Solids", "Heat", "Biomass", "Coal")) {
  pattern <- sprintf("Final Energy|Transportation|%s", fuel)
  matches <- grep(pattern, transp_vars, value = TRUE, fixed = TRUE)
  if (length(matches) > 0) {
    for (m in matches[1:5]) cat(sprintf("  [OK] %s\n", m))
  } else {
    cat(sprintf("  [XX] %s (not found)\n", pattern))
  }
}

# ---- Problem 3: Fertilizer ----
cat("\n=== PROBLEM 3: Fertilizer & Nitrogen Fertilizer ===\n")

# Check all Production|Chemicals variables
chem_vars <- vars[grepl("Production|Chemicals", vars, fixed = TRUE)]
cat("All Production|Chemicals variables:\n")
for (v in sort(chem_vars)) cat("  ", v, "\n")

# Check what's in variables_functions_mapping.csv
cat("\nChecking variables_functions_mapping.csv for Chemicals/Fertilizer entries...\n")
vfm <- read.csv("inst/extdata/mappings/GCAMChina8.0/variables_functions_mapping.csv",
                stringsAsFactors = FALSE, sep = ";")
chem_mappings <- vfm[grepl("Chemical|Fertilizer|Ammonia", vfm$name, ignore.case = TRUE), ]
cat("Matching entries:\n")
for (i in seq_len(nrow(chem_mappings))) {
  cat(sprintf("  name=%s, fun=%s\n", chem_mappings$name[i], chem_mappings$fun[i]))
}

# Check if the fertilizer code ran - was Production|Chemicals|Ammonia present?
cat("\nAmmonia data summary:\n")
ammonia <- output[output$Variable == "Production|Chemicals|Ammonia", ]
cat("Rows:", nrow(ammonia), "\n")
cat("Regions:", paste(sort(unique(ammonia$Region)), collapse = ", "), "\n")

# Is there an industry_production function that should generate N_Fertilizer?
cat("\nChecking industry_production_clean variables:\n")
ip_vars <- vars[grepl("Production|", vars, fixed = TRUE)]
for (v in sort(ip_vars)) cat("  ", v, "\n")

# Check if this is a mapping issue - what variables ARE produced?
cat("\nChecking what the report produces for chemicals:\n")
chem_all <- vars[grepl("Chemicals", vars, fixed = TRUE)]
for (v in sort(chem_all)) cat("  ", v, "\n")
