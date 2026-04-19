# GCAM2GAINS 测试检查清单

**日期**: 2026-04-19
**测试目的**: 验证完整的 GCAM → IAMC → GAINS 工作流程

---

## 测试步骤

### Step 1: 生成 IAMC 报告 ⏳ 进行中

**命令**:
```r
gcamreport::generate_report(
  db_path = 'E:/GCAM/GCAM-China_v7.1/output',
  db_name = 'China60Ref',
  prj_name = 'China60Ref_gains_test',
  scenarios = 'China60ref',
  GCAM_version = 'vGCAMChina7.1',
  desired_regions = 'All',
  save_output = 'CSV',
  launch_ui = FALSE
)
```

**预期输出**:
- `China60Ref_gains_test_standardized.csv` (IAMC 格式)

**检查项**:
- [ ] 文件是否生成
- [ ] 文件大小是否合理（应该有几十MB）
- [ ] 是否包含所有需要的变量

---

### Step 2: 检查 IAMC 变量

**检查关键变量是否存在**:

```r
# 读取生成的 IAMC 文件
iamc <- read.csv("China60Ref_gains_test_standardized.csv")

# 检查变量列表
unique_vars <- unique(iamc$Variable)

# 检查关键变量
key_vars <- c(
  # 畜牧业
  "Agricultural Production|Non-Energy|Livestock|Beef",
  "Agricultural Production|Non-Energy|Livestock|Pork",

  # 土地利用
  "Land Cover|Forest|Managed",
  "Land Cover|Cropland|Otherarable",
  "Land Cover|Pasture|Grazed",

  # 建筑能源
  "Final Energy|Residential and Commercial|Electricity",

  # 交通能源
  "Final Energy|Transportation|Liquids",

  # 工业能源
  "Final Energy|Industry|Chemicals|Electricity",

  # 发电
  "Secondary Energy|Electricity|Coal|w/o CCS"
)

# 检查每个变量
for (var in key_vars) {
  exists <- var %in% unique_vars
  cat(sprintf("%s: %s\n", ifelse(exists, "✅", "❌"), var))
}
```

**检查项**:
- [ ] 畜牧业变量（5个）
- [ ] 土地利用变量（3个）
- [ ] 建筑能源变量
- [ ] 交通能源变量
- [ ] 工业能源变量
- [ ] 发电变量

---

### Step 3: 检查区域覆盖

**检查是否包含所有区域**:

```r
# 检查区域列表
unique_regions <- unique(iamc$Region)

# 应该包含
expected_regions <- c(
  "China",  # 国家级
  "AH", "BJ", "CQ", "FJ", "GD", "GS", "GX", "GZ",  # 省份
  "HA", "HB", "HE", "HI", "HL", "HN", "JL", "JS",
  "JX", "LN", "NM", "NX", "QH", "SC", "SD", "SH",
  "SN", "SX", "TJ", "XJ", "XZ", "YN", "ZJ"
)

cat("Expected regions:", length(expected_regions), "\n")
cat("Found regions:", length(unique_regions), "\n")
cat("Missing:", setdiff(expected_regions, unique_regions), "\n")
```

**检查项**:
- [ ] 包含 China（国家级）
- [ ] 包含 31 个省份
- [ ] 总共 32 个区域

---

### Step 4: 准备 gcam2gains 输入

**复制文件到 gcam2gains 输入目录**:

```bash
cd /e/GCAM/GCAM_tools/gcam2gains

# 备份旧文件
if [ -f data/input/gcam_china_iamc_full.csv ]; then
  mv data/input/gcam_china_iamc_full.csv data/input/gcam_china_iamc_full.csv.backup
fi

# 复制新文件
cp /path/to/China60Ref_gains_test_standardized.csv data/input/gcam_china_iamc_full.csv
```

**检查项**:
- [ ] 文件已复制到正确位置
- [ ] 文件名正确

---

### Step 5: 运行 gcam2gains 转换

**命令**:
```bash
cd /e/GCAM/GCAM_tools/gcam2gains
python run_gcam2gains.py
```

