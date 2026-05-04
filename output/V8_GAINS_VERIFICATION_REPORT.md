# GCAM-China V8 GAINS 覆盖率验证报告

**日期**: 2026-05-04  
**验证人**: Alma  
**目的**: 验证 gcamreport 对 GCAM_GAINS_SEC_ACT_MAP_V8.csv 的覆盖情况

---

## 📋 验证方法

采用两个方向验证：

### 1. 代码层面验证
检查 gcamreport 的映射文件和 template 是否包含所有 GAINS 需要的变量。

### 2. 实际输出验证
检查实际运行 `generate_report()` 生成的输出文件是否包含所有 GAINS 变量。

---

## 📊 GAINS 需求分析

### 需求文件
- **文件路径**: `E:/GCAM/GCAM_tools/gcam2gains/GCAM_GAINS_SEC_ACT_MAP_V8.csv`
- **总变量数**: 48 个唯一变量
- **分类**:
  - National 变量: 10 个
  - Regional 变量: 38 个

### 需求变量列表

#### National 变量 (10个)
1. Land Cover|Cropland
2. Agricultural Production|Livestock|Ruminant|Meat
3. Agricultural Production|Livestock|Ruminant|Dairy
4. Agricultural Production|Livestock|Non-Ruminant|Meat|Pig
5. Agricultural Production|Livestock|Non-Ruminant|Meat|Poultry
6. Land Cover|Forest
7. Land Cover|Pasture
8. Resource|Extraction|Coal
9. Resource|Extraction|Oil
10. Resource|Extraction|Gas

#### Regional 变量 (38个)
包括：
- Population
- Final Energy|Residential and Commercial (多个子类)
- Final Energy|Industry (多个子类)
- Final Energy|Transportation (多个子类)
- Final Energy|Non-Energy Use (多个子类)
- Production (Chemicals, Steel, Cement)
- Secondary Energy|Electricity
- GDP|MER
- 等等...

---

## 🔍 实际输出验证结果

### 测试文件
- **文件路径**: `E:/GCAM/GCAM-China_v8/output/database_basexdb_v8_test_standardized.csv`
- **文件大小**: 47.9 MB
- **生成时间**: 2026-05-02 04:31:27
- **总行数**: 393,024 行

### 初步验证结果

⚠️ **发现问题**: 使用 `data.table::fread()` 读取时遇到列名识别问题

**症状**:
```
Warning: Column name 'Variable' not found (case-sensitive)
Total unique variables: 0
```

**可能原因**:
1. CSV 文件编码问题
2. 列名大小写不匹配
3. 文件格式问题

**解决方案**: 改用 base R 的 `read.csv()` 重新验证（正在运行中）

---

## 📝 下一步行动

### 正在进行
- ✅ 使用 base R 重新读取输出文件
- ⏳ 等待完整的变量列表
- ⏳ 计算实际覆盖率

### 待完成
1. 确认实际输出中的变量列表
2. 与 GAINS 需求进行精确匹配
3. 识别缺失的变量
4. 分析缺失原因（代码层面 vs 数据层面）
5. 提供补充方案

---

## 🎯 预期结果

根据之前的文档记录：
- V7.1 版本: 97.5% 覆盖率 (79/81)
- V8 版本: 81% 覆盖率 (66/81)

**注意**: V8 的 GAINS 映射文件只有 48 个变量（vs V7.1 的 81 个），说明 V8 版本的 GAINS 需求已经简化。

---

## 📂 生成的文件

1. `dev_scripts/check_gains_final.R` - 主验证脚本
2. `dev_scripts/check_with_base_r.R` - Base R 验证脚本（运行中）
3. `output/v8_gains_coverage_summary.txt` - 覆盖率总结
4. `output/v8_gains_coverage_detail.csv` - 详细对比表

---

## 🔧 技术细节

### 使用的工具
- R 语言
- data.table 包（快速读取）
- base R（备用方案）

### 验证脚本位置
- `E:/GCAM/GCAM_tools/gcamreport/dev_scripts/`

### 输出报告位置
- `E:/GCAM/GCAM_tools/gcamreport/output/`

---

**状态**: 验证进行中...  
**预计完成时间**: 2-3 分钟（取决于文件读取速度）
