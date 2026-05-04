# GCAM-China V8 GAINS 覆盖率验证（简化版）
# 日期: 2026-05-04

suppressPackageStartupMessages({
  library(dplyr)
})

cat("\n")
cat("================================================================================\n")
cat("GCAM-China V8 GAINS 覆盖率完整验证\n")
cat("================================================================================\n\n")

# 第一步：读取 GAINS 需求变量
cat("第一步：读取 GAINS 需求变量列表\n")
cat("--------------------------------------------------------------------------------\n")

gains_map <- read.csv("E:/GCAM/GCAM_tools/gcam2gains/GCAM_GAINS_SEC_ACT_MAP_V8.csv", 
                      stringsAsFactors = FALSE)

required_vars <- unique(gains_map$SOURCE_VARIABLE)
required_vars <- required_vars[required_vars != ""]

cat("✅ GAINS 需要的唯一变量数:", length(required_vars), "\n")
cat("   示例变量:\n")
for (i in 1:min(5, length(required_vars))) {
  cat("   -", required_vars[i], "\n")
}
cat("\n")

# 按区域分类
national_vars <- gains_map %>%
  filter(REGIONAL == "National") %>%
  pull(SOURCE_VARIABLE) %>%
  unique()

regional_vars <- gains_map %>%
  filter(REGIONAL == "Regional") %>%
  pull(SOURCE_VARIABLE) %>%
  unique()

cat("📍 按区域分类:\n")
cat("   National 变量:", length(national_vars), "个\n")
cat("   Regional 变量:", length(regional_vars), "个\n\n")

# 第二步：检查实际输出
cat("================================================================================\n")
cat("第二步：检查实际输出覆盖率\n")
cat("--------------------------------------------------------------------------------\n")

output_file <- "E:/GCAM/GCAM-China_v8/output/database_basexdb_v8_test_standardized.csv"

if (!file.exists(output_file)) {
  cat("❌ 找不到输出文件:", output_file, "\n")
  cat("   请先运行 generate_report() 生成输出\n\n")
  quit(status = 1)
}

cat("✅ 找到输出文件\n")
cat("   文件大小:", round(file.info(output_file)$size / 1024^2, 1), "MB\n")
cat("   修改时间:", format(file.info(output_file)$mtime), "\n\n")

cat("📖 读取输出文件（这可能需要几秒钟）...\n")
output_data <- read.csv(output_file, stringsAsFactors = FALSE)

cat("✅ 成功读取\n")
cat("   总行数:", format(nrow(output_data), big.mark = ","), "\n")
cat("   列数:", ncol(output_data), "\n\n")

output_vars <- unique(output_data$Variable)
cat("📊 输出中的唯一变量数:", length(output_vars), "\n\n")

# 第三步：计算覆盖率
cat("================================================================================\n")
cat("第三步：计算覆盖率\n")
cat("--------------------------------------------------------------------------------\n")

output_matched <- required_vars %in% output_vars
output_coverage <- sum(output_matched) / length(required_vars) * 100

cat("📊 实际输出覆盖率:\n")
cat("   ✅ 匹配变量:", sum(output_matched), "/", length(required_vars), "\n")
cat("   📈 覆盖率:", sprintf("%.1f%%", output_coverage), "\n\n")

# 列出缺失的变量
output_missing <- required_vars[!output_matched]
if (length(output_missing) > 0) {
  cat("❌ 实际输出缺失的变量 (", length(output_missing), "个):\n")
  for (var in output_missing) {
    # 检查是 National 还是 Regional
    region_type <- ifelse(var %in% national_vars, "National", "Regional")
    cat("   -", var, "(", region_type, ")\n")
  }
  cat("\n")
} else {
  cat("🎉 实际输出：所有 GAINS 变量都存在！\n\n")
}

# 第四步：按类别分析
cat("================================================================================\n")
cat("第四步：按类别分析\n")
cat("--------------------------------------------------------------------------------\n")

# 分析 National 变量
national_matched <- national_vars %in% output_vars
national_coverage <- sum(national_matched) / length(national_vars) * 100

cat("📍 National 变量覆盖率:\n")
cat("   ✅ 匹配:", sum(national_matched), "/", length(national_vars), "\n")
cat("   📈 覆盖率:", sprintf("%.1f%%", national_coverage), "\n")

if (sum(!national_matched) > 0) {
  cat("   ❌ 缺失:\n")
  for (var in national_vars[!national_matched]) {
    cat("      -", var, "\n")
  }
}
cat("\n")

# 分析 Regional 变量
regional_matched <- regional_vars %in% output_vars
regional_coverage <- sum(regional_matched) / length(regional_vars) * 100

cat("📍 Regional 变量覆盖率:\n")
cat("   ✅ 匹配:", sum(regional_matched), "/", length(regional_vars), "\n")
cat("   📈 覆盖率:", sprintf("%.1f%%", regional_coverage), "\n")

if (sum(!regional_matched) > 0) {
  cat("   ❌ 缺失:\n")
  for (var in regional_vars[!regional_matched]) {
    cat("      -", var, "\n")
  }
}
cat("\n")

# 第五步：保存详细报告
cat("================================================================================\n")
cat("第五步：保存详细报告\n")
cat("--------------------------------------------------------------------------------\n")

comparison <- data.frame(
  Variable = required_vars,
  In_Output = required_vars %in% output_vars,
  Regional = ifelse(required_vars %in% national_vars, "National", "Regional"),
  stringsAsFactors = FALSE
)

comparison$Status <- ifelse(comparison$In_Output, "✅ 已覆盖", "❌ 缺失")

report_path <- "output/v8_gains_coverage_report.csv"
dir.create("output", showWarnings = FALSE, recursive = TRUE)
write.csv(comparison, report_path, row.names = FALSE)

cat("✅ 详细报告已保存:\n")
cat("   ", report_path, "\n\n")

# 最终总结
cat("================================================================================\n")
cat("🎯 最终总结\n")
cat("================================================================================\n\n")

cat("📊 GAINS 需求变量总数:", length(required_vars), "\n")
cat("   - National:", length(national_vars), "个\n")
cat("   - Regional:", length(regional_vars), "个\n\n")

cat("📤 实际输出覆盖情况:\n")
cat("   ✅ 已覆盖:", sum(output_matched), "个\n")
cat("   ❌ 缺失:", length(output_missing), "个\n")
cat("   📈 总覆盖率:", sprintf("%.1f%%", output_coverage), "\n\n")

cat("📍 分类覆盖率:\n")
cat("   - National:", sprintf("%.1f%%", national_coverage), 
    "(", sum(national_matched), "/", length(national_vars), ")\n")
cat("   - Regional:", sprintf("%.1f%%", regional_coverage), 
    "(", sum(regional_matched), "/", length(regional_vars), ")\n\n")

# 判断是否达标
if (output_coverage >= 100) {
  cat("🎉 恭喜！实际输出已 100% 覆盖所有 GAINS 变量！\n")
} else if (output_coverage >= 90) {
  cat("✅ 实际输出覆盖率优秀 (≥90%)！\n")
} else if (output_coverage >= 80) {
  cat("👍 实际输出覆盖率良好 (≥80%)！\n")
} else {
  cat("⚠️  实际输出覆盖率需要提升 (<80%)！\n")
}

cat("\n")
cat("================================================================================\n")
cat("验证完成！\n")
cat("================================================================================\n\n")
