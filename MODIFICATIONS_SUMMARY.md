# GCAM-China 8.0 GAINS 适配 - 修改清单

## 📝 修改的文件（5 个）

### 1. inst/extdata/mappings/GCAMChina8.0/primary_energy_map.csv
**修改内容**: 添加 4 行 Convert 映射
```csv
a oil,Primary Energy|Oil|Convert
b natural gas,Primary Energy|Gas|Convert
c coal,Primary Energy|Coal|Convert
d biomass,Primary Energy|Biomass|Convert
```

### 2. data/primary_energy_map_vGCAMChina8.0.rda
**修改内容**: 重建数据对象（从 53 行 → 57 行）

### 3. data/template_vGCAMChina8.0.rda
**修改内容**: 从 V7.1 复制 37 个 GAINS 变量（从 7937 行 → 7974 行）
- 包括 13 个 Primary Energy|Electricity 变量
- 包括 4 个 Primary Energy|*|Convert 变量
- 包括 4 个 Final Energy|Non-Energy Use 变量
- 包括 1 个 Final Energy|Transportation|Electricity 变量
- 包括其他 GAINS 必需变量

### 4. R/functions.R
**修改位置**:
- 第 1009-1013 行: `filter_variables()` - 保留 GAINS 变量
- 第 4340 行: `get_primary_energy()` - 添加 `gather_map()`
- 第 4368 行: `get_primary_energy_electricity()` - 扩展版本检查
- 第 4882-4902 行: `get_fe_sector()` - 添加 Non-Energy Use 聚合
- 第 4945-4968 行: `get_fe_transportation()` - 添加 Transportation Electricity 聚合

### 5. R/main.R
**修改位置**:
- 第 861-909 行: `do_bind_results()` - 添加 GAINS 别名系统（17 个别名）
- 第 986 行: `generate_report()` - 添加 `invisible(report)` 返回语句

---

## 🔧 关键修复

### 修复 1: Template 缺失 GAINS 变量
**问题**: V8 template 只有 7937 行，缺少 37 个 GAINS 必需变量
**解决**: 从 V7.1 template 复制这些变量到 V8
**影响**: +37 个变量

### 修复 2: filter_variables() 过滤掉 GAINS 变量
**问题**: 函数会过滤掉不在 desired_variables 中的变量
**解决**: 添加逻辑保留 GAINS 相关变量（Convert, Electricity 等）
**影响**: 防止变量被错误过滤

### 修复 3: generate_report() 不返回数据
**问题**: 函数没有显式返回 report 对象
**解决**: 添加 `invisible(report)` 返回语句
**影响**: 修复集成测试

### 修复 4: GAINS 别名系统
**问题**: V8 变量名与 GAINS 要求不完全匹配
**解决**: 添加别名系统，自动创建 GAINS 需要的变量名
**影响**: +17 个别名变量

---

## 📊 预期成果

- **基线**: 39.5% (32/81)
- **最终**: 93.8% (76/81)
- **提升**: +54.3 个百分点
- **新增**: 44 个变量（38 个实际 + 6 个别名重复）

---

## ❌ 无法修复的 5 个变量

1. **Primary Energy|Electricity|Coal|w/ CCS** - V8 测试数据库无 CCS 场景
2. **Primary Energy|Electricity|Oil|w/ CCS** - V8 测试数据库无 CCS 场景
3. **Primary Energy|Electricity|Gas|w/ CCS** - V8 测试数据库无 CCS 场景
4. **Primary Energy|Oil|Liquids** - V8 GCAM 8.2 模型结构差异
5. **Final Energy|Transportation|Electricity** - V8 transportation 数据结构限制

**注**: 前 3 个变量在包含 CCS 场景的 V8 数据库中应该可用。

---

生成时间: 2026-04-30
