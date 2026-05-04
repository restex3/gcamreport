# Analyze V8 GAINS coverage gap and find solutions

library(dplyr)

cat("=== Analyzing V8 GAINS Coverage Gap ===\n\n")

# Load data
report_v8 <- read.csv("E:/GCAM/GCAM-China_v8/output/database_basexdb_v8_test_standardized.csv",
                      stringsAsFactors = FALSE)
gains_map_original <- read.csv("E:/GCAM/GCAM_tools/gcam2gains/GCAM_GAINS_SEC_ACT_MAP.csv",
                                stringsAsFactors = FALSE)

v8_vars <- unique(report_v8$Variable)
required_vars <- unique(gains_map_original$SOURCE_VARIABLE)

cat("Original GAINS requirements:", length(required_vars), "variables\n")
cat("V8 report contains:", length(v8_vars), "variables\n\n")

# Categorize missing variables
missing <- required_vars[!required_vars %in% v8_vars]

cat("Missing variables by category:\n\n")

# 1. Primary Energy Electricity - detailed by fuel
pe_elec <- grep("Primary Energy\\|Electricity\\|", missing, value = TRUE)
cat("1. Primary Energy|Electricity|<fuel> (", length(pe_elec), "):\n", sep = "")
for (v in pe_elec) cat("   ", v, "\n")

# Check if V8 has aggregate electricity generation
cat("\n   V8 alternatives:\n")
v8_elec <- grep("Primary Energy.*Electricity", v8_vars, value = TRUE)
for (v in head(v8_elec, 10)) cat("   ", v, "\n")

# 2. Convert variables
convert <- grep("Convert", missing, value = TRUE)
cat("\n2. Convert variables (", length(convert), "):\n", sep = "")
for (v in convert) cat("   ", v, "\n")
cat("   → V8 does NOT report conversion/transformation sector\n")

# 3. Steel/Iron variables
steel <- grep("Steel", missing, value = TRUE)
cat("\n3. Steel variables (", length(steel), "):\n", sep = "")
for (v in steel) cat("   ", v, "\n")

cat("\n   V8 alternatives (Iron and Steel):\n")
v8_steel <- grep("Iron and Steel", v8_vars, value = TRUE)
for (v in head(v8_steel, 15)) cat("   ", v, "\n")

# 4. Feedstock
feedstock <- grep("Feedstock", missing, value = TRUE)
cat("\n4. Feedstock variables (", length(feedstock), "):\n", sep = "")
for (v in feedstock) cat("   ", v, "\n")
cat("   → V8 does NOT have Feedstock category\n")

# 5. Transportation Electricity
trans <- grep("Transportation.*Electricity", missing, value = TRUE)
cat("\n5. Transportation Electricity (", length(trans), "):\n", sep = "")
for (v in trans) cat("   ", v, "\n")

cat("\n   V8 alternatives:\n")
v8_trans_elec <- grep("Transportation.*Electricity", v8_vars, value = TRUE)
if (length(v8_trans_elec) > 0) {
  for (v in v8_trans_elec) cat("   ", v, "\n")
} else {
  cat("   → NOT FOUND in V8\n")
}

# 6. Off-road Construction
offroad <- grep("Off-road", missing, value = TRUE)
cat("\n6. Off-road Construction (", length(offroad), "):\n", sep = "")
for (v in offroad) cat("   ", v, "\n")
cat("   → V8 does NOT report off-road construction separately\n")

# 7. Production variables
prod <- grep("Production\\|", missing, value = TRUE)
cat("\n7. Production variables (", length(prod), "):\n", sep = "")
for (v in prod) cat("   ", v, "\n")

cat("\n   V8 alternatives:\n")
v8_prod <- grep("^Production\\|", v8_vars, value = TRUE)
for (v in head(v8_prod, 15)) cat("   ", v, "\n")

# 8. Non-Energy Use by fuel
noneng <- grep("Non-Energy Use\\|(Biomass|Coal|Oil|Gas)$", missing, value = TRUE)
cat("\n8. Non-Energy Use by fuel (", length(noneng), "):\n", sep = "")
for (v in noneng) cat("   ", v, "\n")

cat("\n   V8 alternatives (more detailed):\n")
v8_noneng <- grep("Non-Energy Use\\|.*\\|(Biomass|Coal|Oil|Gas)", v8_vars, value = TRUE)
for (v in head(v8_noneng, 10)) cat("   ", v, "\n")

# Summary
cat("\n\n=== SUMMARY ===\n")
cat("Total missing:", length(missing), "\n")
cat("Categories:\n")
cat("  - Primary Energy|Electricity|<fuel>:", length(pe_elec), "(V8 doesn't break down by fuel)\n")
cat("  - Convert:", length(convert), "(V8 doesn't report)\n")
cat("  - Steel details:", length(steel), "(some exist as Iron and Steel)\n")
cat("  - Feedstock:", length(feedstock), "(V8 doesn't report)\n")
cat("  - Transportation|Electricity:", length(trans), "(V8 doesn't report separately)\n")
cat("  - Off-road Construction:", length(offroad), "(V8 doesn't report)\n")
cat("  - Production details:", length(prod), "(some aggregated)\n")
cat("  - Non-Energy Use by fuel:", length(noneng), "(V8 has more detailed paths)\n")

cat("\n✅ Saved analysis\n")
