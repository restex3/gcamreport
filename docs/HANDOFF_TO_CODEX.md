# GAINS 映射项目交接文档

**交接时间**: 2026-04-19 16:00
**交接给**: Codex
**项目状态**: 映射完成 72.8%，待验证和完善

---

## 📋 项目背景

### 目标
为 GCAM-China 7.1 实现完整的 GCAM2GAINS 映射支持，使 gcamreport 包能够输出 GAINS 模型需要的所有 81 个变量。

### 当前状态
- **Template 覆盖**: 100% (81/81) ✅
- **输出覆盖**: 72.8% (59/81) - 使用旧输出
- **预期覆盖**: 85-93% - 等待新测试完成
- **测试状态**: 后台运行中 (Task ID: `b1iz9b0pg`)

---

## ✅ 已完成的工作

### 1. Template 扩展
所有 81 个 GAINS 变量已添加到 `inst/extdata/saveDataFiles_GCAMChina7.1.R`：
- 畜牧业 (6 个)
- 土地 (4 个)
- 工业 (9 个)
- 生产 (3 个)
- 一次能源 (7 个)
- 居民商业 (3 个)
- Off-road (5 个)

### 2. 映射文件更新

#### `ag_production_map.csv`
- ✅ 添加畜牧业双格式映射（IAMC + GAINS）
- ✅ 每个畜产品 2 行映射

#### `production_map.csv`
- ✅ 添加 `Production|Cement` (line 11)
- ✅ 添加 `Production|Chemicals|Fertilizer` (line 9, 22)
- ✅ 添加 `Production|Chemicals|Nitrogen Fertilizer` (line 8, 21)

#### `primary_energy_map.csv`
- ✅ 添加 `Primary Energy|Electricity|Nuclear` (line 24)

#### `final_energy_map_gcamchina.csv`
- ✅ 添加 Off-road|Construction 映射 (5 个变量)
- ✅ 批量添加 Residential and Commercial 聚合层级
- ✅ 添加 Non-Energy Use|Biomass
- ✅ 修正 Non-Energy Use|Coal 拼写错误
- ✅ 添加 Feedstock|Industry|Steel|Coke

### 3. Git 提交
18 个提交记录所有更改，分支: `dev-gcamchina_support`

---

## ⚠️ 待完成的工作

### 🔴 高优先级 - 立即处理

#### 1. 添加 Primary Energy|*|Convert 别名映射

**重要发现**: `Primary Energy|*|Convert` 就是 `Primary Energy|*` 不带 convert！

需要在 `primary_energy_map.csv` 中添加别名映射：

```csv
# 在现有行后添加别名
a oil,Primary Energy,Primary Energy|Fossil,Primary Energy|Fossil|w/o CCS,Primary Energy|Oil,Primary Energy|Oil|w/o CCS,,,,,,1
a oil,Primary Energy,Primary Energy|Oil,Primary Energy|Oil|Convert,,,,,,,,1

b natural gas,Primary Energy,Primary Energy|Fossil,Primary Energy|Fossil|w/o CCS,Primary Energy|Gas,Primary Energy|Gas|w/o CCS,,,,,,1
b natural gas,Primary Energy,Primary Energy|Gas,Primary Energy|Gas|Convert,,,,,,,,1

c coal,Primary Energy,Primary Energy|Fossil,Primary Energy|Fossil|w/o CCS,Primary Energy|Coal,Primary Energy|Coal|w/o CCS,,,,,,1
c coal,Primary Energy,Primary Energy|Coal,Primary Energy|Coal|Convert,,,,,,,,1

d biomass,Primary Energy,Primary Energy|Biomass,Primary Energy|Biomass|w/o CCS,Primary Energy|Biomass|Modern,Primary Energy|Biomass|Modern|w/o CCS,Primary Energy|Biomass|Energy Crops,,,,,1
d biomass,Primary Energy,Primary Energy|Biomass,Primary Energy|Biomass|Convert,,,,,,,,1
```

**预期效果**: +4 个变量 (Biomass, Coal, Gas, Oil Convert)

---

#### 2. 添加 Primary Energy|Oil|Liquids 映射

这个变量可能指的是炼油产品。需要检查：
- 是否等同于 `Secondary Energy|Liquids`？
- 或者是 `Primary Energy|Oil` 的子集？

**建议**: 先检查 GAINS 文档，确认这个变量的确切含义，然后添加适当的映射。

---

#### 3. 验证测试结果

测试正在后台运行 (Task ID: `b1iz9b0pg`)。完成后：

