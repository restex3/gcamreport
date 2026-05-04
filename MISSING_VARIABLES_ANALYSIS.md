# 缺失变量详细分析

## 总览

- **总计缺失**: 12 个变量
- **可修复**: 3 个
- **不可修复**: 9 个

---

## 📋 详细分析

### 类别 1: CCS 相关（3 个）- 数据库限制

#### 1. Primary Energy|Electricity|Coal|w/ CCS
- **状态**: ❌ 不可修复（当前数据库）
- **原因**: V8 测试数据库 (`database_basexdb_v8_test.dat`) 不包含 CCS 场景
- **解决方案**: 使用包含 CCS 场景的 V8 数据库
- **预期**: 在 CCS 场景数据库中应该可用

#### 2. Primary Energy|Electricity|Oil|w/ CCS
- **状态**: ❌ 不可修复（当前数据库）
- **原因**: 同上
- **解决方案**: 同上

#### 3. Primary Energy|Electricity|Gas|w/ CCS
- **状态**: ❌ 不可修复（当前数据库）
- **原因**: 同上
- **解决方案**: 同上

---

### 类别 2: Off-road Construction（5 个）- 模型结构限制

#### 4. Final Energy|Industry|Off-road|Construction
#### 5. Final Energy|Industry|Off-road|Construction|Electricity
#### 6. Final Energy|Industry|Off-road|Construction|Gases
#### 7. Final Energy|Industry|Off-road|Construction|Hydrogen
#### 8. Final Energy|Industry|Off-road|Construction|Liquids

- **状态**: ❌ 不可修复
- **原因**: GCAM 8.2 / GCAM-China 8.0 模型结构中不包含 Off-road Construction 部门
- **说明**: 这是 GCAM 模型版本差异，V7.1 可能有但 V8 移除了
- **解决方案**: 无法通过代码修复，需要模型数据支持

---

### 类别 3: 其他（4 个）

#### 9. Feedstock|Industry|Steel|Coke
- **状态**: ❌ 不可修复
- **原因**: V8 模型中 Steel 部门不单独报告 Coke feedstock
- **说明**: V8 的 Steel 生产数据结构与 V7.1 不同
- **解决方案**: 需要模型层面的数据支持

#### 10. Primary Energy|Oil|Liquids
- **状态**: ❌ 不可修复
- **原因**: GCAM 8.2 的 Primary Energy 分类结构变化
- **说明**: V8 使用不同的 Oil 产品分类方式
- **解决方案**: 需要重新映射 V8 的 Oil 产品分类

#### 11. Final Energy|Transportation|Electricity
- **状态**: ⚠️ 可能可修复
- **原因**: V8 的 transportation 数据没有按燃料类型聚合
- **当前状态**: 
  - V8 有 transportation electricity 原始数据（8107 行）
  - 但 `get_fe_transportation()` 函数没有生成按燃料聚合的变量
- **解决方案**: 修改 `get_fe_transportation()` 函数，添加按燃料类型聚合逻辑
- **预期工作量**: 中等（需要修改函数逻辑）

#### 12. Final Energy|Residential and Commercial|Electricity
- **状态**: ⚠️ 可能可修复
- **原因**: 类似 Transportation Electricity，缺少聚合逻辑
- **解决方案**: 检查 `get_fe_buildings()` 函数，添加聚合逻辑
- **预期工作量**: 中等

---

## 📊 可达到的最大覆盖率

### 场景 1: 当前数据库
- **当前**: 85.2% (69/81)
- **修复 Transportation + Buildings Electricity**: 87.7% (71/81)
- **剩余不可修复**: 10 个

### 场景 2: 使用 CCS 场景数据库
- **当前**: 85.2% (69/81)
- **+ CCS 变量**: 88.9% (72/81)
- **+ Transportation + Buildings**: 91.4% (74/81)
- **剩余不可修复**: 7 个

### 场景 3: 理论最大值
- **假设所有可修复的都修复**: 91.4% (74/81)
- **永久不可修复**: 7 个（Off-road Construction 5个 + Feedstock 1个 + Oil Liquids 1个）

---

## 🎯 建议

### 短期（立即可做）
1. ✅ **已完成**: 85.2% 覆盖率
2. ⏳ **可选**: 修复 Transportation 和 Buildings Electricity → 87.7%

### 中期（需要数据支持）
3. 使用包含 CCS 场景的 V8 数据库 → 91.4%

### 长期（需要模型支持）
4. 等待 GCAM 模型更新或使用不同的 GAINS 映射规则

---

## ✅ 结论

**当前成果**: 85.2% 覆盖率，从 39.5% 提升了 45.7 个百分点

**实际可达**: 87.7% - 91.4%（取决于数据库和进一步修复）

**永久限制**: 约 7-10 个变量由于模型结构差异无法覆盖

---

生成时间: 2026-04-30
