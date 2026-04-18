# GCAM2GAINS 工作流程 - 正确理解

**日期**: 2026-04-19
**状态**: 理解正确的工作流程

---

## 完整的工作流程

```
GCAM 数据库
    ↓
gcamreport::generate_report()  ← 生成 IAMC 格式标准化报告
    ↓
IAMC CSV 文件 (gcam_china_iamc_full.csv)
    ↓
gcam2gains/run_gcam2gains.py  ← 使用 GCAM_GAINS_SEC_ACT_MAP.csv 映射
    ↓
GAINS 输入文件 (31个省份的 CSV 文件)
```

---

## 两个项目的分工

### 1. gcamreport (R 包)

**位置**: `E:/GCAM/GCAM_tools/gcamreport`

**功能**:
- 从 GCAM 数据库提取数据
- 转换为 IAMC 标准格式
- 输出 CSV 文件

**关键函数**:
- `generate_report()` - 主函数，生成完整的 IAMC 报告

**映射文件位置**: `inst/extdata/mappings/GCAMChina7.1/`
- `ag_production_map.csv` - 农业生产映射
- `final_energy_map_gcamchina.csv` - 终端能源映射
- `primary_energy_map.csv` - 一次能源映射
- 等等...

**输出格式** (IAMC):
```csv
Model,Scenario,Region,Variable,Unit,2020,2025,2030,...
GCAM-China,China60ref,China,Primary Energy|Coal|Convert,EJ/yr,83.576,85.2,87.1,...
GCAM-China,China60ref,AH,Final Energy|Residential and Commercial|Electricity,EJ/yr,0.5,0.6,0.7,...
```

---

### 2. gcam2gains (Python 工具)

**位置**: `E:/GCAM/GCAM_tools/gcam2gains`

**功能**:
- 读取 IAMC 格式的 CSV 文件
- 使用 `GCAM_GAINS_SEC_ACT_MAP.csv` 进行映射
- 进行两层权重拆分：
  1. ACT_ABB 权重分配（活动类型）
  2. 省份权重分配（31个省）
- 输出 GAINS 格式的文件

**关键文件**:
- `GCAM_GAINS_SEC_ACT_MAP.csv` - **最重要的映射文件**
- `run_gcam2gains.py` - 主运行脚本
- `src/mapper.py` - GCAM → GAINS 映射
- `src/splitter.py` - 省份拆分

**输出格式** (GAINS):
```csv
YEAR,ACT_ABB,SEC_ABB,VALUE,SOURCE_VARIABLE,SOURCE_UNIT,GAINS_UNIT
2020,HC3,CON_LOSS,4.83,Primary Energy|Coal|Convert,EJ/yr,PJ
2020,BC1,DOM_COM,0.25,Final Energy|Residential and Commercial|Solids|Coal,EJ/yr,PJ
```

每个省份一个文件：`CHIN_ANHU.csv`, `CHIN_BEIJ.csv`, ...

---

## GCAM_GAINS_SEC_ACT_MAP.csv 的结构

这是**最核心的映射文件**，定义了：

```csv
DATASOURCE_NAME,MODEL_NAME,REGIONAL,SOURCE_VARIABLE_DET,SOURCE_VARIABLE,SOURCE_UNIT,ACT_ABB,SEC_ABB,GAINS_UNIT
```

**关键列**:
- `REGIONAL`: "National" 或 "Regional"
  - "National" = 国家级数据（农业、土地利用）
  - "Regional" = 省级数据（能源、建筑、交通、工业）
- `SOURCE_VARIABLE`: IAMC 变量名（必须与 gcamreport 输出一致）
- `ACT_ABB`: GAINS 活动缩写
- `SEC_ABB`: GAINS 部门缩写

**示例**:
```csv
"Tsinghua","GCAM_China","National","Agricultural Production|Livestock|Ruminant","Agricultural Production|Non-Energy|Livestock|Beef","Mt","OL","AGR_BEEF","M animals"
"Tsinghua","GCAM_China","Regional","Final Energy|Residential and Commercial|Electricity","Final Energy|Residential and Commercial|Electricity","EJ/yr","ELE","DOM_COM","PJ"
```

---

## 我之前的误解

### ❌ 错误的理解

我以为需要：
1. 在 gcamreport 中直接实现 GCAM → GAINS 的转换
2. 创建新的映射文件（buildings_services.csv, transport_modes.csv 等）
3. 实现省份分配算法
4. 直接输出 GAINS 格式

### ✅ 正确的理解

实际上应该：
1. gcamreport 只负责生成 **IAMC 格式**
2. 使用现有的 **gcam2gains** 工具进行转换
3. 关键是确保 gcamreport 输出的 IAMC 变量名与 `GCAM_GAINS_SEC_ACT_MAP.csv` 一致

---

## 发现的问题

### 问题：农业变量名不一致

**gcamreport 当前输出**:
```
Agricultural Production|Livestock|Ruminant|Meat  (Beef)
Agricultural Production|Livestock|Non-Ruminant|Meat|Pig  (Pork)
```

**GCAM_GAINS_SEC_ACT_MAP.csv 需要**:
```
Agricultural Production|Non-Energy|Livestock|Beef
Agricultural Production|Non-Energy|Livestock|Pork
```

### 解决方案

✅ 已更新 `inst/extdata/mappings/GCAMChina7.1/ag_production_map.csv`

