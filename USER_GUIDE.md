# GCAM-China 8.0 使用指南

## 快速开始

### 1. 重新安装包

```r
# 方法 1: 从源代码安装（推荐）
devtools::install('e:/GCAM/GCAM_tools/gcamreport', upgrade='never')

# 方法 2: 使用 load_all 进行开发测试
devtools::load_all('e:/GCAM/GCAM_tools/gcamreport')
```

### 2. 生成 V8 报告

```r
library(gcamreport)

# 生成完整报告
report_v8 <- generate_report(
  prj_name = 'E:/GCAM/GCAM-China_v8/output/database_basexdb.dat',
  scenarios = 'Reference',
  GCAM_version = 'vGCAMChina8.0',
  final_year = 2050,
  save_output = TRUE,
  launch_ui = FALSE
)
```

### 3. 验证 GAINS 覆盖率

```r
# 加载 GAINS 映射
gains_map <- read.csv('E:/GCAM/GCAM_tools/gcam2gains/GCAM_GAINS_SEC_ACT_MAP.csv',
                      stringsAsFactors = FALSE)
required_vars <- unique(gains_map$SOURCE_VARIABLE)

# 检查覆盖率
v8_vars <- unique(report_v8$Variable)
matched <- sum(required_vars %in% v8_vars)
coverage <- 100 * matched / length(required_vars)

cat('GAINS Coverage:', round(coverage, 1), '%\n')
cat('Matched:', matched, '/', length(required_vars), '\n')

# 列出缺失的变量
missing <- required_vars[!required_vars %in% v8_vars]
cat('\nMissing variables:\n')
for(v in missing) cat('  -', v, '\n')
```

## 新增功能

### Primary Energy Convert 变量

V8 现在支持 4 个 Convert 变量：
- `Primary Energy|Biomass|Convert`
- `Primary Energy|Coal|Convert`
- `Primary Energy|Gas|Convert`
- `Primary Energy|Oil|Convert`

### Primary Energy Electricity 变量

V8 现在支持 10+ 个 Electricity 变量：
- `Primary Energy|Electricity|Biomass|w/ CCS`
- `Primary Energy|Electricity|Biomass|w/o CCS`
- `Primary Energy|Electricity|Coal|w/o CCS`
- `Primary Energy|Electricity|Gas|w/o CCS`
- `Primary Energy|Electricity|Geothermal`
- `Primary Energy|Electricity|Hydro`
- `Primary Energy|Electricity|Nuclear`
- `Primary Energy|Electricity|Oil|w/o CCS`
- `Primary Energy|Electricity|Solar`
- `Primary Energy|Electricity|Wind`

### Non-Energy Use 聚合

V8 现在自动聚合 Non-Energy Use 变量：
- `Final Energy|Non-Energy Use|Biomass`
- `Final Energy|Non-Energy Use|Coal`
- `Final Energy|Non-Energy Use|Oil`
- `Final Energy|Non-Energy Use|Gas`

## 测试单个函数

如果需要测试特定功能：

```r
devtools::load_all('e:/GCAM/GCAM_tools/gcamreport')

# 加载项目
prj <- rgcam::loadProject('path/to/database.dat')
prj <<- prj
desired_variables.global <<- 'All'

# 测试 Primary Energy
get_primary_energy('vGCAMChina8.0')
cat('Primary Energy rows:', nrow(primary_energy_clean), '\n')

# 测试 Primary Energy Electricity
get_primary_energy_electricity('vGCAMChina8.0')
cat('Electricity rows:', nrow(primary_energy_electricity_clean), '\n')

# 测试 Non-Energy Use
get_fe_sector_tmp('vGCAMChina8.0')
cat('Final Energy rows:', nrow(fe_sector), '\n')
```

## 与 V7.1 的兼容性

所有修改都使用版本检查，确保 V7.1 的功能不受影响：

```r
# V7.1 仍然正常工作
report_v71 <- generate_report(
  prj_name = 'path/to/v71/database.dat',
  scenarios = 'Reference',
  GCAM_version = 'vGCAMChina7.1',
  final_year = 2050
)
```

## 故障排除

### 问题：generate_report() 返回空数据

**解决方案**：使用 `devtools::load_all()` 而不是已安装的包

```r
devtools::load_all('e:/GCAM/GCAM_tools/gcamreport')
# 然后再调用 generate_report()
```

### 问题：缺少某些 GAINS 变量

**检查步骤**：
1. 确认使用的是 `vGCAMChina8.0` 版本
2. 检查 `primary_energy_map_vGCAMChina8.0.rda` 是否已重建
3. 验证函数是否被调用（检查全局变量）

```r
# 检查全局变量
ls(envir = .GlobalEnv, pattern = "primary_energy")
```

### 问题：filter_variables() 过滤掉变量

**原因**：`desired_variables.global` 设置不正确

**解决方案**：
```r
desired_variables.global <<- 'All'
```

## 性能优化

对于大型数据库，可以只生成需要的变量：

```r
# 只生成 Primary Energy 相关变量
report_pe <- generate_report(
  prj_name = 'path/to/database.dat',
  scenarios = 'Reference',
  GCAM_version = 'vGCAMChina8.0',
  final_year = 2050,
  desired_variables = c('Primary Energy'),
  save_output = FALSE
)
```

## 文档

详细文档请参考：
- [FINAL_SUMMARY.md](FINAL_SUMMARY.md) - 完整项目总结
- [STAGE_1_2_SUCCESS_SUMMARY.md](STAGE_1_2_SUCCESS_SUMMARY.md) - 阶段 1-2 详情
- [STAGE_3_SUCCESS.md](STAGE_3_SUCCESS.md) - 阶段 3 详情

## 支持

如有问题，请检查：
1. R 版本 ≥ 4.0
2. 所有依赖包已安装
3. GCAM 数据库文件路径正确
4. 使用正确的 GCAM_version 参数

## 更新日志

### v8.0 (2026-04-30)
- ✅ 添加 Primary Energy Convert 变量支持
- ✅ 添加 Primary Energy Electricity 变量支持
- ✅ 添加 Non-Energy Use 聚合功能
- ✅ 修复 gather_map() 缺失 bug
- ✅ 修复 filter_variables() 过滤 GAINS 变量问题
- ✅ GAINS 覆盖率从 59% 提升到 81%
