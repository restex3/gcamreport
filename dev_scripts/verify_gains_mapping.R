# GCAM_GAINS_SEC_ACT_MAP 完整验证脚本

library(gcamreport)

cat("=== GCAM_GAINS_SEC_ACT_MAP 验证 ===\n\n")

# 1. 读取 GAINS 映射要求
gains_map <- read.csv('E:/GCAM/GCAM_tools/gcam2gains/GCAM_GAINS_SEC_ACT_MAP.csv', stringsAsFactors=FALSE)
required_vars <- sort(unique(gains_map$SOURCE_VARIABLE))

cat("GAINS 需要的变量数:", length(required_vars), "\n\n")

# 2. 读取 gcamreport 输出
output <- read.csv('E:/GCAM/GCAM_tools/gcamreport/output/gains_final.csv', stringsAsFactors=FALSE)
available_vars <- unique(output$Variable)

cat("gcamreport 输出的变量数:", length(available_vars), "\n\n")

# 3. 检查覆盖率
missing_vars <- c()
found_vars <- c()

for (var in required_vars) {
  if (var %in% available_vars) {
    found_vars <- c(found_vars, var)
  } else {
    missing_vars <- c(missing_vars, var)
  }
}

cat("=== 覆盖率统计 ===\n")
cat("✅ 找到:", length(found_vars), "/", length(required_vars),
    sprintf(" (%.1f%%)\n", 100 * length(found_vars) / length(required_vars)))
cat("❌ 缺失:", length(missing_vars), "\n\n")

# 4. 按类别统计
if (length(missing_vars) > 0) {
  cat("=== 缺失变量按类别 ===\n")

  categories <- list(
    "Agricultural Production" = grep("^Agricultural Production", missing_vars, value=TRUE),
    "Final Energy" = grep("^Final Energy", missing_vars, value=TRUE),
    "Primary Energy" = grep("^Primary Energy", missing_vars, value=TRUE),
    "Land Cover" = grep("^Land Cover", missing_vars, value=TRUE),
    "Production" = grep("^Production", missing_vars, value=TRUE),
    "Feedstock" = grep("^Feedstock", missing_vars, value=TRUE),
    "Resource" = grep("^Resource", missing_vars, value=TRUE),
    "Other" = setdiff(missing_vars, unlist(lapply(c("^Agricultural Production", "^Final Energy",
                                                      "^Primary Energy", "^Land Cover", "^Production",
                                                      "^Feedstock", "^Resource"),
                                                    function(p) grep(p, missing_vars, value=TRUE))))
  )

  for (cat_name in names(categories)) {
    vars <- categories[[cat_name]]
    if (length(vars) > 0) {
      cat("\n", cat_name, " (", length(vars), "):\n", sep="")
      for (var in vars) {
        cat("  -", var, "\n")
      }
    }
  }
}

# 5. 检查单位转换
cat("\n\n=== 单位转换检查 ===\n")

# 检查几个关键变量的单位
key_vars <- c(
  "Agricultural Production|Non-Energy|Livestock|Beef",
  "Land Cover|Cropland|Crops",
  "Final Energy|Industry|Electricity",
  "Primary Energy|Coal|Convert"
)

for (var in key_vars) {
  if (var %in% available_vars) {
    unit <- unique(output$Unit[output$Variable == var])
    gains_unit <- unique(gains_map$SOURCE_UNIT[gains_map$SOURCE_VARIABLE == var])
    gains_target_unit <- unique(gains_map$GAINS_UNIT[gains_map$SOURCE_VARIABLE == var])

    cat("\n变量:", var, "\n")
    cat("  gcamreport 单位:", unit, "\n")
    cat("  GAINS 源单位:", gains_unit, "\n")
    cat("  GAINS 目标单位:", gains_target_unit, "\n")

    # 检查单位是否匹配
    if (length(unit) == 1 && length(gains_unit) == 1) {
      if (unit == gains_unit) {
        cat("  ✅ 单位匹配\n")
      } else {
        cat("  ⚠️ 单位不匹配，需要转换\n")
      }
    }
  } else {
    cat("\n变量:", var, "\n")
    cat("  ❌ 变量缺失\n")
  }
}

cat("\n\n=== 验证完成 ===\n")
