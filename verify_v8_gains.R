# GCAM-China 8.0 验证脚本
# 用于验证 GAINS 覆盖率

library(gcamreport)

cat("=== GCAM-China 8.0 GAINS Coverage Verification ===\n\n")

# 1. 生成报告
cat("Step 1: Generating V8 report...\n")
report_v8 <- generate_report(
  prj_name = 'E:/GCAM/GCAM-China_v8/output/database_basexdb_v8_test.dat',
  scenarios = 'Reference',
  GCAM_version = 'vGCAMChina8.0',
  final_year = 2050,
  save_output = FALSE,
  launch_ui = FALSE
)

cat("Report generated:", nrow(report_v8), "rows\n\n")

# 2. 检查 GAINS 覆盖率
cat("Step 2: Checking GAINS coverage...\n")
gains_map <- read.csv('E:/GCAM/GCAM_tools/gcam2gains/GCAM_GAINS_SEC_ACT_MAP.csv',
                      stringsAsFactors = FALSE)
required_vars <- unique(gains_map$SOURCE_VARIABLE)
v8_vars <- unique(report_v8$Variable)
matched <- sum(required_vars %in% v8_vars)
coverage <- 100 * matched / length(required_vars)

cat("\n=== GAINS Coverage Results ===\n")
cat("Total required variables:", length(required_vars), "\n")
cat("Matched variables:", matched, "\n")
cat("Coverage:", round(coverage, 1), "%\n\n")

# 3. 检查新增的变量
cat("Step 3: Verifying new variables...\n\n")

# Primary Energy Convert
convert_vars <- c('Primary Energy|Biomass|Convert',
                  'Primary Energy|Coal|Convert',
                  'Primary Energy|Gas|Convert',
                  'Primary Energy|Oil|Convert')
convert_found <- sum(convert_vars %in% v8_vars)
cat("Primary Energy Convert:", convert_found, "/ 4\n")
for(v in convert_vars) {
  status <- if(v %in% v8_vars) "✓" else "✗"
  cat("  ", status, v, "\n")
}

# Primary Energy Electricity
elec_vars <- c('Primary Energy|Electricity|Biomass|w/ CCS',
               'Primary Energy|Electricity|Biomass|w/o CCS',
               'Primary Energy|Electricity|Coal|w/o CCS',
               'Primary Energy|Electricity|Gas|w/o CCS',
               'Primary Energy|Electricity|Geothermal',
               'Primary Energy|Electricity|Hydro',
               'Primary Energy|Electricity|Nuclear',
               'Primary Energy|Electricity|Oil|w/o CCS',
               'Primary Energy|Electricity|Solar',
               'Primary Energy|Electricity|Wind')
elec_found <- sum(elec_vars %in% v8_vars)
cat("\nPrimary Energy Electricity:", elec_found, "/ 10\n")
for(v in elec_vars) {
  status <- if(v %in% v8_vars) "✓" else "✗"
  cat("  ", status, v, "\n")
}

# Non-Energy Use
neu_vars <- c('Final Energy|Non-Energy Use|Biomass',
              'Final Energy|Non-Energy Use|Coal',
              'Final Energy|Non-Energy Use|Oil',
              'Final Energy|Non-Energy Use|Gas')
neu_found <- sum(neu_vars %in% v8_vars)
cat("\nNon-Energy Use:", neu_found, "/ 4\n")
for(v in neu_vars) {
  status <- if(v %in% v8_vars) "✓" else "✗"
  cat("  ", status, v, "\n")
}

# 4. 总结
cat("\n=== Summary ===\n")
cat("Total new variables:", convert_found + elec_found + neu_found, "/ 18\n")
cat("Expected coverage: ~81%\n")
cat("Actual coverage:", round(coverage, 1), "%\n")

if(coverage >= 80) {
  cat("\n✓ SUCCESS: Coverage target achieved!\n")
} else {
  cat("\n✗ WARNING: Coverage below target\n")
}

# 5. 列出仍然缺失的 GAINS 变量
missing <- required_vars[!required_vars %in% v8_vars]
if(length(missing) > 0) {
  cat("\nMissing GAINS variables (", length(missing), "):\n", sep="")
  for(v in head(missing, 20)) {
    cat("  -", v, "\n")
  }
  if(length(missing) > 20) {
    cat("  ... and", length(missing) - 20, "more\n")
  }
}

cat("\n=== Verification Complete ===\n")
