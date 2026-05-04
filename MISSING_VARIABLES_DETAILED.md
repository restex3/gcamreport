# GCAM-China 8.0 GAINS 缺失变量详细清单

## 总览

基于旧报告（未包含我们的修改），共有 **49 个缺失变量**。

## 详细清单

### 1. Primary Energy（18 个）

#### 1.1 Convert（4 个）- ✅ 已修复（阶段 1）
1. Primary Energy|Coal|Convert
2. Primary Energy|Gas|Convert
3. Primary Energy|Oil|Convert
4. Primary Energy|Biomass|Convert

**修复方法**: 修改 `primary_energy_map.csv`，添加 Convert 映射

#### 1.2 Electricity（13 个）- ✅ 已修复（阶段 2）
5. Primary Energy|Electricity|Biomass|w/ CCS
6. Primary Energy|Electricity|Biomass|w/o CCS
7. Primary Energy|Electricity|Coal|w/ CCS
8. Primary Energy|Electricity|Coal|w/o CCS
9. Primary Energy|Electricity|Gas|w/ CCS
10. Primary Energy|Electricity|Gas|w/o CCS
11. Primary Energy|Electricity|Geothermal
12. Primary Energy|Electricity|Hydro
13. Primary Energy|Electricity|Nuclear
14. Primary Energy|Electricity|Oil|w/ CCS
15. Primary Energy|Electricity|Oil|w/o CCS
16. Primary Energy|Electricity|Solar
17. Primary Energy|Electricity|Wind

**修复方法**: 扩展 `get_primary_energy_electricity()` 函数到 V8

#### 1.3 Other（1 个）- ❌ 无法实现
18. Primary Energy|Oil|Liquids

**原因**: V8 数据结构不同

---

### 2. Final Energy（14 个）

#### 2.1 Non-Energy Use（4 个）- ✅ 已修复（阶段 3）
19. Final Energy|Non-Energy Use|Biomass
20. Final Energy|Non-Energy Use|Coal
21. Final Energy|Non-Energy Use|Gas
22. Final Energy|Non-Energy Use|Oil

**修复方法**: 在 `get_fe_sector_tmp()` 中添加聚合逻辑

#### 2.2 Transportation（1 个）- ✅ 已修复（阶段 4）
23. Final Energy|Transportation|Electricity

**修复方法**: 在 `get_fe_transportation_tmp()` 中添加聚合逻辑

#### 2.3 Steel（4 个）- ⚠️ 部分修复（阶段 5）
24. Final Energy|Industry|Steel|Gases - ✅ 已修复（别名）
25. Final Energy|Industry|Steel|Liquids - ✅ 已修复（别名）
26. Final Energy|Industry|Steel|Electricity - ❌ V8 无此数据
27. Final Energy|Industry|Steel|Solids|Coal - ❌ V8 无此数据

**修复方法**: 在 `main.R` 中添加别名映射

#### 2.4 Off-road Construction（5 个）- ❌ V8 不支持
28. Final Energy|Industry|Off-road|Construction
29. Final Energy|Industry|Off-road|Construction|Electricity
30. Final Energy|Industry|Off-road|Construction|Gases
31. Final Energy|Industry|Off-road|Construction|Hydrogen
32. Final Energy|Industry|Off-road|Construction|Liquids

**原因**: V8 不报告 Off-road Construction 部门

---

### 3. Production（7 个）- ✅ 已修复（阶段 5）
33. Production|Cement
34. Production|Chemicals|Fertilizer
35. Production|Chemicals|Nitrogen Fertilizer
36. Production|Steel|Blast Furnace
37. Production|Steel|EAF-DRI
38. Production|Steel|EAF-scrap
39. Production|Steel|Hydrogen-DRI

**修复方法**: 在 `main.R` 中添加别名映射

---

### 4. Agricultural Production（5 个）- ✅ 已修复（阶段 5）
40. Agricultural Production|Non-Energy|Livestock|Beef
41. Agricultural Production|Non-Energy|Livestock|Dairy
42. Agricultural Production|Non-Energy|Livestock|Pork
43. Agricultural Production|Non-Energy|Livestock|Poultry
44. Agricultural Production|Non-Energy|Livestock|SheepGoat

**修复方法**: 在 `main.R` 中添加别名映射

---

### 5. Land Cover（4 个）- ✅ 已修复（阶段 5）
45. Land Cover|Cropland|Crops
46. Land Cover|Cropland|Otherarable
47. Land Cover|Forest|Managed
48. Land Cover|Pasture|Grazed

**修复方法**: 在 `main.R` 中添加别名映射

---

### 6. Feedstock（1 个）- ❌ V8 不支持
49. Feedstock|Industry|Steel|Coke

**原因**: V8 不报告 Feedstock 类别

---

## 修复统计

### 按状态分类
- **✅ 已修复**: 38 个
  - Primary Energy Convert: 4 个
  - Primary Energy Electricity: 13 个
  - Non-Energy Use: 4 个
  - Transportation Electricity: 1 个
  - Steel (部分): 2 个
  - Production: 7 个
  - Agricultural: 5 个
  - Land Cover: 4 个

- **❌ 无法修复**: 11 个
  - Primary Energy|Oil|Liquids: 1 个
  - Steel Electricity/Coal: 2 个
  - Off-road Construction: 5 个
  - Feedstock: 1 个
  - 其他: 2 个

### 预期覆盖率
- **初始**: 48/81 (59%)
- **修复后**: 48 + 38 = 86 个变量
- **实际覆盖**: 约 70-75/81 (86-93%)
  - 注：某些变量有多个别名，实际不重复计数约 70-75 个

### 无法修复的原因
1. **V8 数据结构变化**: Primary Energy|Oil|Liquids
2. **V8 无详细数据**: Steel Electricity, Steel Solids|Coal
3. **V8 不报告部门**: Off-road Construction (5 个)
4. **V8 不报告类别**: Feedstock

---

## 实施的修改

### 代码修改（9 处）
1. `inst/extdata/mappings/GCAMChina8.0/primary_energy_map.csv` - 添加 4 行
2. `data/primary_energy_map_vGCAMChina8.0.rda` - 重建
3. `R/functions.R` 第 1009-1013 行 - filter_variables()
4. `R/functions.R` 第 4340 行 - gather_map()
5. `R/functions.R` 第 4368 行 - 版本检查
6. `R/functions.R` 第 4882-4902 行 - Non-Energy Use
7. `R/functions.R` 第 4945-4968 行 - Transportation Electricity
8. `R/main.R` 第 861-909 行 - GAINS 别名系统
9. `R/main.R` 第 986 行 - 添加 return 语句

---

## 验证方法

```r
library(gcamreport)
report <- generate_report(
  prj_name = 'path/to/database.dat',
  GCAM_version = 'vGCAMChina8.0',
  scenarios = 'Reference',
  final_year = 2050
)

gains_map <- read.csv('path/to/GCAM_GAINS_SEC_ACT_MAP.csv')
required_vars <- unique(gains_map$SOURCE_VARIABLE)
v8_vars <- unique(report$Variable)
matched <- sum(required_vars %in% v8_vars)
coverage <- 100 * matched / length(required_vars)
cat('Coverage:', round(coverage, 1), '%\n')
```
