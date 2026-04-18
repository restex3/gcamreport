# GCAM2GAINS 映射评估报告

**日期**: 2026-04-19
**目的**: 评估 gcamreport 当前映射与 GAINS 需求的匹配度

---

## GAINS 需要的变量（共82个）

根据 `GCAM_GAINS_SEC_ACT_MAP.csv`，GAINS 需要以下 IAMC 变量：

### 1. 农业和土地利用（National 级别）

#### 畜牧业生产（5个变量）
- ✅ `Agricultural Production|Non-Energy|Livestock|Beef` - 已修正
- ✅ `Agricultural Production|Non-Energy|Livestock|Dairy` - 已修正
- ✅ `Agricultural Production|Non-Energy|Livestock|Pork` - 已修正
- ✅ `Agricultural Production|Non-Energy|Livestock|Poultry` - 已修正
- ✅ `Agricultural Production|Non-Energy|Livestock|SheepGoat` - 已修正

**状态**: ✅ 已完成（刚刚修正了 ag_production_map.csv）

#### 土地利用（4个变量）
- ❓ `Land Cover|Cropland|Crops`
- ❓ `Land Cover|Cropland|Otherarable`
- ❓ `Land Cover|Forest|Managed`
- ❓ `Land Cover|Pasture|Grazed`

**状态**: ⚠️ 需要检查 gcamreport 是否有 land_use_map.csv

---

### 2. 一次能源（National 级别）

#### 能源转换（4个变量）
- ❓ `Primary Energy|Coal|Convert`
- ❓ `Primary Energy|Gas|Convert`
- ❓ `Primary Energy|Oil|Convert`
- ❓ `Primary Energy|Biomass|Convert`

#### 炼油（1个变量）
- ❓ `Primary Energy|Oil|Liquids`

#### 资源开采（3个变量）
- ❓ `Resource|Extraction|Coal`
- ❓ `Resource|Extraction|Gas`
- ❓ `Resource|Extraction|Oil`

**状态**: ⚠️ 需要检查 primary_energy_map.csv 和 res_extraction_map.csv

---

### 3. 电力生产（Regional 级别）

#### 发电技术（13个变量）
- ❓ `Primary Energy|Electricity|Coal|w/ CCS`
- ❓ `Primary Energy|Electricity|Coal|w/o CCS`
- ❓ `Primary Energy|Electricity|Gas|w/ CCS`
- ❓ `Primary Energy|Electricity|Gas|w/o CCS`
- ❓ `Primary Energy|Electricity|Oil|w/ CCS`
- ❓ `Primary Energy|Electricity|Oil|w/o CCS`
- ❓ `Primary Energy|Electricity|Biomass|w/ CCS`
- ❓ `Primary Energy|Electricity|Biomass|w/o CCS`
- ❓ `Primary Energy|Electricity|Nuclear`
- ❓ `Primary Energy|Electricity|Hydro`
- ❓ `Primary Energy|Electricity|Wind`
- ❓ `Primary Energy|Electricity|Solar`
- ❓ `Primary Energy|Electricity|Geothermal`

#### 二次能源（1个变量）
- ❓ `Secondary Energy|Electricity`

**状态**: ⚠️ 需要检查 elec_gen_map_gcamchina.csv

---

### 4. 终端能源 - 建筑（Regional 级别）

#### 建筑能源（7个变量）
- ❓ `Final Energy|Residential and Commercial|Electricity`
- ❓ `Final Energy|Residential and Commercial|Gases`
- ❓ `Final Energy|Residential and Commercial|Heat`
- ❓ `Final Energy|Residential and Commercial|Hydrogen`
- ❓ `Final Energy|Residential and Commercial|Liquids`
- ❓ `Final Energy|Residential and Commercial|Other`
- ❓ `Final Energy|Residential and Commercial|Solids|Biomass`
- ❓ `Final Energy|Residential and Commercial|Solids|Coal`

**状态**: ⚠️ 需要检查 final_energy_map_gcamchina.csv

---

### 5. 终端能源 - 交通（Regional 级别）

#### 交通能源（4个变量）
- ❓ `Final Energy|Transportation|Electricity`
- ❓ `Final Energy|Transportation|Gases`
- ❓ `Final Energy|Transportation|Hydrogen`
- ❓ `Final Energy|Transportation|Liquids`

**状态**: ⚠️ 需要检查 transport_final_en_map_gcamchina.csv

---

### 6. 终端能源 - 工业（Regional 级别）

