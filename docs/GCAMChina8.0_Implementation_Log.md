# GCAM-China v8 适配实施记录

**日期**: 2026-04-19
**状态**: 进行中

---

## 已完成的工作

### 1. 创建 GCAMChina8.0 目录 ✅

```bash
mkdir -p inst/extdata/mappings/GCAMChina8.0
cp -r GCAMChina7.1/* GCAMChina8.0/
```

**结果**: 68 个文件已复制

---

### 2. 对比分析 ✅

#### 文件大小对比

| 文件 | GCAMChina7.1 | GCAM8.2 | 差异 |
|------|--------------|---------|------|
| ag_production_map.csv | 26 | 26 | 相同 |
| land_use_map.csv | 73 | 73 | 相同 |
| CO2_tech_map.csv | 668 | 273 | v7.1 更大 |
| final_energy_map | 456 | 188 | v7.1 更大 |

#### 关键发现

**畜牧业映射差异**:

GCAM8.2 使用：
```
Beef → Agricultural Production|Livestock|Ruminant|Meat
Pork → Agricultural Production|Livestock|Non-Ruminant|Meat|Pig
```

GCAMChina7.1（我们的修正）使用：
```
Beef → Agricultural Production|Non-Energy|Livestock|Beef
Pork → Agricultural Production|Non-Energy|Livestock|Pork
```

**GAINS 要求**:
```
Agricultural Production|Non-Energy|Livestock|Beef  ✅ 我们的正确
Agricultural Production|Non-Energy|Livestock|Pork ✅ 我们的正确
```

**结论**:
- ✅ 我们的 GAINS 修正是正确的
- ❌ GCAM8.2 的标准映射不符合 GAINS 要求
- ✅ **必须保留我们的修正**

---

## 决策

### 保留的文件（来自 GCAMChina7.1）

1. **ag_production_map.csv** ✅
   - 原因：包含 GAINS 修正
   - 状态：保持不变

2. **land_use_map.csv** ✅
   - 原因：包含 GAINS 修正
   - 状态：保持不变

3. **CO2_tech_map.csv** ✅
   - 原因：包含完整的 666 个映射
   - 状态：保持不变

4. **所有 GCAM-China 特有的映射** ✅
   - elec_gen_map_gcamchina.csv
   - final_energy_map_gcamchina.csv
   - transport_final_en_map_gcamchina.csv
   - 等等

### 可能需要更新的文件

需要检查 GCAM8.2 是否有新的技术或部门：

1. **primary_energy_map.csv** ⚠️
   - 可能有新的能源类型

2. **nonCO2_emissions_sector_map.csv** ⚠️
   - 可能有新的排放部门

3. **其他通用映射** ⚠️
   - 需要逐个检查

---

## 下一步行动

### Phase 1: 验证当前映射 ⏭️

```bash
# 测试 GCAMChina8.0 映射是否可用
# （需要 GCAM-China v8 数据库）
```

### Phase 2: 检查差异 ⏭️

对比 GCAM8.2 和 GCAMChina7.1 的每个文件：
- 识别新增的技术
- 识别变化的变量名
- 决定是否需要更新

### Phase 3: 选择性更新 ⏭️

只更新那些：
- 有新技术的文件
- 有变量名变化的文件
- 不影响 GAINS 修正的文件

### Phase 4: 测试验证 ⏭️

使用 GCAM-China v8 数据库测试

---

## 当前状态

### 已完成
- ✅ 创建 GCAMChina8.0 目录
- ✅ 复制 v7.1 文件作为基础
- ✅ 对比分析关键文件
- ✅ 确认保留 GAINS 修正

### 进行中
- ⏳ 等待 v7.1 最终测试完成
- ⏳ 准备详细的文件对比

### 待完成
- ⏭️ 逐个文件对比差异
- ⏭️ 选择性更新
- ⏭️ 测试验证

---

## 重要注意事项

### 必须保留的修正

1. **GAINS 畜牧业映射** ✅
   - 5 个变量
   - 格式：`Agricultural Production|Non-Energy|Livestock|...`

2. **GAINS 土地利用映射** ✅
   - 3 个变量
   - 格式：`Land Cover|...|Managed/Otherarable/Grazed`

3. **完整的 CO2 映射** ✅
   - 666 个技术映射
   - 覆盖所有 GCAM-China 特有部门

### 不能直接使用 GCAM8.2 的原因

1. **GAINS 兼容性**
   - GCAM8.2 的畜牧业映射不符合 GAINS 要求

2. **GCAM-China 特殊性**
   - 有按需求等级细分的部门（d1-d10）
   - 需要更多的技术映射

3. **已验证的修正**
   - v7.1 的修正已经过验证
   - 不应该丢失这些工作

---

## 建议的策略

### 保守策略（推荐）

1. **保持 GCAMChina8.0 = GCAMChina7.1**
2. **只在发现问题时更新**
3. **逐步验证每个更新**

**优点**:
- ✅ 保留所有已验证的修正
- ✅ 风险最小
- ✅ 可以逐步改进

**缺点**:
- ⚠️ 可能错过 v8 的新特性

### 激进策略（不推荐）

1. **从 GCAM8.2 开始**
2. **重新应用 GAINS 修正**
3. **重新生成 CO2 映射**

**优点**:
- ✅ 使用最新的 v8 映射

**缺点**:
- ❌ 需要重新做所有工作
- ❌ 可能引入新问题
- ❌ 时间成本高

---

## 结论

**当前决策**: 采用保守策略

**理由**:
1. ✅ GAINS 修正已验证正确
2. ✅ CO2 映射已完整
3. ✅ 风险最小
4. ✅ 可以逐步改进

**下一步**:
- 等待 v7.1 测试完成
- 如果成功，GCAMChina8.0 可以直接使用
- 如果有 v8 数据库，再进行测试验证

---

**创建日期**: 2026-04-19
**最后更新**: 2026-04-19 05:30
**状态**: GCAMChina8.0 基础已创建，等待测试
