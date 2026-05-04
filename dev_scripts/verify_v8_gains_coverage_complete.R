# GCAM-China V8 GAINS 覆盖率完整验证
# 日期: 2026-05-04
# 目的: 从代码和实际输出两个方向验证 GAINS 映射覆盖率

library(dplyr)
library(tidyr)

cat(paste(rep("=", 80), collapse = ""), "\n")
cat("GCAM-China V8 GAINS 覆盖率完整验证\n")
cat(paste(rep("=", 80), collapse = ""), "\n\n")

# ============================================================================
# 第一部分：读取 GAINS 需求文件
# ============================================================================

cat("📋 第一步：读取 GAINS 需求变量列表\n")
cat(paste(rep("-", 80), collapse = ""), "\n")

gains_map_path <- "E:/GCAM/GCAM_tools/gcam2gains/GCAM_GAINS_SEC_ACT_MAP_V8.csv"

if (!file.exists(gains_map_path)) {
  stop("❌ 找不到 GAINS 映射文件: ", gains_map_path)
}

gains_map <- read.csv(gains_map_path, stringsAsFactors = FALSE)

cat("✅ 成功读取 GAINS 映射文件\n")
cat("   文件路径:", gains_map_path, "\n")
cat("   总行数:", nrow(gains_map), "\n\n")

# 提取唯一的 SOURCE_VARIABLE
required_vars <- unique(gains_map$SOURCE_VARIABLE)
required_vars <- required_vars[required_vars != ""]  # 移除空值

cat("📊 GAINS 需要的唯一变量数:", length(required_vars), "\n")
cat("   示例变量:\n")
for (i in 1:min(5, length(required_vars))) {
  cat("   -", required_vars[i], "\n")
}
cat("\n")

# 按 REGIONAL 分类统计
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

# ============================================================================
# 第二部分：检查代码层面的映射配置
# ============================================================================

cat(paste(rep("=", 80), collapse = ""), "\n")
cat("🔧 第二步：检查代码层面的映射配置\n")
cat(paste(rep("-", 80), collapse = ""), "\n")

# 检查 template
template_path <- "inst/extdata/mappings/GCAMChina8.0/variables_functions_mapping.csv"

if (!file.exists(template_path)) {
  cat("⚠️  找不到 template 文件:", template_path, "\n")
  cat("   尝试从 data 对象加载...\n")
  
  # 尝试加载包
  if (!require(gcamreport, quietly = TRUE)) {
    devtools::load_all(".", quiet = TRUE)
  }
  
  # 从包数据加载
  template_vars <- get("template_vGCAMChina8.0")$variable
} else {
  template_df <- read.csv(template_path, stringsAsFactors = FALSE)
  template_vars <- unique(template_df$variable)
}

cat("✅ Template 中的变量数:", length(template_vars), "\n\n")

# 检查映射文件覆盖情况
mapping_files <- list.files(
  "inst/extdata/mappings/GCAMChina8.0",
  pattern = "\\.csv$",
  full.names = TRUE
)

cat("📁 找到", length(mapping_files), "个映射文件\n\n")

# 统计代码层面的覆盖
code_matched <- required_vars %in% template_vars
code_coverage <- sum(code_matched) / length(required_vars) * 100

cat("📊 代码层面覆盖率:\n")
cat("   匹配变量:", sum(code_matched), "/", length(required_vars), "\n")
cat("   覆盖率:", sprintf("%.1f%%", code_coverage), "\n\n")

# 列出代码层面缺失的变量
code_missing <- required_vars[!code_matched]
if (length(code_missing) > 0) {
  cat("❌ 代码层面缺失的变量 (", length(code_missing), "个):\n")
  for (var in code_missing) {
    cat("   -", var, "\n")
  }
  cat("\n")
} else {
  cat("✅ 代码层面：所有 GAINS 变量都在 template 中！\n\n")
}

# ============================================================================
# 第三部分：检查实际输出
# ============================================================================

cat(paste(rep("=", 80), collapse = ""), "\n")
cat("📤 第三步：检查实际输出覆盖率\n")
cat(paste(rep("-", 80), collapse = ""), "\n")

# 查找最新的输出文件
output_files <- list.files(
  "E:/GCAM/GCAM-China_v8/output",
  pattern = ".*standardized\\.csv$",
  full.names = TRUE
)

