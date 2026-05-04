# 从 85.2% 到 100% 的路线图

## 当前状态：85.2% (69/81)
## 目标：100% (81/81)
## 需要修复：12 个变量

---

## 📋 12 个缺失变量分类

### 类别 A: 可立即修复（2 个）
1. **Final Energy|Transportation|Electricity** ⚠️
   - 原因：transportation 函数缺少按燃料聚合
   - 解决：修改 get_fe_transportation() 添加聚合逻辑
   - 难度：中

2. **Final Energy|Residential and Commercial|Electricity** ⚠️
   - 原因：buildings 函数缺少聚合
   - 解决：修改 get_fe_buildings() 添加聚合逻辑
   - 难度：中

### 类别 B: 需要数据库支持（3 个）
3. **Primary Energy|Electricity|Coal|w/ CCS** 🔄
4. **Primary Energy|Electricity|Oil|w/ CCS** 🔄
5. **Primary Energy|Electricity|Gas|w/ CCS** 🔄
   - 原因：测试数据库无 CCS 场景
   - 解决：使用包含 CCS 的数据库，或创建占位符
   - 难度：低（如果有 CCS 数据库）

### 类别 C: 模型结构限制（7 个）
6-10. **Final Energy|Industry|Off-road|Construction** 系列（5 个）❌
11. **Feedstock|Industry|Steel|Coke** ❌
12. **Primary Energy|Oil|Liquids** ❌
   - 原因：GCAM 8.2 模型不支持
   - 解决：创建占位符或从其他变量推算
   - 难度：高

---

## 🎯 实施计划

### 阶段 1: 立即修复（目标：87.7%）
- [ ] 修复 Transportation Electricity
- [ ] 修复 Buildings Electricity
- **预期覆盖率**: 87.7% (71/81)

### 阶段 2: CCS 占位符（目标：91.4%）
- [ ] 为 CCS 变量创建占位符（全 0 值）
- **预期覆盖率**: 91.4% (74/81)

### 阶段 3: 模型限制变量（目标：100%）
- [ ] Off-road Construction 占位符
- [ ] Feedstock Steel Coke 占位符
- [ ] Oil Liquids 从其他变量推算
- **预期覆盖率**: 100% (81/81)

---

## 开始实施！
