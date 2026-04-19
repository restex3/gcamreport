# gcamreport R 包功能总结

**日期**: 2026-04-18
**版本**: 1.0.0
**分支**: dev-gcamchina_support

---

## 📦 R 包核心功能

`gcamreport` 是一个 R 包，用于从 GCAM（全球变化分析模型）输出生成符合 IAMC（综合评估建模联盟）标准的报告数据集。

### 支持的 GCAM 版本
- GCAM-core: 6.0, 7.0, 7.1, 7.2, 8.2
- **GCAM-China: 7.1** ✨

### 主要功能
1. 从 GCAM 数据库提取和标准化数据
2. 生成符合 IAMC 标准的报告变量
3. 交互式 Shiny UI 界面
4. 导出为 CSV/XLSX/RData 格式
5. 实时可视化和数据探索

---

## 🇨🇳 GCAM-China 专项优化

### 1. 目标

**使 `gcamreport` 成为官方 `GCAM-China-reporting` 工作流的实用替代品**，用于中国国家级 IAMC 数据导出。

### 2. 参考基准

- **验证数据库**: `E:/GCAM/GCAM-China_v7.1/output/China60Ref`
- **官方工作流**: `E:/GCAM/GCAM_tools/GCAM-China-reporting`
- **对比输出**: `official_GCAM_China_China60ref.csv`

---

## 🔧 已完成的五大优化阶段

### Phase 1: 运行时 GCAM-China 支持
**实现内容**:
- 运行时加载 `variables_functions_mapping.csv`
- 运行时加载 GCAM-China 查询 XML
- 运行时转换回退机制
- GCAM-China 特定文件的映射访问助手

**目的**: 确保本地 GCAM-China 查询和映射编辑能被报告工作流实际使用

---

### Phase 2: 官方 CO2 集成
**实现内容**:
- 集成官方 `CO2 emissions by sector` 查询
- 使用官方 `CO2_sector_map.csv` 和 `CO2_resource_map.csv`
- 修正中国特定的 CO2 部门标准化
- 直接注入最终中国 CO2 数据行

**覆盖变量**:
- `Emissions|CO2`
- `Emissions|CO2|Energy and Industrial Processes`
- `Emissions|CO2|Industrial Processes`
- `Emissions|CO2|AFOLU`
- `Emissions|CO2|Energy|Supply|*` (Gases, Liquids, Solids)

**关键修复**: 修复了工业过程排放被低估的 bug

---

### Phase 3: 电力发电和装机容量链
**实现内容**:
- 集成官方 `elec gen by gen tech (incl cogen)` 查询
- 使用官方 WEO 映射和装机容量文件
- 集成官方省级可再生能源容量因子调整
- 实现官方水电和屋顶光伏伪年份处理
- 修正 `EJ_to_GWh` 转换
- 移除 GCAM-China 分支的容量回退重复问题

**对齐变量**:
- `Secondary Energy|Electricity*`
- `Capacity|Electricity*`
- `Capacity Additions|Electricity*`

---

### Phase 4: 最终能源和资本成本对齐
**实现内容**:
- 切换到官方 `final_energy_map_detailedIndustry-ylv2-v7.csv`
- 切换到官方 `transport_final_en_map.csv`
- 禁用 GCAM-China 居民部门的意外十分位分割
- 切换到官方中国特定的 `L2234.*_CHINA.csv` 电力资本成本文件
- 对齐 GCAM-China 转换常数

**结果**: 全国对比从主要差异缩小到仅 `Final Energy` 变量的浮点噪声

---

### Phase 5: 维护和工程改进
**实现内容**:
- `approx_fun()` 对零点和单点情况的清洁回退
- `production_price_clean` 容忍缺失的可选生产价格查询
- 注入官方零值占位符（如地热装机容量）
- 添加官方对比脚本:
  - `GCAM-China_fullcheck.R`
  - `GCAM-China_compare_official.R`

**结果**: 完整验证运行可重现，警告量减少，维护更容易

---

## 📊 与官方 GCAM-China Reporting 对比

### 当前验证状态（最新快照）

