# GCAM2GAINS 映射修正建议

**日期**: 2026-04-19
**目的**: 详细对比并提供修正方案

---

## 映射对比总结

### ✅ 已修正（1个文件）

**ag_production_map.csv** - 畜牧业变量
- ✅ Beef: `Agricultural Production|Non-Energy|Livestock|Beef`
- ✅ Dairy: `Agricultural Production|Non-Energy|Livestock|Dairy`
- ✅ Pork: `Agricultural Production|Non-Energy|Livestock|Pork`
- ✅ Poultry: `Agricultural Production|Non-Energy|Livestock|Poultry`
- ✅ SheepGoat: `Agricultural Production|Non-Energy|Livestock|SheepGoat`

---

## ⚠️ 需要修正的映射

### 1. 土地利用变量

**文件**: `land_use_map.csv`

#### 问题 1: Cropland|Otherarable

**GAINS 需要**:
```
Land Cover|Cropland|Otherarable
```

**gcamreport 当前**:
```
OtherArableLand → Land Cover|Cropland|Rainfed
```

**建议修正**:
```csv
# 第36行
OtherArableLand,NA,Land Cover,Land Cover|Cropland,Land Cover|Cropland|Otherarable,,,,,,0.1
```

#### 问题 2: Forest|Managed

**GAINS 需要**:
```
Land Cover|Forest|Managed
```

**gcamreport 当前**:
```
Forest → Land Cover|Forest
```

**建议修正**:
```csv
# 第13行
Forest,NA,Land Cover,Land Cover|Forest,Land Cover|Forest|Managed,,,,,,0.1
```

#### 问题 3: Pasture|Grazed

**GAINS 需要**:
```
Land Cover|Pasture|Grazed
```

**gcamreport 当前**:
```
Pasture → Land Cover|Pasture
```

**建议修正**:
```csv
# 第41行
Pasture,NA,Land Cover,Land Cover|Pasture,Land Cover|Pasture|Grazed,,,,,,0.1
```

#### 问题 4: Cropland|Crops (水稻)

**GAINS 需要**:
```
Land Cover|Cropland|Crops  (用于 RICE_FLOOD, RICE_INTER, RICE_UPLAND)
```

**gcamreport 当前**:
```
Rice → Land Cover|Cropland|Cereals
```

**建议**: 需要添加一个聚合变量 `Land Cover|Cropland|Crops`，或者修改 Rice 的映射

---

### 2. 一次能源和资源开采

需要检查以下文件是否输出正确的变量名：

#### primary_energy_map.csv

**GAINS 需要**:
- `Primary Energy|Coal|Convert`
- `Primary Energy|Gas|Convert`
- `Primary Energy|Oil|Convert`
- `Primary Energy|Biomass|Convert`
- `Primary Energy|Oil|Liquids`

#### res_extraction_map.csv

**GAINS 需要**:
- `Resource|Extraction|Coal`
- `Resource|Extraction|Gas`
- `Resource|Extraction|Oil`

---

### 3. 发电技术

#### elec_gen_map_gcamchina.csv

**GAINS 需要** (需要区分 w/ CCS 和 w/o CCS):
- `Primary Energy|Electricity|Coal|w/ CCS`
- `Primary Energy|Electricity|Coal|w/o CCS`
- `Primary Energy|Electricity|Gas|w/ CCS`
- `Primary Energy|Electricity|Gas|w/o CCS`
- `Primary Energy|Electricity|Oil|w/ CCS`
- `Primary Energy|Electricity|Oil|w/o CCS`
- `Primary Energy|Electricity|Biomass|w/ CCS`
- `Primary Energy|Electricity|Biomass|w/o CCS`
- `Primary Energy|Electricity|Nuclear`
- `Primary Energy|Electricity|Hydro`
- `Primary Energy|Electricity|Wind`
- `Primary Energy|Electricity|Solar`
- `Primary Energy|Electricity|Geothermal`

**关键**: 需要确认 gcamreport 是否区分 CCS 技术

---

### 4. 终端能源 - 建筑

#### final_energy_map_gcamchina.csv

**GAINS 需要**:
- `Final Energy|Residential and Commercial|Electricity`
- `Final Energy|Residential and Commercial|Gases`
- `Final Energy|Residential and Commercial|Heat`
- `Final Energy|Residential and Commercial|Hydrogen`
- `Final Energy|Residential and Commercial|Liquids`
- `Final Energy|Residential and Commercial|Other`
- `Final Energy|Residential and Commercial|Solids|Biomass`
- `Final Energy|Residential and Commercial|Solids|Coal`

**注意**: 变量名是 "Residential and Commercial"，不是 "Buildings"

---

### 5. 终端能源 - 交通

#### transport_final_en_map_gcamchina.csv

**GAINS 需要**:
- `Final Energy|Transportation|Electricity`
- `Final Energy|Transportation|Gases`
- `Final Energy|Transportation|Hydrogen`
- `Final Energy|Transportation|Liquids`

---

### 6. 终端能源 - 工业

#### final_energy_map_gcamchina.csv

**GAINS 需要细分到行业**:

**化工**:
- `Final Energy|Industry|Chemicals|Electricity`
- `Final Energy|Industry|Chemicals|Gases`
- `Final Energy|Industry|Chemicals|Heat`
- `Final Energy|Industry|Chemicals|Hydrogen`
- `Final Energy|Industry|Chemicals|Liquids`
- `Final Energy|Industry|Chemicals|Solids|Coal`

