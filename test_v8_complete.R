# 完整的 V8 GAINS 测试脚本
# 使用已安装的包 + 手动添加别名

library(gcamreport)

cat("=== GCAM-China 8.0 Complete GAINS Test ===\n\n")

# 1. 生成报告
cat("Step 1: Generating report...\n")
report_v8 <- generate_report(
  prj_name = 'E:/GCAM/GCAM-China_v8/output/database_basexdb_v8_test.dat',
  scenarios = 'Reference',
  GCAM_version = 'vGCAMChina8.0',
  final_year = 2050,
  save_output = FALSE,
  launch_ui = FALSE
)

cat("Report generated:", nrow(report_v8), "rows,", length(unique(report_v8$Variable)), "variables\n\n")

# 2. 手动添加别名（如果 generate_report 没有自动添加）
cat("Step 2: Adding GAINS aliases...\n")

alias_mappings <- list(
  "Agricultural Production|Livestock|Ruminant|Meat" = c(
    "Agricultural Production|Non-Energy|Livestock|Beef",
    "Agricultural Production|Non-Energy|Livestock|SheepGoat"
  ),
  "Agricultural Production|Livestock|Ruminant|Dairy" = "Agricultural Production|Non-Energy|Livestock|Dairy",
  "Agricultural Production|Livestock|Non-Ruminant|Meat|Pig" = "Agricultural Production|Non-Energy|Livestock|Pork",
  "Agricultural Production|Livestock|Non-Ruminant|Meat|Poultry" = "Agricultural Production|Non-Energy|Livestock|Poultry",
  "Land Cover|Cropland" = c("Land Cover|Cropland|Otherarable", "Land Cover|Cropland|Crops"),
  "Land Cover|Forest" = "Land Cover|Forest|Managed",
  "Land Cover|Pasture" = "Land Cover|Pasture|Grazed",
  "Production|Non-Metallic Minerals|Cement" = "Production|Cement",
  "Production|Chemicals|Ammonia" = c("Production|Chemicals|Nitrogen Fertilizer", "Production|Chemicals|Fertilizer"),
  "Production|Iron and Steel|Steel" = c(
    "Production|Steel|Blast Furnace",
    "Production|Steel|EAF-scrap",
    "Production|Steel|EAF-DRI",
    "Production|Steel|Hydrogen-DRI"
  ),
  "Final Energy|Industry|Iron and Steel|Gases" = "Final Energy|Industry|Steel|Gases",
  "Final Energy|Industry|Iron and Steel|Liquids" = "Final Energy|Industry|Steel|Liquids"
)

gains_aliases <- list()
for (source_var in names(alias_mappings)) {
  target_vars <- alias_mappings[[source_var]]
  source_data <- report_v8[report_v8$Variable == source_var, ]
  if (nrow(source_data) > 0) {
    for (target_var in target_vars) {
      alias_data <- source_data
      alias_data$Variable <- target_var
      gains_aliases[[length(gains_aliases) + 1]] <- alias_data
    }
  }
}

if (length(gains_aliases) > 0) {
  report_v8_final <- rbind(report_v8, do.call(rbind, gains_aliases))
  report_v8_final <- report_v8_final[!duplicated(report_v8_final[c('Model', 'Scenario', 'Region', 'Variable', 'Unit')]), ]
  cat("Added", length(gains_aliases), "aliases\n")
} else {
  report_v8_final <- report_v8
  cat("No aliases added (may already be in report)\n")
}

cat("Final report:", nrow(report_v8_final), "rows,", length(unique(report_v8_final$Variable)), "variables\n\n")

# 3. 检查 GAINS 覆盖率
cat("Step 3: Checking GAINS coverage...\n")
gains_map <- read.csv('E:/GCAM/GCAM_tools/gcam2gains/GCAM_GAINS_SEC_ACT_MAP.csv',
                      stringsAsFactors = FALSE)
required_vars <- unique(gains_map$SOURCE_VARIABLE)
v8_vars <- unique(report_v8_final$Variable)

matched <- sum(required_vars %in% v8_vars)
coverage <- 100 * matched / length(required_vars)

cat("\n=== GAINS Coverage Results ===\n")
cat("Total required:", length(required_vars), "\n")
cat("Matched:", matched, "\n")
cat("Coverage:", round(coverage, 1), "%\n\n")

# 4. 列出缺失的变量
missing <- required_vars[!required_vars %in% v8_vars]
if (length(missing) > 0) {
  cat("Missing variables (", length(missing), "):\n", sep="")
  for (v in missing) {
    cat("  -", v, "\n")
  }
}

cat("\n=== Test Complete ===\n")
cat("Expected coverage: 90-95%\n")
cat("Actual coverage:", round(coverage, 1), "%\n")

if (coverage >= 90) {
  cat("\n✓ SUCCESS: Target achieved!\n")
} else if (coverage >= 85) {
  cat("\n⚠ PARTIAL: Above 85% but below 90%\n")
} else {
  cat("\n✗ BELOW TARGET\n")
}