#### 工业总体（8个变量）
- ❓ `Final Energy|Industry|Electricity`
- ❓ `Final Energy|Industry|Gases`
- ❓ `Final Energy|Industry|Heat`
- ❓ `Final Energy|Industry|Hydrogen`
- ❓ `Final Energy|Industry|Liquids`
- ❓ `Final Energy|Industry|Other`
- ❓ `Final Energy|Industry|Solids|Biomass`
- ❓ `Final Energy|Industry|Solids|Coal`

#### 化工行业（6个变量）
- ❓ `Final Energy|Industry|Chemicals|Electricity`
- ❓ `Final Energy|Industry|Chemicals|Gases`
- ❓ `Final Energy|Industry|Chemicals|Heat`
- ❓ `Final Energy|Industry|Chemicals|Hydrogen`
- ❓ `Final Energy|Industry|Chemicals|Liquids`
- ❓ `Final Energy|Industry|Chemicals|Solids|Coal`

#### 钢铁行业（4个变量）
- ❓ `Final Energy|Industry|Steel|Electricity`
- ❓ `Final Energy|Industry|Steel|Gases`
- ❓ `Final Energy|Industry|Steel|Liquids`
- ❓ `Final Energy|Industry|Steel|Solids|Coal`

#### 建筑业（5个变量）
- ❓ `Final Energy|Industry|Off-road|Construction`
- ❓ `Final Energy|Industry|Off-road|Construction|Electricity`
- ❓ `Final Energy|Industry|Off-road|Construction|Gases`
- ❓ `Final Energy|Industry|Off-road|Construction|Hydrogen`
- ❓ `Final Energy|Industry|Off-road|Construction|Liquids`

**状态**: ⚠️ 需要检查 final_energy_map_gcamchina.csv

---

### 7. 非能源使用（Regional 级别）

#### 原料用能（4个变量）
- ❓ `Final Energy|Non-Energy Use|Biomass`
- ❓ `Final Energy|Non-Energy Use|Coal`
- ❓ `Final Energy|Non-Energy Use|Gas`
- ❓ `Final Energy|Non-Energy Use|Oil`

**状态**: ⚠️ 需要检查是否有映射

---

### 8. 工业产品（Regional 级别）

#### 产品产量（7个变量）
- ❓ `Production|Cement`
- ❓ `Production|Steel|Blast Furnace`
- ❓ `Production|Steel|EAF-scrap`
- ❓ `Production|Steel|EAF-DRI`
- ❓ `Production|Steel|Hydrogen-DRI`
- ❓ `Production|Chemicals|Fertilizer`
- ❓ `Production|Chemicals|Nitrogen Fertilizer`

#### 原料（1个变量）
- ❓ `Feedstock|Industry|Steel|Coke`

**状态**: ⚠️ 需要检查 production_map.csv 和 iron_steel_prod_tech_map.csv

---

### 9. 其他（Regional 级别）

#### 热力（1个变量）
- ❓ `Final Energy|Heat`

#### 宏观经济（2个变量）
- ❓ `Population`
- ❓ `GDP|MER`

**状态**: ⚠️ 需要检查是否有映射

---

## 检查清单

### 立即检查的映射文件

1. ✅ **ag_production_map.csv** - 已修正畜牧业变量
2. ⏭️ **land_use_map.csv** - 检查土地利用变量
3. ⏭️ **primary_energy_map.csv** - 检查一次能源变量
4. ⏭️ **res_extraction_map.csv** - 检查资源开采变量
5. ⏭️ **elec_gen_map_gcamchina.csv** - 检查发电变量
6. ⏭️ **final_energy_map_gcamchina.csv** - 检查终端能源变量
7. ⏭️ **transport_final_en_map_gcamchina.csv** - 检查交通能源变量
8. ⏭️ **production_map.csv** - 检查工业产品变量
9. ⏭️ **iron_steel_prod_tech_map.csv** - 检查钢铁技术变量

---

## 关键问题

### 1. 变量命名一致性

**问题**: gcamreport 的 IAMC 变量名可能与 GCAM_GAINS_SEC_ACT_MAP.csv 不完全一致

**示例**:
- gcamreport 可能输出: `Final Energy|Buildings|Electricity`
- GAINS 需要: `Final Energy|Residential and Commercial|Electricity`

**解决方案**: 逐个检查并修正映射文件

### 2. 变量层级深度

**问题**: GAINS 需要特定层级的变量

**示例**:
- GAINS 需要: `Final Energy|Industry|Chemicals|Electricity`（4层）
- gcamreport 可能只有: `Final Energy|Industry|Electricity`（3层）

