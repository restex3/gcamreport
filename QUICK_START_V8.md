# GCAM-China 8.0 快速入门指南

## 📦 安装

```r
# 安装 devtools（如果还没有）
install.packages("devtools")

# 从 GitHub 安装 gcamreport（GCAM-China 8.0 支持版本）
devtools::install_github("restex3/gcamreport", ref = "dev-gcamchina_support")
```

## 🚀 基本用法

### 1. 生成标准报告

```r
library(gcamreport)

# 设置参数
db_path <- "E:/GCAM/GCAM-China_v8.0/output/"
db_name <- "database_basexdb"
prj_name <- "gcamchina_v8.dat"
scenarios <- "Reference"
GCAM_version <- "vGCAMChina8.0"

# 生成报告
report <- generate_report(
  db_path = db_path,
  db_name = db_name,
  prj_name = prj_name,
  scenarios = scenarios,
  GCAM_version = GCAM_version,
  final_year = 2100
)

# 查看结果
head(report)
dim(report)  # 应该有 2148 个变量
```

### 2. 多场景对比

```r
# 读取多个场景
scenarios <- c("Reference", "Policy1", "Policy2")

report_multi <- generate_report(
  db_path = db_path,
  db_name = db_name,
  prj_name = prj_name,
  scenarios = scenarios,
  GCAM_version = "vGCAMChina8.0"
)

# 按场景分组查看
library(dplyr)
report_multi %>%
  filter(Variable == "Emissions|CO2") %>%
  select(Scenario, Region, `2030`, `2050`, `2100`)
```

### 3. 省级数据提取

```r
# GCAM-China 8.0 包含 70 个区域（中国各省份）
unique(report$Region)

# 提取特定省份的数据
beijing_data <- report %>%
  filter(Region == "Beijing")

# 提取所有省份的能源消费
energy_by_province <- report %>%
  filter(grepl("Final Energy", Variable)) %>%
  select(Region, Variable, `2030`, `2050`)
```

## 📊 常用变量示例

### 碳排放

```r
# CO2 排放
co2_emissions <- report %>%
  filter(Variable == "Emissions|CO2")

# 按部门的 CO2 排放
co2_by_sector <- report %>%
  filter(grepl("Emissions\\|CO2\\|Energy", Variable))
```

### 能源消费

```r
# 一次能源
primary_energy <- report %>%
  filter(grepl("^Primary Energy\\|", Variable))

# 最终能源
final_energy <- report %>%
  filter(grepl("^Final Energy\\|", Variable))

# 电力生产
electricity <- report %>%
  filter(grepl("Secondary Energy\\|Electricity", Variable))
```

### 农业生产

```r
# 农业生产
ag_production <- report %>%
  filter(grepl("Agricultural Production", Variable))

# 土地利用
land_use <- report %>%
  filter(grepl("Land Cover", Variable))
```

## 🔄 与 GAINS 模型对接

```r
# GCAM-China 8.0 支持与 GAINS 模型的数据转换
# 覆盖率：97.5%（79/81 变量）

# 注意：需要额外的 GAINS 转换函数
# 详见：inst/extdata/mappings/GCAM2GAINS/
```

## 📈 导出结果

### 导出为 CSV

```r
# 标准化格式
write.csv(report, "gcamchina_v8_report.csv", row.names = FALSE)

# IAMC 格式（用于模型比较）
report_iamc <- report %>%
  select(Model, Scenario, Region, Variable, Unit, everything())
write.csv(report_iamc, "gcamchina_v8_iamc.csv", row.names = FALSE)
```

### 导出为 Excel

```r
library(openxlsx)

# 创建多工作表 Excel 文件
wb <- createWorkbook()

# 完整报告
addWorksheet(wb, "Full Report")
writeData(wb, "Full Report", report)

# CO2 排放
addWorksheet(wb, "CO2 Emissions")
writeData(wb, "CO2 Emissions",
          report %>% filter(grepl("Emissions\\|CO2", Variable)))

# 能源
addWorksheet(wb, "Energy")
writeData(wb, "Energy",
          report %>% filter(grepl("Energy", Variable)))

saveWorkbook(wb, "gcamchina_v8_report.xlsx", overwrite = TRUE)
```

## 🎯 V8.0 新特性

### 相比 V7.1 的改进

1. **更多变量**: 2,148 个变量（V7.1 约 2,000 个）
2. **基于 GCAM 8.2**: 包含最新的模型改进
3. **更细致的部门分类**: 特别是工业和交通部门
4. **改进的碳捕集技术**: 更详细的 CCS 技术表示

### 碳排放计算

```r
# V8.0 的碳排放计算与 V7.1 原理一致
# 基于：燃料消耗量 × 碳含量系数

# 查看碳含量系数
data("carbon_content_vGCAMChina8.0", package = "gcamreport")
print(carbon_content_vGCAMChina8.0)
```

## 🔧 故障排除

### 常见问题

**问题 1**: 找不到数据库文件
```r
# 确认路径正确
list.files("E:/GCAM/GCAM-China_v8.0/output/", pattern = ".basex")
```

**问题 2**: 内存不足
```r
# 限制年份范围
report <- generate_report(
  db_path = db_path,
  db_name = db_name,
  prj_name = prj_name,
  scenarios = scenarios,
  GCAM_version = "vGCAMChina8.0",
  final_year = 2050  # 只到 2050 年
)
```

**问题 3**: 某些变量缺失
```r
# 检查可用变量
available_vars <- unique(report$Variable)
length(available_vars)  # 应该约 2148 个

# 搜索特定变量
grep("Coal", available_vars, value = TRUE)
```

## 📚 更多资源

- **GitHub 仓库**: https://github.com/restex3/gcamreport
- **分支**: `dev-gcamchina_support`
- **文档**: `docs/gcam-china/`
- **GAINS 接口**: `output/V8_GAINS_INTERFACE_STATUS.md`

## 💡 提示

1. **首次运行较慢**: 第一次生成报告需要加载所有数据，约 2-5 分钟
2. **使用 .dat 文件**: 生成的 `.dat` 文件可以重复使用，加快后续分析
3. **省级数据**: V8.0 包含中国所有省份的详细数据
4. **版本兼容**: 代码同时支持 V7.1 和 V8.0，只需更改 `GCAM_version` 参数

---

**最后更新**: 2026-04-29
**版本**: GCAM-China 8.0
**Commit**: 2698fe15
