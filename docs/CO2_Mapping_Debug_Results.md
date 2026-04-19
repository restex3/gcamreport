# CO2 映射问题 - 深入调试结果

**日期**: 2026-04-19
**方法**: 方案3 - 深入调试映射匹配逻辑

---

## 调试结果

### 关键发现

**数据库实际情况**:
- 总共有 **527** 个唯一的技术组合
- 涉及多个部门，包括很多 GCAM-China 特有的细分部门

**映射文件对比**:

| 映射文件 | 行数 | 缺失技术数 | 状态 |
|---------|------|-----------|------|
| gcamreport 原始 | 348 | 313 | ❌ 不完整 |
| gcamreport + CCS | 629 | 仍然很多 | ❌ 不完整 |
| GCAM-China-reporting | 198 | 383 | ❌ 不完整 |

### 主要缺失的部门

1. **住宅供暖（按需求等级）**:
   - `resid heating modern_d1` 到 `d10`
   - 每个等级有 3 个技术（biomass, refined liquids, gas）
   - 共 30 个技术组合

2. **住宅其他用途（按需求等级）**:
   - `resid others coal_d1` 到 `d10`
   - 每个等级有 1 个技术（coal）
   - 共 10 个技术组合

3. **工业过程热**:
   - `process heat food processing`
   - 多种技术和 cogen 变体

4. **其他工业部门**:
   - `ammonia`
   - `H2 central production`
   - `refining`
   - 等等

---

## 根本原因分析

### 问题 1: GCAM-China 的特殊结构

GCAM-China 有很多标准 GCAM 没有的细分：
- 按需求等级（d1-d10）细分的住宅部门
- 更详细的工业子部门
- 中国特有的技术

### 问题 2: 映射文件不匹配

**gcamreport 的映射**:
- 设计用于标准 GCAM
- 不包含 GCAM-China 的特殊部门

**GCAM-China-reporting 的映射**:
- 设计用于 GCAM-China
- 但可能使用不同的查询或聚合逻辑
- 不需要映射所有细分技术

---

## 为什么 GCAM-China-reporting 能工作？

### 可能的原因

1. **使用不同的查询**:
   - 可能使用聚合后的查询
   - 不需要技术级别的详细映射

2. **使用不同的处理逻辑**:
   - 可能有默认的映射规则
   - 对于未映射的技术使用通用规则

3. **不报告所有技术**:
   - 可能只报告主要技术
   - 忽略细分的需求等级

---

## 解决方案

### 方案 A: 自动生成缺失的映射（推荐）

**原理**: 为缺失的技术自动生成映射规则

**实施**:
```r
# 1. 读取现有映射
existing_mapping <- read.csv("CO2_tech_map.csv")

# 2. 获取缺失的技术
missing_techs <- anti_join(actual_techs, existing_mapping)

# 3. 为缺失的技术生成映射
# 规则：使用通用的 Emissions|CO2 映射
auto_mapping <- missing_techs %>%
  mutate(
    var1 = "Emissions|CO2",
    var2 = "",
    var3 = "",
    var4 = "",
    var5 = "",
    var6 = "",
    var7 = "",
    var8 = "",
    var9 = "",
    unit_conv = 3.666667
  )

# 4. 合并
complete_mapping <- rbind(existing_mapping, auto_mapping)

# 5. 保存
write.csv(complete_mapping, "CO2_tech_map_complete.csv", row.names=FALSE)
```

**优点**:
- ✅ 完整覆盖所有技术
- ✅ 自动化，易于维护
- ✅ 可以后续手动优化

**缺点**:
- ⚠️ 自动生成的映射可能不够精确
- ⚠️ 需要验证结果

---

### 方案 B: 使用 GCAM-China-reporting 的方法

**原理**: 研究 GCAM-China-reporting 如何处理 CO2 数据

**实施**:
```r
# 查看 GCAM-China-reporting 的代码
source("/e/GCAM/GCAM_tools/GCAM-China-reporting/Reporting.R")

# 找到 CO2 处理的部分
# 可能使用了不同的查询或聚合方法
```