if (length(output_files) == 0) {
  cat("⚠️  找不到现成的输出文件，需要运行 generate_report()\n")
  cat("   跳过实际输出验证...\n\n")
  output_verified <- FALSE
} else {
  # 使用最新的文件
  latest_output <- output_files[which.max(file.info(output_files)$mtime)]
  
  cat("✅ 找到输出文件:\n")
  cat("   ", latest_output, "\n")
  cat("   文件大小:", round(file.info(latest_output)$size / 1024^2, 1), "MB\n")
  cat("   修改时间:", format(file.info(latest_output)$mtime), "\n\n")
  
  cat("📖 读取输出文件...\n")
  output_data <- read.csv(latest_output, stringsAsFactors = FALSE)
  
  cat("✅ 成功读取\n")
  cat("   总行数:", nrow(output_data), "\n")
  cat("   列数:", ncol(output_data), "\n\n")
  
  # 提取输出中的变量
  output_vars <- unique(output_data$Variable)
  
  cat("📊 输出中的唯一变量数:", length(output_vars), "\n\n")
  
  # 统计实际输出覆盖
  output_matched <- required_vars %in% output_vars
  output_coverage <- sum(output_matched) / length(required_vars) * 100
  
  cat("📊 实际输出覆盖率:\n")
  cat("   匹配变量:", sum(output_matched), "/", length(required_vars), "\n")
  cat("   覆盖率:", sprintf("%.1f%%", output_coverage), "\n\n")
  
  # 列出实际输出缺失的变量
  output_missing <- required_vars[!output_matched]
  if (length(output_missing) > 0) {
    cat("❌ 实际输出缺失的变量 (", length(output_missing), "个):\n")
    for (var in output_missing) {
      cat("   -", var, "\n")
    }
    cat("\n")
  } else {
    cat("✅ 实际输出：所有 GAINS 变量都存在！\n\n")
  }
  
  output_verified <- TRUE
}

# ============================================================================
# 第四部分：生成详细报告
# ============================================================================

cat(paste(rep("=", 80), collapse = ""), "\n")
cat("📋 第四步：生成详细报告\n")
cat("-" %R% 80, "\n\n")

# 创建对比表
comparison <- data.frame(
  Variable = required_vars,
  In_Template = required_vars %in% template_vars,
  stringsAsFactors = FALSE
)

if (output_verified) {
  comparison$In_Output <- required_vars %in% output_vars
  comparison$Status <- ifelse(
    comparison$In_Template & comparison$In_Output,
    "✅ 完全覆盖",
    ifelse(
      comparison$In_Template & !comparison$In_Output,
      "⚠️  仅在代码",
      ifelse(
        !comparison$In_Template & comparison$In_Output,
        "🔍 仅在输出",
        "❌ 完全缺失"
      )
    )
  )
} else {
  comparison$Status <- ifelse(
    comparison$In_Template,
    "✅ 在代码中",
    "❌ 代码缺失"
  )
}

# 按 REGIONAL 分类
comparison$Regional <- ifelse(
  comparison$Variable %in% national_vars,
  "National",
  "Regional"
)

# 保存详细报告
report_path <- "output/v8_gains_coverage_report.csv"
write.csv(comparison, report_path, row.names = FALSE)

cat("✅ 详细报告已保存:\n")
cat("   ", report_path, "\n\n")

# ============================================================================
# 第五部分：最终总结
# ============================================================================

cat(paste(rep("=", 80), collapse = ""), "\n")
cat("🎯 最终总结\n")
cat("=" %R% 80, "\n\n")

cat("📊 GAINS 需求变量总数:", length(required_vars), "\n\n")

cat("🔧 代码层面 (Template):\n")
cat("   ✅ 已覆盖:", sum(code_matched), "个\n")
cat("   ❌ 缺失:", length(code_missing), "个\n")
cat("   📈 覆盖率:", sprintf("%.1f%%", code_coverage), "\n\n")

if (output_verified) {
  cat("📤 实际输出:\n")
  cat("   ✅ 已覆盖:", sum(output_matched), "个\n")
  cat("   ❌ 缺失:", length(output_missing), "个\n")
  cat("   📈 覆盖率:", sprintf("%.1f%%", output_coverage), "\n\n")
  
  # 交叉分析
  both_covered <- sum(comparison$In_Template & comparison$In_Output)
  only_template <- sum(comparison$In_Template & !comparison$In_Output)
  only_output <- sum(!comparison$In_Template & comparison$In_Output)
  both_missing <- sum(!comparison$In_Template & !comparison$In_Output)
  
  cat("🔍 交叉分析:\n")
  cat("   ✅ 代码+输出都有:", both_covered, "个\n")
  cat("   ⚠️  仅在代码中:", only_template, "个\n")
  cat("   🔍 仅在输出中:", only_output, "个\n")
  cat("   ❌ 完全缺失:", both_missing, "个\n\n")
}

# 判断是否达标
if (code_coverage >= 100) {
  cat("🎉 恭喜！代码层面已 100% 覆盖所有 GAINS 变量！\n")
} else if (code_coverage >= 90) {
  cat("✅ 代码层面覆盖率优秀 (≥90%)！\n")
} else if (code_coverage >= 80) {
  cat("👍 代码层面覆盖率良好 (≥80%)！\n")
} else {
  cat("⚠️  代码层面覆盖率需要提升 (<80%)！\n")
}

if (output_verified) {
  if (output_coverage >= 100) {
    cat("🎉 恭喜！实际输出已 100% 覆盖所有 GAINS 变量！\n")
  } else if (output_coverage >= 90) {
    cat("✅ 实际输出覆盖率优秀 (≥90%)！\n")
  } else if (output_coverage >= 80) {
    cat("👍 实际输出覆盖率良好 (≥80%)！\n")
  } else {
    cat("⚠️  实际输出覆盖率需要提升 (<80%)！\n")
  }
}

cat("\n")
cat(paste(rep("=", 80), collapse = ""), "\n")
cat("验证完成！\n")
cat(paste(rep("=", 80), collapse = ""), "\n")
