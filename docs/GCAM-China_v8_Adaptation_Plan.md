# GCAM-China v8 适配方案

**日期**: 2026-04-19
**目的**: 为 GCAM-China v8 创建映射文件，参考 GCAM v8.2

---

## 背景

### 当前状态
- ✅ GCAM-China v7.1 映射已完成
- ✅ GAINS 映射已修正
- ⏭️ 需要支持 GCAM-China v8

### GCAM v8.2 的变化
根据 GCAM v8.2 的更新，可能的变化包括：
1. 新的技术类型
2. 更新的部门结构
3. 新的查询格式
4. 变量命名的变化

---

## 适配方案

### 方案 1：复制并修改（推荐）

**步骤**:

1. **复制现有映射目录**
```bash
cd inst/extdata/mappings/
cp -r GCAMChina7.1 GCAMChina8.0
```

2. **检查 GCAM v8.2 的映射差异**
```bash
# 对比 GCAM v7.1 和 v8.2 的映射
diff -r mappings/v7.1 mappings/v8.2 > v8_changes.txt
```

3. **应用相同的变化到 GCAMChina8.0**
- 识别 v8.2 中的新技术
- 更新技术名称映射
- 添加新的部门映射

4. **验证映射完整性**
```r
# 测试 v8 映射
gcamreport::generate_report(
  db_path = "path/to/gcam-china-v8/output",
  db_name = "test_db",
  prj_name = "test_v8",
  GCAM_version = "vGCAMChina8.0"
)
```

---

### 方案 2：增量更新

**步骤**:

1. **创建差异文件**
```bash
# 列出 v8.2 相对于 v7.1 的新增内容
inst/extdata/mappings/GCAMChina8.0/
├── ag_production_map.csv          (从 v7.1 复制，检查差异)
├── land_use_map.csv                (从 v7.1 复制，检查差异)
├── CO2_tech_map.csv                (从 v7.1 复制，添加新技术)
├── elec_gen_map_gcamchina.csv      (检查新的发电技术)
└── ... (其他映射文件)
```

2. **重点检查的文件**
- **发电技术**: 可能有新的可再生能源技术
- **工业部门**: 可能有新的工业子部门
- **交通部门**: 可能有新的交通模式
- **建筑部门**: 可能有新的建筑服务

3. **GAINS 映射验证**
- 确保新的 IAMC 变量名与 GAINS 要求一致
- 特别注意畜牧业和土地利用变量（已修正的部分）

---

## 具体实施计划

### Phase 1: 准备工作（1-2天）

**任务 1.1**: 获取 GCAM v8.2 映射文件
```bash
# 如果 gcamreport 已有 v8.2 支持
ls inst/extdata/mappings/ | grep "v8\|8.2"
```

**任务 1.2**: 对比 v7.1 和 v8.2 的差异
```bash
# 生成差异报告
for file in inst/extdata/mappings/v7.1/*.csv; do
  filename=$(basename $file)
  if [ -f "inst/extdata/mappings/v8.2/$filename" ]; then
    echo "=== $filename ===" >> v8_diff_report.txt
    diff inst/extdata/mappings/v7.1/$filename \
         inst/extdata/mappings/v8.2/$filename >> v8_diff_report.txt
  fi
done
```

**任务 1.3**: 创建 GCAMChina8.0 目录结构
```bash
mkdir -p inst/extdata/mappings/GCAMChina8.0
```

---

### Phase 2: 映射文件创建（3-5天）

#### 2.1 核心映射文件

**优先级 1 - 必须更新**:
1. `ag_production_map.csv` - 农业生产
   - ✅ 保留 v7.1 的 GAINS 修正
   - ⚠️ 检查是否有新的作物类型

2. `land_use_map.csv` - 土地利用
   - ✅ 保留 v7.1 的 GAINS 修正
   - ⚠️ 检查是否有新的土地类型

3. `CO2_tech_map.csv` - CO2 排放
   - ✅ 保留 v7.1 的 CCS 修正
   - ⚠️ 添加 v8 的新技术

**优先级 2 - 可能需要更新**:
4. `elec_gen_map_gcamchina.csv` - 发电
5. `final_energy_map_gcamchina.csv` - 终端能源
6. `transport_final_en_map_gcamchina.csv` - 交通
7. `primary_energy_map.csv` - 一次能源

**优先级 3 - 检查即可**:
8. 其他映射文件

#### 2.2 映射文件模板

**创建脚本**: `create_v8_mappings.R`
```r
# 自动化创建 v8 映射的脚本
library(dplyr)

# 1. 复制 v7.1 映射
v7_files <- list.files("inst/extdata/mappings/GCAMChina7.1",
                       pattern = "\\.csv$", full.names = TRUE)

for (file in v7_files) {
  filename <- basename(file)
  v8_file <- file.path("inst/extdata/mappings/GCAMChina8.0", filename)
  file.copy(file, v8_file, overwrite = TRUE)
  cat("Copied:", filename, "\n")
}

# 2. 读取 v8.2 的差异
# (需要手动识别差异)

# 3. 应用差异到 GCAMChina8.0
# (根据差异报告手动更新)

cat("GCAMChina8.0 mappings created\n")
```

---

### Phase 3: GAINS 映射验证（1-2天）

**任务 3.1**: 验证关键变量
```r
# 检查 GAINS 需要的变量是否都有映射
gains_vars <- c(
  # 畜牧业
  "Agricultural Production|Non-Energy|Livestock|Beef",
  "Agricultural Production|Non-Energy|Livestock|Dairy",
  "Agricultural Production|Non-Energy|Livestock|Pork",
  "Agricultural Production|Non-Energy|Livestock|Poultry",
  "Agricultural Production|Non-Energy|Livestock|SheepGoat",

  # 土地利用
  "Land Cover|Forest|Managed",
  "Land Cover|Cropland|Otherarable",
  "Land Cover|Pasture|Grazed"
)

# 验证这些变量在 v8 映射中是否正确
```