**修改前**:
```csv
Beef,Agricultural Production,Agricultural Production|Livestock,Agricultural Production|Livestock|Ruminant,Agricultural Production|Livestock|Ruminant|Meat,,1
```

**修改后**:
```csv
Beef,Agricultural Production,Agricultural Production|Non-Energy,Agricultural Production|Non-Energy|Livestock,Agricultural Production|Non-Energy|Livestock|Beef,,1
```

---

## 完整的使用流程

### Step 1: 使用 gcamreport 生成 IAMC 报告

```r
library(gcamreport)

# 生成完整的 IAMC 报告
generate_report(
  db_path = "E:/GCAM/GCAM-China_v7.1/output",
  db_name = "China60Ref",
  prj_name = "China60Ref_gcamreport",
  scenarios = "China60ref",
  GCAM_version = "vGCAMChina7.1",
  desired_regions = "All",  # 包括 China 和 31 个省
  save_output = TRUE,
  output_file = "gcam_china_iamc_full"
)
```

**输出**: `gcam_china_iamc_full.csv` (IAMC 格式)

### Step 2: 使用 gcam2gains 转换为 GAINS 格式

```bash
cd E:/GCAM/GCAM_tools/gcam2gains

# 将 IAMC 文件放到 data/input/
cp path/to/gcam_china_iamc_full.csv data/input/

# 运行转换
python run_gcam2gains.py
```

**输出**: `data/output/gains_input/` 目录下的 31 个省份文件
- `CHIN_ANHU.csv` (安徽)
- `CHIN_BEIJ.csv` (北京)
- `CHIN_SICH.csv` (四川)
- ... (共 31 个文件)

---

## 数据流示例

### 农业数据（National 级别）

**GCAM 查询**:
```
Query: "ag production by crop type"
Region: China
Sector: Beef
Value: 6.73 Mt
```

**gcamreport 输出** (IAMC):
```csv
Model,Scenario,Region,Variable,Unit,2020
GCAM-China,China60ref,China,Agricultural Production|Non-Energy|Livestock|Beef,Mt,6.73
```

**gcam2gains 处理**:
1. 识别为 "National" 级别（根据 GCAM_GAINS_SEC_ACT_MAP.csv）
2. 映射到多个 ACT_ABB: OL, OS (不同的牛类型)
3. 使用省份权重分配到 31 个省
4. 输出到各省份文件

**GAINS 输出** (CHIN_SHND.csv - 山东):
```csv
YEAR,ACT_ABB,SEC_ABB,VALUE,SOURCE_VARIABLE,GAINS_UNIT
2020,OL,AGR_BEEF,0.43,Agricultural Production|Non-Energy|Livestock|Beef,M animals
```

### 能源数据（Regional 级别）

**GCAM 查询**:
```
Query: "building total final energy by service"
Region: AH (安徽)
Sector: comm cooling
Value: 0.5 EJ
```

**gcamreport 输出** (IAMC):
```csv
Model,Scenario,Region,Variable,Unit,2020
GCAM-China,China60ref,AH,Final Energy|Residential and Commercial|Electricity,EJ/yr,0.5
```

**gcam2gains 处理**:
1. 识别为 "Regional" 级别
2. 映射到 ACT_ABB: ELE, SEC_ABB: DOM_COM
3. 直接输出到安徽省文件（无需分配）

**GAINS 输出** (CHIN_ANHU.csv - 安徽):
```csv
YEAR,ACT_ABB,SEC_ABB,VALUE,SOURCE_VARIABLE,GAINS_UNIT
2020,ELE,DOM_COM,500,Final Energy|Residential and Commercial|Electricity,PJ
```

---

## 下一步工作

### 1. 验证 gcamreport 输出

运行 `generate_report()` 并检查：
- ✅ 是否包含所有需要的 IAMC 变量
- ✅ 变量名是否与 GCAM_GAINS_SEC_ACT_MAP.csv 一致
- ✅ 是否包含 China（国家级）和 31 个省（省级）的数据

### 2. 测试 gcam2gains 转换

```bash
python run_gcam2gains.py
```

检查：
- ✅ 是否成功生成 31 个省份文件
- ✅ 数值是否守恒（省份总和 = 国家级）
- ✅ 格式是否符合 GAINS 要求

### 3. 如有问题，调整映射

如果发现变量名不匹配：
- 更新 gcamreport 的映射文件
- 或更新 GCAM_GAINS_SEC_ACT_MAP.csv

---

## 总结

### 关键认识

1. **gcamreport 和 gcam2gains 是两个独立的工具**
   - gcamreport: GCAM → IAMC
   - gcam2gains: IAMC → GAINS

2. **GCAM_GAINS_SEC_ACT_MAP.csv 是核心**
   - 定义了所有的映射关系
   - 区分 National 和 Regional 数据
   - 定义 ACT_ABB 和 SEC_ABB

3. **农业数据确实是 National 级别**
   - 在 GCAM_GAINS_SEC_ACT_MAP.csv 中标记为 "National"
   - gcam2gains 会自动使用权重分配到省级

4. **我之前创建的文件都不需要**
   - buildings_services.csv ❌
   - transport_modes.csv ❌
   - convert_buildings_to_gains() ❌
   - 等等...

### 正确的工作

✅ 更新 gcamreport 的农业映射文件，使其输出正确的 IAMC 变量名

---

**报告日期**: 2026-04-19
**理解状态**: 完全明白
**下一步**: 测试完整流程