**预期输出**:
```
Loading GCAM data...
  Loaded XXXX records
Converting IAMC wide format to long format...
Filtering for Primary Energy and Final Energy variables...
Initializing mapper...
Mapping to GAINS format...
Splitting by province...
  Split into 31 provinces
✅ Conversion complete!
```

**检查项**:
- [ ] 没有报错
- [ ] 成功加载数据
- [ ] 成功映射变量
- [ ] 成功拆分到 31 个省

---

### Step 6: 检查 GAINS 输出

**检查输出文件**:

```bash
cd /e/GCAM/GCAM_tools/gcam2gains/data/output/gains_input

# 列出所有省份文件
ls -lh *.csv

# 应该有 31 个文件
ls *.csv | wc -l
```

**预期文件**:
```
CHIN_ANHU.csv  (安徽)
CHIN_BEIJ.csv  (北京)
CHIN_CHON.csv  (重庆)
CHIN_FUJI.csv  (福建)
CHIN_GUAN.csv  (广东)
... (共 31 个)
```

**检查项**:
- [ ] 生成了 31 个省份文件
- [ ] 每个文件大小合理（不为空）
- [ ] 文件格式正确

---

### Step 7: 验证数据质量

**检查一个省份文件的内容**:

```bash
# 查看安徽省的数据
head -20 /e/GCAM/GCAM_tools/gcam2gains/data/output/gains_input/CHIN_ANHU.csv
```

**预期格式**:
```csv
YEAR,ACT_ABB,SEC_ABB,VALUE,SOURCE_VARIABLE,SOURCE_UNIT,GAINS_UNIT
2020,ELE,DOM_COM,500,Final Energy|Residential and Commercial|Electricity,EJ/yr,PJ
2020,HC3,CON_LOSS,4.83,Primary Energy|Coal|Convert,EJ/yr,PJ
...
```

**检查项**:
- [ ] 包含正确的列
- [ ] 有数据（不是全部为0）
- [ ] ACT_ABB 和 SEC_ABB 正确
- [ ] 单位转换正确

---

### Step 8: 验证数值守恒

**检查省份总和是否等于国家级**:

```python
import pandas as pd
from pathlib import Path

# 读取所有省份文件
gains_dir = Path('/e/GCAM/GCAM_tools/gcam2gains/data/output/gains_input')
all_data = pd.concat([pd.read_csv(f) for f in gains_dir.glob('*.csv')])

# 按变量分组求和
provincial_sum = all_data.groupby(['YEAR', 'SOURCE_VARIABLE'])['VALUE'].sum()

# 读取原始 IAMC 数据中的 China 国家级数据
iamc = pd.read_csv('data/input/gcam_china_iamc_full.csv')
china_data = iamc[iamc['Region'] == 'China']

# 对比
print("Checking conservation...")
# 这里需要具体的对比逻辑
```

**检查项**:
- [ ] 省份总和 ≈ 国家级数据
- [ ] 误差 < 1%

---

## 常见问题排查

### 问题 1: gcamreport 报错

**可能原因**:
- 数据库路径不正确
- 映射文件有语法错误
- 缺少必要的包

**解决方案**:
- 检查路径
- 检查映射文件语法
- 安装缺失的包

### 问题 2: gcam2gains 找不到变量

**可能原因**:
- IAMC 变量名与 GCAM_GAINS_SEC_ACT_MAP.csv 不匹配
- 某些变量没有生成

**解决方案**:
- 检查 IAMC 文件中的变量名
- 对比 GCAM_GAINS_SEC_ACT_MAP.csv
- 修正映射文件

### 问题 3: 数值不守恒

**可能原因**:
- gcam2gains 的权重文件有问题
- 某些数据丢失

**解决方案**:
- 重新提取权重
- 检查数据完整性

---

## 成功标准

测试成功的标准：

1. ✅ gcamreport 成功生成 IAMC 文件
2. ✅ IAMC 文件包含所有关键变量
3. ✅ IAMC 文件包含 China + 31 个省
4. ✅ gcam2gains 成功转换
5. ✅ 生成 31 个省份的 GAINS 文件
6. ✅ 数据格式正确
7. ✅ 数值守恒（误差 < 1%）

---

**测试日期**: 2026-04-19
**测试状态**: ⏳ 进行中
