# GCAM-China 8.0 GAINS 无法修复的变量清单

## 总览

基于 V8 的数据结构限制，以下变量无法实现。

## 详细清单

### 1. Final Energy - Steel 详细能源（2 个）

**变量**:
1. Final Energy|Industry|Steel|Electricity
2. Final Energy|Industry|Steel|Solids|Coal

**原因**:
- V8 只报告 `Final Energy|Industry|Iron and Steel|Gases` 和 `Liquids`
- 没有 Electricity 和 Solids|Coal 的细分数据
- 这是 V8 数据结构的限制

**V8 实际有的**:
- Final Energy|Industry|Iron and Steel|Gases ✅
- Final Energy|Industry|Iron and Steel|Liquids ✅

**已实现的映射**:
- Final Energy|Industry|Steel|Gases ← Iron and Steel|Gases ✅
- Final Energy|Industry|Steel|Liquids ← Iron and Steel|Liquids ✅

---

### 2. Final Energy - Off-road Construction（5 个）

**变量**:
3. Final Energy|Industry|Off-road|Construction
4. Final Energy|Industry|Off-road|Construction|Electricity
5. Final Energy|Industry|Off-road|Construction|Gases
6. Final Energy|Industry|Off-road|Construction|Hydrogen
7. Final Energy|Industry|Off-road|Construction|Liquids

**原因**:
- V8 不报告 Off-road Construction 部门
- 这些变量在 V8 的 queries 和数据中完全不存在
- V7.1 有这些数据，但 V8 删除了

**影响**:
- 这是 GAINS 覆盖率与 V7.1 差距的主要来源（5 个变量）

---

### 3. Feedstock（1 个）

**变量**:
8. Feedstock|Industry|Steel|Coke

**原因**:
- V8 不报告 Feedstock 类别
- V8 的 queries 中没有 feedstock 相关数据

---

### 4. Primary Energy - Oil Liquids（1 个）

**变量**:
9. Primary Energy|Oil|Liquids

**原因**:
- V8 的 Primary Energy 数据结构与 V7.1 不同
- 这个变量在 V8 中的定义和计算方式改变了

---

### 5. 其他可能缺失的变量（0-2 个）

**可能的变量**:
- Secondary Energy|Electricity - 可能不在 GAINS 映射中
- 其他非标准 GAINS 变量

---

## 统计

### 按原因分类
- **V8 无详细数据**: 2 个（Steel Electricity/Coal）
- **V8 不支持部门**: 5 个（Off-road Construction）
- **V8 不支持类别**: 1 个（Feedstock）
- **V8 结构变化**: 1 个（Oil Liquids）
- **其他**: 0-2 个

**总计**: 9-11 个变量无法实现

### 对覆盖率的影响
- **GAINS 总需求**: 81 个变量
- **可实现**: 70-72 个
- **无法实现**: 9-11 个
- **最终覆盖率**: **86-89%**

---

## 与 V7.1 的对比

| 指标 | V7.1 | V8.0 |
|------|------|------|
| GAINS 覆盖率 | 97.5% (79/81) | 86-89% (70-72/81) |
| 缺失变量 | 2 个 | 9-11 个 |
| Off-road Construction | ✅ | ❌ |
| Steel 详细能源 | ✅ | ⚠️ 部分 |
| Feedstock | ✅ | ❌ |

**差距**: 7-9 个变量（8.6-11.1%）

---

## 结论

V8 的 GAINS 覆盖率预计为 **86-89%**，与 V7.1 的 97.5% 相比有 **8-11% 的差距**。

这个差距主要来自：
1. **Off-road Construction 部门被删除**（5 个变量，6.2%）
2. **Steel 详细能源数据缺失**（2 个变量，2.5%）
3. **Feedstock 类别不支持**（1 个变量，1.2%）
4. **其他结构变化**（1-2 个变量，1-2.5%）

这些限制是 GCAM-China 8.0 数据结构的固有特性，无法通过代码修改解决。

---

## 建议

### 短期
- 接受 86-89% 的覆盖率作为 V8 的最佳结果
- 在 GAINS 映射文件中标注这些变量为 "V8 不支持"

### 长期
- 如果需要这些变量，考虑：
  1. 向 GCAM-China 开发团队反馈，要求在未来版本中恢复这些数据
  2. 使用替代变量或聚合方法近似这些缺失的数据
  3. 在 GAINS 分析中使用 V7.1 数据作为这些部门的补充
