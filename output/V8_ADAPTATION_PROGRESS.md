# GCAM-China 8.0 适配进展报告

**日期**: 2026-04-28
**状态**: 进行中 - 已修复2个映射问题

---

## ✅ 已完成的工作

### 1. 修复 ag_demand_map 缺失映射
**问题**: `ag_demand_map_vGCAMChina8.0` 缺少两个关键映射
- `regional woodpulp` → `NonFoodDemand_woodpulp`
- `regional biomass` → `regional biomass`

**解决方案**:
- CSV 文件已包含正确的映射（第88-89行）
- 重建了数据对象 `ag_demand_map_vGCAMChina8.0.rda`
- 验证：数据对象现在包含264行，包括所需的映射

**脚本**: `dev_scripts/rebuild_ag_demand_map_v8.R`

### 2. 修复 food_items_map 缺失映射
**问题**: `food_items_map_vGCAMChina8.0` 缺少 `regional biomass` 映射

**解决方案**:
- CSV 文件已包含两个 biomass 映射：
  - `biomass` → `total biomass`
  - `biomass` → `regional biomass`
- 重建了数据对象 `food_items_map_vGCAMChina8.0.rda`
- 验证：数据对象现在包含22行，包括两个 biomass 映射

**脚本**: `dev_scripts/rebuild_food_items_map_v8.R`

### 3. 创建系统性对比脚本
**脚本**: `dev_scripts/compare_all_mappings_v8.R`

**功能**:
- 对比 GCAM 8.2 和 GCAMChina 8.0 的所有映射文件
- 识别缺失的映射行
- 生成详细的差异报告

**发现**:
- 48 个共同文件需要对比
- 18 个 GCAMChina 8.0 特有文件（China 特定映射）
- 1 个 GCAM 8.2 特有文件

---

## ⚠️ 当前问题

### 3. refliq_bioshare 连接错误

**错误信息**:
```
Error in left_join_strict(., refliq_bioshare %>% tidyr::complete(...))
Some rows in the left dataset do not have matching keys in the right dataset.
Missing: 58 rows (scenario, region, year combinations)
```

**分析**:
- 这不是映射缺失问题，而是数据处理逻辑问题
- 涉及的区域：BJ, CQ, GD, GS 等中国省份
- 涉及的年份：2010, 2015, 2021

**可能原因**:
1. V8 的数据结构发生了变化
2. 某些省份或年份的数据在 V8 中不存在
3. `refliq_bioshare` 的计算逻辑需要适配 V8

**下一步**:
- 需要检查 `R/functions.R` 中 `refliq_bioshare` 相关的代码
- 可能需要添加 V8 特定的处理逻辑
- 或者需要使用 `left_join` 而不是 `left_join_strict`

---

## 📊 测试进展

### 测试轮次

1. **初始测试** (`v8_FINAL.log`):
   - ❌ 失败：`ag_demand_map` 缺失映射

2. **第一轮修复后** (`v8_test_after_fix.log`):
   - ✅ `ag_demand_map` 问题已修复
   - ❌ 失败：`food_items_map` 缺失映射

3. **第二轮修复后** (`v8_test_round2.log`):
   - ✅ `ag_demand_map` 问题已修复
   - ✅ `food_items_map` 问题已修复
   - ❌ 失败：`refliq_bioshare` 连接错误

### 警告信息

- `Capital Stock` 变量不可用（需要 National Account 查询）
- `Capital Formation` 变量不可用（需要 National Account 查询）

这些警告可能不影响核心功能，但需要确认 V8 是否支持这些查询。

---

## 📁 创建的文件

### 脚本
1. `dev_scripts/rebuild_ag_demand_map_v8.R` - 重建 ag_demand_map 数据对象
2. `dev_scripts/rebuild_food_items_map_v8.R` - 重建 food_items_map 数据对象
3. `dev_scripts/compare_all_mappings_v8.R` - 系统性对比所有映射

### 数据对象（已更新）
1. `data/ag_demand_map_vGCAMChina8.0.rda` - 264 rows
2. `data/food_items_map_vGCAMChina8.0.rda` - 22 rows

### 日志
1. `output/v8_FINAL.log` - 初始测试
2. `output/v8_test_after_fix.log` - 第一轮修复后
3. `output/v8_test_round2.log` - 第二轮修复后

---

## 🎯 下一步行动

### 立即行动
1. 调查 `refliq_bioshare` 连接错误的根本原因
2. 检查 V8 数据库中是否缺少某些省份/年份的数据
3. 修改代码以适配 V8 的数据结构

### 后续工作
1. 运行系统性对比脚本，生成完整的映射差异报告
2. 处理所有发现的映射差异
3. 完整测试和验证
4. 更新文档

---

## 💡 经验总结

1. **数据对象需要重建**: CSV 文件更新后，必须重建对应的 .rda 文件
2. **逐步修复**: 每次修复一个问题，立即测试，避免积累问题
3. **系统性方法**: 创建对比脚本可以预防性地发现其他问题
4. **V8 特定逻辑**: 可能需要添加 V8 特定的数据处理逻辑

---

**报告生成时间**: 2026-04-28
**预计完成时间**: 需要进一步调查 refliq_bioshare 问题后确定