**优点**:
- ✅ 已验证可用
- ✅ 专门为 GCAM-China 设计

**缺点**:
- ⚠️ 需要理解其代码逻辑
- ⚠️ 可能需要修改 gcamreport

---

### 方案 C: 简化映射策略

**原理**: 不映射所有细分技术，使用聚合查询

**实施**:
1. 使用 `CO2 emissions by sector` 而不是 `by tech`
2. 只映射主要部门，不映射细分技术
3. 在后处理中进行必要的分配

**优点**:
- ✅ 简单
- ✅ 映射文件小

**缺点**:
- ⚠️ 损失技术级别的细节
- ⚠️ 可能不符合 IAMC 要求

---

## 推荐实施

### 立即行动：方案 A

**步骤 1**: 自动生成完整映射
```bash
cd /e/GCAM/GCAM_tools/gcamreport
Rscript generate_complete_co2_mapping.R
```

**步骤 2**: 测试
```bash
Rscript test_complete_mapping.R
```

**步骤 3**: 如果成功，提交
```bash
git add inst/extdata/mappings/GCAMChina7.1/CO2_tech_map.csv
git commit -m "Complete CO2 tech mapping for GCAM-China"
```

---

## 创建自动生成脚本

```r
# generate_complete_co2_mapping.R
library(dplyr)
library(rgcam)

# 1. 加载数据
prj <- rgcam::loadProject('E:/GCAM/GCAM-China_v7.1/output/China60Ref_China60Ref_final.dat')
co2_data <- rgcam::getQuery(prj, 'CO2 emissions by tech (excluding resource production)', 'China60ref')

actual_techs <- co2_data %>%
  select(sector, subsector, technology) %>%
  distinct()

# 2. 读取现有映射
existing_mapping <- read.csv(
  'inst/extdata/mappings/GCAMChina7.1/CO2_tech_map.csv',
  comment.char='#',
  stringsAsFactors=FALSE
)

existing_techs <- existing_mapping %>%
  select(sector, subsector, technology)

# 3. 找出缺失的
missing_techs <- anti_join(actual_techs, existing_techs,
                           by = c('sector', 'subsector', 'technology'))

cat('Missing technologies:', nrow(missing_techs), '\n')

# 4. 生成映射规则
# 根据部门类型使用不同的映射
auto_mapping <- missing_techs %>%
  mutate(
    var1 = case_when(
      grepl('resid', sector) ~ 'Emissions|CO2',
      grepl('comm', sector) ~ 'Emissions|CO2',
      grepl('industry', sector) ~ 'Emissions|CO2',
      TRUE ~ 'Emissions|CO2'
    ),
    var2 = '',
    var3 = '',
    var4 = '',
    var5 = '',
    var6 = '',
    var7 = '',
    var8 = '',
    var9 = '',
    unit_conv = 3.666667
  )

# 5. 合并
complete_mapping <- rbind(existing_mapping, auto_mapping)

# 6. 保存
header <- '# CO2 emission by tech mapping'
write(header, 'inst/extdata/mappings/GCAMChina7.1/CO2_tech_map.csv')
write.table(complete_mapping,
            'inst/extdata/mappings/GCAMChina7.1/CO2_tech_map.csv',
            sep = ',', row.names = FALSE, quote = FALSE, append = TRUE)

cat('Complete mapping saved\n')
cat('Total mappings:', nrow(complete_mapping), '\n')
```

---

## 总结

### 核心问题
- GCAM-China 有 527 个技术组合
- 现有映射只覆盖 348 个
- 缺失 313 个（主要是细分的住宅和工业部门）

### 推荐方案
- ✅ 使用方案 A：自动生成缺失的映射
- ✅ 为所有缺失技术使用通用的 `Emissions|CO2` 映射
- ✅ 后续可以手动优化重要技术的映射

### 不影响 GAINS
- ✅ GAINS 映射修正（畜牧业和土地利用）已完成
- ✅ CO2 映射问题是独立的
- ✅ 两者可以分别处理

---

**调试完成日期**: 2026-04-19
**下一步**: 实施方案 A