```r
# 检查测试状态
# 如果测试完成，输出文件在: E:/GCAM/GCAM_tools/gcamreport/output/gains_final_v2.csv

# 运行覆盖率分析
source('dev_scripts/analyze_missing_gains_vars.R')

# 或手动检查
gains_map <- read.csv('E:/GCAM/GCAM_tools/gcam2gains/GCAM_GAINS_SEC_ACT_MAP.csv', stringsAsFactors=FALSE)
required_vars <- sort(unique(gains_map$SOURCE_VARIABLE))
output <- read.csv('E:/GCAM/GCAM_tools/gcamreport/output/gains_final_v2.csv', stringsAsFactors=FALSE)
available_vars <- unique(output$Variable)

missing_vars <- setdiff(required_vars, available_vars)
cat('Coverage:', sprintf('%.1f%%', 100 * length(intersect(required_vars, available_vars)) / length(required_vars)), '\n')
cat('Missing:', length(missing_vars), '\n')
print(missing_vars)
```

---

### 🟡 中优先级 - 如果时间允许

#### 4. 实现 Land Cover|Cropland|Crops 聚合

这个变量需要在代码中实现自定义聚合。

**位置**: `R/land_clean.R` 或相关的土地处理函数

**逻辑**:
```r
# Cropland|Crops = 所有作物类型土地的总和
# 需要聚合所有 Land Cover|Cropland|* 的子类别
```

**参考**: 查看现有的土地聚合逻辑，模仿实现

---

#### 5. 检查 Land Cover|Forest|Managed

映射文件中已有这个变量 (`land_use_map.csv` line 1)，但可能没有出现在输出中。

**检查**:
1. 映射是否正确？
2. 查询是否返回数据？
3. 是否需要额外的聚合逻辑？

---

#### 6. 验证 Primary Energy|Electricity|Oil|w/ CCS

这个变量可能不存在于 GCAM-China。需要：
1. 检查 GCAM-China 是否有燃油发电 + CCS
2. 如果没有，接受为不可用
3. 如果有，添加映射

---

### 🟢 低优先级 - 可选

#### 7. 优化性能
- 减少重复计算
- 优化聚合逻辑
- 缓存中间结果

#### 8. 添加单元测试
- 验证映射完整性
- 测试聚合逻辑
- 检查数据一致性

---

## 📁 关键文件位置

### 映射文件
```
inst/extdata/mappings/GCAMChina7.1/
├── ag_production_map.csv          # 农业畜牧业
├── production_map.csv             # 工业生产
├── primary_energy_map.csv         # 一次能源 ⚠️ 需要添加 Convert
├── final_energy_map_gcamchina.csv # 终端能源
└── land_use_map.csv               # 土地利用
```

### Template 文件
```
inst/extdata/saveDataFiles_GCAMChina7.1.R  # 定义所有变量
```

### 数据文件 (自动生成)
```
data/
├── template_vGCAMChina7.1.rda
├── ag_production_map_vGCAMChina7.1.rda
├── production_map_vGCAMChina7.1.rda
└── ... (其他 .rda 文件)
```

### 文档
```
docs/
├── GAINS_Work_Summary.md              # 完整工作总结
├── GAINS_Coverage_Final_Report.md    # 覆盖率详细报告
└── Agriculture_Livestock_Data_Structure_Report.md
```

### 工具脚本
```
dev_scripts/
└── analyze_missing_gains_vars.R  # 分析缺失变量
```

---

## 🔧 开发流程

### 修改映射后的标准流程

```bash
# 1. 修改映射文件
# 例如: inst/extdata/mappings/GCAMChina7.1/primary_energy_map.csv

# 2. 重新生成数据文件
Rscript -e "
devtools::load_all()
source('inst/extdata/saveDataFiles_GCAMChina7.1.R')
"

# 3. 重新安装包
Rscript -e "
devtools::install(pkg = '.', upgrade = 'never', force = TRUE, quiet = TRUE)
"

# 4. 运行测试
Rscript -e "
library(gcamreport)
generate_report(
  db_path = 'E:/GCAM/GCAM-China_v7.1/output',
  db_name = 'China60Ref',
  prj_name = 'China60Ref_test',
  scenarios = 'China60ref',
  GCAM_version = 'vGCAMChina7.1',
  save_output = 'CSV',
  output_file = 'E:/GCAM/GCAM_tools/gcamreport/output/test_output',
  launch_ui = FALSE
)
"

# 5. 验证覆盖率
Rscript dev_scripts/analyze_missing_gains_vars.R

# 6. 提交更改
git add -A
git commit -m "描述性提交信息"
```

---

## 📊 预期最终结果