**任务 3.2**: 生成测试报告
```r
# 使用 v8 数据库测试
gcamreport::generate_report(
  db_path = "path/to/gcam-china-v8",
  db_name = "test_db",
  prj_name = "test_v8",
  GCAM_version = "vGCAMChina8.0",
  save_output = "CSV"
)

# 检查输出的 IAMC 变量名
output <- read.csv("test_v8_standardized.csv")
unique(output$Variable)
```

---

### Phase 4: 文档更新（1天）

**任务 4.1**: 更新文档
- 创建 `GCAM-China_v8_Migration_Guide.md`
- 记录 v7.1 到 v8 的变化
- 更新 GAINS 映射文档

**任务 4.2**: 更新代码
```r
# 在 main.R 中添加 v8 支持
available_GCAM_versions <- c(
  "v7.0", "v7.1", "v7.2",
  "vGCAMChina7.1", "vGCAMChina8.0"  # 新增
)
```

---

## 关键注意事项

### 1. 保留 GAINS 修正

**必须保留的修正**:
```csv
# ag_production_map.csv
Beef,Agricultural Production,Agricultural Production|Non-Energy,Agricultural Production|Non-Energy|Livestock,Agricultural Production|Non-Energy|Livestock|Beef,,1
Dairy,Agricultural Production,Agricultural Production|Non-Energy,Agricultural Production|Non-Energy|Livestock,Agricultural Production|Non-Energy|Livestock|Dairy,,1
Pork,Agricultural Production,Agricultural Production|Non-Energy,Agricultural Production|Non-Energy|Livestock,Agricultural Production|Non-Energy|Livestock|Pork,,1
Poultry,Agricultural Production,Agricultural Production|Non-Energy,Agricultural Production|Non-Energy|Livestock,Agricultural Production|Non-Energy|Livestock|Poultry,,1
SheepGoat,Agricultural Production,Agricultural Production|Non-Energy,Agricultural Production|Non-Energy|Livestock,Agricultural Production|Non-Energy|Livestock|SheepGoat,,1

# land_use_map.csv
Forest,NA,Land Cover,Land Cover|Forest,Land Cover|Forest|Managed,,,,,,0.1
OtherArableLand,NA,Land Cover,Land Cover|Cropland,Land Cover|Cropland|Otherarable,,,,,,0.1
Pasture,NA,Land Cover,Land Cover|Pasture,Land Cover|Pasture|Grazed,,,,,,0.1
```

### 2. CCS 技术映射

**确保 v8 的 CO2 映射包含所有 CCS 技术**:
- 为每个非 CCS 技术生成 CCS 版本
- 验证技术名称格式一致

### 3. 新技术识别

**可能的新技术**:
- 氢能技术
- 新型储能
- 碳捕集技术
- 新的可再生能源

---

## 测试计划

### 测试 1: 基本功能测试
```r
# 测试 v8 映射是否能正常加载
gcamreport::generate_report(
  db_path = "test_db_path",
  db_name = "test_db",
  prj_name = "test",
  GCAM_version = "vGCAMChina8.0"
)
```

### 测试 2: GAINS 变量验证
```r
# 验证 GAINS 需要的变量
output <- read.csv("test_standardized.csv")
gains_vars <- c(
  "Agricultural Production|Non-Energy|Livestock|Beef",
  # ... 其他变量
)
missing <- setdiff(gains_vars, unique(output$Variable))
if (length(missing) > 0) {
  cat("Missing GAINS variables:\n")
  print(missing)
}
```

### 测试 3: 完整流程测试
```bash
# 1. 生成 IAMC
Rscript -e "gcamreport::generate_report(...)"

# 2. 转换为 GAINS
cd /path/to/gcam2gains
python run_gcam2gains.py

# 3. 验证输出
ls data/output/gains_input/*.csv
```

---

## 时间估算

| 阶段 | 任务 | 时间 |
|------|------|------|
| Phase 1 | 准备工作 | 1-2 天 |
| Phase 2 | 映射文件创建 | 3-5 天 |
| Phase 3 | GAINS 验证 | 1-2 天 |
| Phase 4 | 文档更新 | 1 天 |
| **总计** | | **6-10 天** |

---

## 风险和缓解

### 风险 1: v8.2 映射不可用
**缓解**:
- 联系 gcamreport 团队获取 v8.2 映射
- 或者基于 v8.2 文档手动创建

### 风险 2: 技术名称变化
**缓解**:
- 详细对比 v7.1 和 v8 的查询结果
- 创建技术名称映射表

### 风险 3: GAINS 兼容性
**缓解**:
- 严格遵循 GCAM_GAINS_SEC_ACT_MAP.csv
- 保留所有 v7.1 的 GAINS 修正

---

## 下一步行动

### 立即可以做的

1. ⏭️ **检查 gcamreport 是否已有 v8.2 支持**
```bash
ls inst/extdata/mappings/ | grep "8"
```

2. ⏭️ **获取 GCAM-China v8 数据库**
- 用于测试和验证

3. ⏭️ **创建 v8 适配分支**
```bash
git checkout -b feature/gcam-china-v8-support
```

### 后续工作

4. ⏭️ 执行 Phase 1-4
5. ⏭️ 测试验证
6. ⏭️ 提交 PR

---

## 参考资料

- GCAM v8.2 文档
- GCAM-China v8 发布说明
- gcamreport v8.2 映射文件
- GCAM_GAINS_SEC_ACT_MAP.csv

---

**方案创建日期**: 2026-04-19
**预计开始时间**: 待定
**负责人**: 待定
