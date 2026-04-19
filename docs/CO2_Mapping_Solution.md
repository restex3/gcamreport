# CO2 映射问题分析和解决方案

**日期**: 2026-04-19
**问题**: gcamreport 报错缺少 CO2 技术映射

---

## 问题分析

### 错误信息
```
Error: Some rows in the left dataset do not have matching keys in the right dataset.
Missing mappings for 95 technologies including:
- electricity, biomass, biomass (conv CCS)
- electricity, biomass, biomass (conv)
- electricity, coal, coal (conv pul CCS)
...
```

### 已尝试的解决方案
1. ✅ 手动添加 6 个发电 CCS 技术 - 失败
2. ✅ 自动生成所有 CCS 技术（281个）- 失败
3. ⚠️ 问题依然存在

### 根本原因分析

**可能的原因**：
1. **格式差异**: gcamreport 和 GCAM-China-reporting 使用不同的映射格式
   - gcamreport: 13 列（var1-var9）
   - GCAM-China-reporting: 6 列（var1-var2）

2. **版本不兼容**: gcamreport 可能期望不同的技术名称格式

3. **映射逻辑问题**: 可能不是简单的缺失映射，而是映射匹配逻辑的问题

---

## 对比分析

### GCAM-China-reporting 的 CO2 映射

**文件**: `/e/GCAM/GCAM_tools/GCAM-China-reporting/mappings/CO2_tech_map.csv`

**特点**:
- ✅ 只有 199 行（简洁）
- ✅ 6 列格式
- ✅ 很多技术的 var1/var2 为空
- ✅ 已经包含所有 CCS 技术

**示例**:
```csv
sector,subsector,technology,var1,var2,unit_conv
electricity,biomass,biomass (conv CCS),,,3.666667
electricity,biomass,biomass (conv),,,3.666667
electricity,coal,coal (conv pul CCS),Emissions|CO2|Energy|Coal,,3.666667
electricity,coal,coal (conv pul),Emissions|CO2|Energy|Coal,,3.666667
```

### gcamreport 的 CO2 映射

**文件**: `inst/extdata/mappings/GCAMChina7.1/CO2_tech_map.csv`

**特点**:
- ⚠️ 629 行（复杂）
- ⚠️ 13 列格式
- ⚠️ 详细的 IAMC 变量层级
- ⚠️ 测试失败

**示例**:
```csv
sector,subsector,technology,var1,var2,var3,var4,var5,var6,var7,var8,var9,unit_conv
electricity,biomass,biomass (conv),Emissions|CO2,Emissions|CO2|Energy and Industrial Processes,Emissions|CO2|Energy,Emissions|CO2|Energy|Supply,Emissions|CO2|Energy|Supply|Electricity,,,,,3.666667
```

---

## 解决方案

### 方案 1: 使用 GCAM-China-reporting 的映射（推荐）

**步骤**:
```bash
# 1. 备份当前映射
cp inst/extdata/mappings/GCAMChina7.1/CO2_tech_map.csv \
   inst/extdata/mappings/GCAMChina7.1/CO2_tech_map.csv.gcamreport_original

# 2. 复制 GCAM-China-reporting 的映射
cp /e/GCAM/GCAM_tools/GCAM-China-reporting/mappings/CO2_tech_map.csv \
   inst/extdata/mappings/GCAMChina7.1/CO2_tech_map.csv

# 3. 测试
Rscript -e "gcamreport::generate_report(...)"
```

**优点**:
- ✅ 已经在 GCAM-China-reporting 中验证可用
- ✅ 格式简单，易于维护
- ✅ 包含所有必要的技术

**缺点**:
- ⚠️ 可能需要调整列数（6列 vs 13列）
- ⚠️ IAMC 变量层级较少

---

### 方案 2: 调整列格式

如果 gcamreport 要求 13 列格式，需要转换：