**解决方案**: 可能需要添加更细分的映射

### 3. CCS 技术区分

**问题**: GAINS 需要区分 w/ CCS 和 w/o CCS

**示例**:
- `Primary Energy|Electricity|Coal|w/ CCS`
- `Primary Energy|Electricity|Coal|w/o CCS`

**解决方案**: 检查 elec_gen_map 是否有这个区分

### 4. 钢铁技术细分

**问题**: GAINS 需要按技术类型细分钢铁产量

**示例**:
- `Production|Steel|Blast Furnace`
- `Production|Steel|EAF-scrap`
- `Production|Steel|EAF-DRI`
- `Production|Steel|Hydrogen-DRI`

**解决方案**: 检查 iron_steel_prod_tech_map.csv

---

## 下一步行动

### Phase 1: 检查现有映射（1-2小时）

逐个检查以下文件，确认是否输出正确的 IAMC 变量名：

```bash
# 1. 土地利用
cat inst/extdata/mappings/GCAMChina7.1/land_use_map.csv

# 2. 一次能源
cat inst/extdata/mappings/GCAMChina7.1/primary_energy_map.csv

# 3. 资源开采
cat inst/extdata/mappings/GCAMChina7.1/res_extraction_map.csv

# 4. 发电
cat inst/extdata/mappings/GCAMChina7.1/elec_gen_map_gcamchina.csv

# 5. 终端能源
cat inst/extdata/mappings/GCAMChina7.1/final_energy_map_gcamchina.csv

# 6. 交通
cat inst/extdata/mappings/GCAMChina7.1/transport_final_en_map_gcamchina.csv

# 7. 工业产品
cat inst/extdata/mappings/GCAMChina7.1/production_map.csv
cat inst/extdata/mappings/GCAMChina7.1/iron_steel_prod_tech_map.csv
```

### Phase 2: 修正不匹配的映射（2-4小时）

对于每个不匹配的变量：
1. 修改对应的 mapping 文件
2. 确保变量名与 GCAM_GAINS_SEC_ACT_MAP.csv 完全一致

### Phase 3: 测试完整流程（1小时）

```r
# 生成 IAMC 报告
gcamreport::generate_report(
  db_path = "E:/GCAM/GCAM-China_v7.1/output",
  db_name = "China60Ref",
  prj_name = "China60Ref_test",
  scenarios = "China60ref",
  GCAM_version = "vGCAMChina7.1"
)
```

```bash
# 转换为 GAINS 格式
cd /e/GCAM/GCAM_tools/gcam2gains
python run_gcam2gains.py
```

### Phase 4: 验证结果（30分钟）

检查：
1. ✅ 是否生成了 31 个省份文件
2. ✅ 变量是否完整（对比 GCAM_GAINS_SEC_ACT_MAP.csv）
3. ✅ 数值是否守恒
4. ✅ 格式是否正确

---

## 预期问题和解决方案

### 问题 1: 缺少某些变量

**症状**: gcam2gains 报错找不到某些 SOURCE_VARIABLE

**原因**: gcamreport 没有生成这些变量

**解决**:
1. 检查 GCAM 数据库是否有对应的查询
2. 添加或修改映射文件
3. 如果 GCAM 确实没有这个数据，需要与 GAINS 团队沟通

### 问题 2: 变量名不匹配

**症状**: gcam2gains 找不到变量，但 gcamreport 输出了类似的变量

**原因**: 变量名不完全一致

**解决**: 修改 gcamreport 的映射文件，使其与 GCAM_GAINS_SEC_ACT_MAP.csv 一致

### 问题 3: 数值不守恒

**症状**: 省份总和 ≠ 国家级数据

**原因**: gcam2gains 的权重文件有问题

**解决**: 重新提取权重（这是 gcam2gains 的问题，不是 gcamreport 的问题）

---

## 总结

### 当前状态

- ✅ 畜牧业变量已修正（5个）
- ❓ 其他 77 个变量需要逐一检查

### 工作量估算

- **检查映射**: 1-2 小时
- **修正映射**: 2-4 小时
- **测试验证**: 1-2 小时
- **总计**: 4-8 小时

### 关键原则

1. **变量名必须完全一致** - 与 GCAM_GAINS_SEC_ACT_MAP.csv 一字不差
2. **层级结构必须匹配** - 不能多也不能少
3. **单位必须正确** - gcamreport 输出的单位要与 GAINS 期望一致

---

**评估日期**: 2026-04-19
**下一步**: 开始逐个检查映射文件