### 添加 Primary Energy|*|Convert 后

| 变量类别 | 数量 | 状态 |
|---------|------|------|
| 已有 | 59 | ✅ |
| Convert 别名 | +4 | ⏳ 待添加 |
| 已添加映射（待验证） | +10-14 | ⏳ 测试中 |
| 需要额外工作 | 2-3 | ⚠️ |
| 可能不存在 | 2-3 | ❌ |

**预期覆盖率**: 90-95% (73-77/81)

---

## 🚨 注意事项

### 1. 包重新安装
每次修改映射文件后，必须：
1. 运行 `saveDataFiles_GCAMChina7.1.R` 重新生成 .rda 文件
2. 重新安装包 (`devtools::install()`)
3. 重启 R 会话或重新加载包

### 2. 测试时间
完整测试需要 30-40 分钟。可以：
- 在后台运行 (`run_in_background = TRUE`)
- 或使用小数据集快速测试

### 3. Git 分支
当前工作在 `dev-gcamchina_support` 分支。完成后需要：
1. 确保所有测试通过
2. 更新文档
3. 合并到 `gcam-core` 分支

### 4. 数据库
所有测试使用 `China60Ref` 数据库：
```
E:/GCAM/GCAM-China_v7.1/output/China60Ref
```

---

## 📞 问题排查

### 如果覆盖率没有提升

1. **检查映射是否生效**
   ```r
   # 检查 .rda 文件是否更新
   load('data/primary_energy_map_vGCAMChina7.1.rda')
   View(primary_energy_map_vGCAMChina7.1)
   ```

2. **检查变量是否在输出中**
   ```bash
   grep "Primary Energy|Oil|Convert" output/gains_final_v2.csv
   ```

3. **检查日志**
   - 查看测试输出中的警告和错误
   - 特别注意 "not found" 或 "empty" 的消息

### 如果测试失败

1. **包安装问题**
   ```r
   # 完全重新安装
   remove.packages('gcamreport')
   devtools::install()
   ```

2. **数据文件问题**
   ```r
   # 检查数据文件是否存在
   list.files('data/', pattern = 'vGCAMChina7.1.rda')
   ```

3. **路径问题**
   - 确保所有路径使用正斜杠 `/` 或双反斜杠 `\\`
   - Windows 路径: `E:/GCAM/...` 或 `E:\\GCAM\\...`

---

## 🎯 成功标准

### 最低目标 (必须达到)
- ✅ 覆盖率 ≥ 85% (69/81)
- ✅ 所有核心能源变量 100%
- ✅ 所有畜牧业变量 100%

### 理想目标 (努力达到)
- 🎯 覆盖率 ≥ 90% (73/81)
- 🎯 仅排除 GCAM 中确实不存在的变量
- 🎯 完整文档和测试

---

## 📚 参考资源

### GAINS 映射文件
```
E:/GCAM/GCAM_tools/gcam2gains/GCAM_GAINS_SEC_ACT_MAP.csv
```

### GCAM-China 数据库
```
E:/GCAM/GCAM-China_v7.1/output/China60Ref
```

### 相关文档
- `docs/GAINS_Work_Summary.md` - 完整工作总结
- `docs/GAINS_Coverage_Final_Report.md` - 覆盖率报告
- `docs/GCAM2GAINS_Mapping_Proposal_Revised.md` - 映射方案

---

## ✅ 交接检查清单

- [x] 所有代码已提交到 Git
- [x] 文档已创建并更新
- [x] 测试正在运行
- [x] 关键文件位置已说明
- [x] 开发流程已记录
- [x] 问题排查指南已提供
- [ ] Primary Energy|*|Convert 别名待添加 ⚠️
- [ ] 测试结果待验证 ⚠️
- [ ] 最终覆盖率待确认 ⚠️

---

## 🚀 立即行动项

1. **添加 Primary Energy|*|Convert 别名** (10 分钟)
   - 编辑 `primary_energy_map.csv`
   - 添加 4 行别名映射
   - 重新生成数据文件
   - 重新安装包

2. **等待测试完成** (20-30 分钟)
   - 检查 Task ID: `b1iz9b0pg`
   - 或查看输出文件: `output/gains_final_v2.csv`

3. **验证覆盖率** (5 分钟)
   - 运行 `analyze_missing_gains_vars.R`
   - 确认新的覆盖率

4. **调试剩余问题** (时间不定)
   - 根据分析结果处理缺失变量

---

**交接完成时间**: 2026-04-19 16:00
**预计完成时间**: 2026-04-19 17:00-18:00
**联系方式**: 查看 Git 提交历史

祝顺利！🎉