**转换脚本**:
```r
# 读取 GCAM-China-reporting 的映射
china_reporting <- read.csv(
  "/e/GCAM/GCAM_tools/GCAM-China-reporting/mappings/CO2_tech_map.csv",
  skip = 1  # 跳过第一行注释
)

# 转换为 13 列格式
gcamreport_format <- china_reporting %>%
  mutate(
    var3 = "",
    var4 = "",
    var5 = "",
    var6 = "",
    var7 = "",
    var8 = "",
    var9 = ""
  ) %>%
  select(sector, subsector, technology,
         var1, var2, var3, var4, var5, var6, var7, var8, var9,
         unit_conv)

# 保存
write.csv(gcamreport_format,
          "inst/extdata/mappings/GCAMChina7.1/CO2_tech_map.csv",
          row.names = FALSE)
```

---

### 方案 3: 调试映射匹配逻辑

**深入调试**:
```r
# 1. 查看实际的 CO2 数据
library(rgcam)
prj <- rgcam::loadProject("path/to/project.dat")
co2_data <- rgcam::getQuery(prj, "CO2 emissions by tech", "scenario")

# 2. 检查实际的技术名称
unique_techs <- co2_data %>%
  filter(sector == "electricity") %>%
  select(sector, subsector, technology) %>%
  distinct()

print(unique_techs)

# 3. 对比映射文件
mapping <- read.csv("CO2_tech_map.csv")
mapping_techs <- mapping %>%
  filter(sector == "electricity") %>%
  select(sector, subsector, technology)

# 4. 找出缺失的
missing <- anti_join(unique_techs, mapping_techs)
print(missing)
```

---

## 推荐实施步骤

### Step 1: 尝试方案 1（最快）

```bash
# 直接使用 GCAM-China-reporting 的映射
cp /e/GCAM/GCAM_tools/GCAM-China-reporting/mappings/CO2_tech_map.csv \
   inst/extdata/mappings/GCAMChina7.1/CO2_tech_map_china_reporting.csv

# 测试
Rscript test_co2_mapping.R
```

### Step 2: 如果格式不兼容，使用方案 2

```r
# 运行转换脚本
source("convert_co2_mapping.R")
```

### Step 3: 如果还是失败，使用方案 3

```r
# 深入调试
source("debug_co2_mapping.R")
```

---

## 关键发现

### GCAM-China-reporting 的优势

1. **简洁**: 只有 199 行 vs 629 行
2. **已验证**: 在实际项目中使用
3. **完整**: 包含所有必要的技术
4. **维护性**: 更容易理解和维护

### 建议

**立即行动**:
1. ⏭️ 尝试使用 GCAM-China-reporting 的 CO2 映射
2. ⏭️ 如果格式不兼容，进行转换
3. ⏭️ 测试验证

**长期**:
1. ⏭️ 统一 gcamreport 和 GCAM-China-reporting 的映射格式
2. ⏭️ 创建映射验证工具
3. ⏭️ 文档化映射规则

---

## 注意事项

### 不影响 GAINS 映射

**重要**: CO2 映射问题与 GAINS 映射修正是独立的：
- ✅ GAINS 映射修正已完成（畜牧业和土地利用）
- ✅ 这些修正不受 CO2 映射问题影响
- ✅ 下次成功生成 IAMC 报告时会使用正确的 GAINS 变量名

### 测试策略

**分步测试**:
1. 先测试 CO2 映射是否解决
2. 再测试完整的 IAMC 生成
3. 最后测试 GAINS 变量是否正确

---

## 参考文件

- GCAM-China-reporting CO2 映射: `/e/GCAM/GCAM_tools/GCAM-China-reporting/mappings/CO2_tech_map.csv`
- gcamreport CO2 映射: `inst/extdata/mappings/GCAMChina7.1/CO2_tech_map.csv`
- 备份文件: `CO2_tech_map.csv.backup`

---

**创建日期**: 2026-04-19
**状态**: 待实施
**优先级**: 中（不影响 GAINS 映射）