**钢铁**:
- `Final Energy|Industry|Steel|Electricity`
- `Final Energy|Industry|Steel|Gases`
- `Final Energy|Industry|Steel|Liquids`
- `Final Energy|Industry|Steel|Solids|Coal`

**建筑业**:
- `Final Energy|Industry|Off-road|Construction`
- `Final Energy|Industry|Off-road|Construction|Electricity`
- `Final Energy|Industry|Off-road|Construction|Gases`
- `Final Energy|Industry|Off-road|Construction|Hydrogen`
- `Final Energy|Industry|Off-road|Construction|Liquids`

**工业总体**:
- `Final Energy|Industry|Electricity`
- `Final Energy|Industry|Gases`
- `Final Energy|Industry|Heat`
- `Final Energy|Industry|Hydrogen`
- `Final Energy|Industry|Liquids`
- `Final Energy|Industry|Other`
- `Final Energy|Industry|Solids|Biomass`
- `Final Energy|Industry|Solids|Coal`

---

### 7. 非能源使用

**GAINS 需要**:
- `Final Energy|Non-Energy Use|Biomass`
- `Final Energy|Non-Energy Use|Coal`
- `Final Energy|Non-Energy Use|Gas`
- `Final Energy|Non-Energy Use|Oil`

**gcamreport 可能有**: 需要检查是否有 feedstock 相关的映射

---

### 8. 工业产品

#### production_map.csv

**GAINS 需要**:
- `Production|Cement`
- `Production|Chemicals|Fertilizer`
- `Production|Chemicals|Nitrogen Fertilizer`

#### iron_steel_prod_tech_map.csv

**GAINS 需要** (按技术细分):
- `Production|Steel|Blast Furnace`
- `Production|Steel|EAF-scrap`
- `Production|Steel|EAF-DRI`
- `Production|Steel|Hydrogen-DRI`

**Feedstock**:
- `Feedstock|Industry|Steel|Coke`

---

### 9. 其他变量

**GAINS 需要**:
- `Final Energy|Heat` (总体热力)
- `Secondary Energy|Electricity` (二次能源电力)
- `Population` (人口)
- `GDP|MER` (GDP)

---

## 修正优先级

### 高优先级（必须修正）

1. ✅ **畜牧业变量** - 已完成
2. ⏭️ **土地利用变量** - 4个变量需要修正
3. ⏭️ **建筑能源变量** - 确保使用 "Residential and Commercial"
4. ⏭️ **交通能源变量** - 确保使用 "Transportation"

### 中优先级（重要）

5. ⏭️ **工业细分变量** - 化工、钢铁、建筑业
6. ⏭️ **发电技术 CCS 区分** - w/ CCS vs w/o CCS
7. ⏭️ **钢铁技术细分** - 按生产技术分类

### 低优先级（可选）

8. ⏭️ **非能源使用** - 如果 GCAM 有数据
9. ⏭️ **其他变量** - Heat, Population, GDP

---

## 实施步骤

### Step 1: 修正土地利用映射（10分钟）

编辑 `inst/extdata/mappings/GCAMChina7.1/land_use_map.csv`:

```csv
# 第13行 - Forest
Forest,NA,Land Cover,Land Cover|Forest,Land Cover|Forest|Managed,,,,,,0.1

# 第36行 - OtherArableLand
OtherArableLand,NA,Land Cover,Land Cover|Cropland,Land Cover|Cropland|Otherarable,,,,,,0.1

# 第41行 - Pasture
Pasture,NA,Land Cover,Land Cover|Pasture,Land Cover|Pasture|Grazed,,,,,,0.1
```

### Step 2: 检查能源映射（30分钟）

逐个检查以下文件，确认变量名：

```bash
# 1. 一次能源
cat inst/extdata/mappings/GCAMChina7.1/primary_energy_map.csv | grep "Convert\|Liquids"

# 2. 资源开采
cat inst/extdata/mappings/GCAMChina7.1/res_extraction_map.csv

# 3. 发电
cat inst/extdata/mappings/GCAMChina7.1/elec_gen_map_gcamchina.csv | grep "CCS\|Coal\|Gas"

# 4. 终端能源
cat inst/extdata/mappings/GCAMChina7.1/final_energy_map_gcamchina.csv | grep "Residential\|Transportation\|Industry"

# 5. 交通
cat inst/extdata/mappings/GCAMChina7.1/transport_final_en_map_gcamchina.csv
```

### Step 3: 修正不匹配的映射（1-2小时）

根据检查结果，修正每个不匹配的变量名

### Step 4: 测试（30分钟）

```r
# 生成报告
gcamreport::generate_report(
  db_path = "E:/GCAM/GCAM-China_v7.1/output",
  db_name = "China60Ref",
  prj_name = "test_gains",
  scenarios = "China60ref",
  GCAM_version = "vGCAMChina7.1"
)

# 检查输出的变量名
output <- read.csv("test_gains_standardized.csv")
unique(output$Variable)
```

### Step 5: 运行 gcam2gains（10分钟）

```bash
cd /e/GCAM/GCAM_tools/gcam2gains
python run_gcam2gains.py
```

检查是否有错误或缺失变量

---

## 预期结果

修正后，gcamreport 应该能够输出所有 82 个 GAINS 需要的 IAMC 变量，然后 gcam2gains 可以顺利转换为 GAINS 格式。

---

**报告日期**: 2026-04-19
**下一步**: 开始修正土地利用映射