| 指标 | 数值 |
|------|------|
| 官方中国变量数 | 118 |
| gcamreport 中国变量数 | 1,908 |
| 重叠变量数 | 118 |
| **完全相等的变量** | **113** |
| 剩余不相等变量 | 5 |

### 剩余差异

**仅为浮点精度噪声**，出现在 `Final Energy` 变量中：
- **最大绝对差异**: `8.54e-05 EJ/yr`

### 结论

✅ **国家级中国输出现在可以被视为与官方工作流在数值上等效**（针对已验证的变量集）

---

## 🎯 目前的进展

### ✅ 已完成
1. **CO2 排放链** - 完全对齐
2. **电力发电链** - 完全对齐
3. **装机容量链** - 完全对齐
4. **装机容量增量链** - 完全对齐
5. **最终能源链** - 对齐（仅浮点噪声）
6. **资本成本链** - 对齐

### 📈 优势
- **更多变量**: gcamreport 导出 1,908 个变量 vs 官方 118 个
- **运行时灵活性**: 无需重建包数据即可更新映射
- **可重现验证**: 标准化的对比脚本
- **更广泛的应用**: 同时支持 GCAM-core 和 GCAM-China

### ⚠️ 剩余维护项（非阻塞）
- 部分项目加载警告（针对仅存在于中国或部分省份的查询）
- `Vetting variables: ERROR` 仍出现在完整运行中（与世界级历史验证相关，不影响国家级中国 CSV）
- gcamreport 导出的变量远多于官方工作流（这是预期的，但如果需要严格的官方模板模式，可以后续添加）

---

## 📁 关键文件

### 核心逻辑
- `R/functions.R` - 主要函数实现
- `R/main.R` - 主工作流

### GCAM-China 映射文件（17个）
```
inst/extdata/mappings/GCAMChina7.1/
├── CO2_sector_map.csv
├── CO2_resource_map.csv
├── elec_gen_map_gcamchina.csv
├── gcam_weo_mapping.csv
├── IEAWEO2023_Capacity.csv
├── CF_tech_mapping.csv
├── df_CF_China_province_8_12.csv
├── final_energy_map_gcamchina.csv
├── transport_final_en_map_gcamchina.csv
├── L2234.GlobalIntTechCapital_elecS_CHINA.csv
├── L2234.GlobalTechCapital_elecS_CHINA.csv
└── variables_functions_mapping.csv
```

### 查询和元数据
- `inst/extdata/queries/GCAMChina7.1/queries_gcamreport_general.xml`
- `inst/extdata/saveDataFiles_GCAMChina7.1.R`

### 验证脚本
- `dev_scripts/GCAM-China_fullcheck.R` - 完整 gcamreport 运行
- `dev_scripts/GCAM-China_compare_official.R` - 官方对比

---

## 🔄 推荐的验证工作流

```r
# 1. 运行完整检查
source("dev_scripts/GCAM-China_fullcheck.R")

# 2. 与官方输出对比
source("dev_scripts/GCAM-China_compare_official.R")

# 3. 查看对比摘要
# E:/GCAM/GCAM_tools/tmp_china60ref_compare/fullcheck_summary.txt
```

---

## 📝 总结

### 核心成就

1. ✅ **功能等效**: gcamreport 现在可以作为官方 GCAM-China-reporting 的实用替代品
2. ✅ **数值对齐**: 118/118 官方变量完全覆盖，113 个完全相等
3. ✅ **更强大**: 提供 1,908 个变量（官方仅 118 个）
4. ✅ **可维护**: 运行时加载机制 + 标准化验证脚本
5. ✅ **通用性**: 同时支持 GCAM-core 和 GCAM-China

### 技术亮点

- **五阶段系统优化**: 从运行时支持到最终对齐
- **官方路径集成**: CO2、电力、容量链完全采用官方逻辑
- **工程健壮性**: 容错处理、回退机制、零值占位符
- **可重现验证**: 完整的对比工作流和文档

### 应用价值

gcamreport 现在提供了一个**统一的 R 包解决方案**，既能满足 GCAM-China 的官方报告需求，又能提供更广泛的变量空间用于进一步开发和分析。
