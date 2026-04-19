# GCAM-China 农业和畜牧业数据结构验证报告

**验证日期**: 2026-04-18
**数据库**: China60Ref (E:/GCAM/GCAM-China_v7.1/output/China60Ref)

---

## 📊 数据结构验证结果汇总

| 数据类型 | 查询名称 | 省级数据 | 国家级数据 | 区域数 | 备注 |
|---------|---------|---------|-----------|--------|------|
| **农作物生产** | `ag production by crop type` | ❌ 无 | ✅ 有 | 32 | 20种作物，仅全球区域 |
| **农作物需求** | `demand balances by crop commodity` | ✅ 有 | ✅ 有 | 63 | 31个省份 + 全球区域 |
| **土地分配** | `land allocation by crop and water source` | ❌ 无 | ✅ 有 | 32 | 仅全球区域 |
| **畜牧业生产** | `meat and dairy production by type` | ❌ 无 | ✅ 有 | 32 | 5种畜产品，仅全球区域 |
| **畜牧业需求** | `demand balances by meat and dairy commodity` | ❌ 无 | ✅ 有 | 32 | 仅全球区域 |

---

## 🔍 详细发现

### 1. 农作物生产 (Crop Production)

**查询**: `ag production by crop type`

- **空间分辨率**: 仅国家级（China）
- **作物类型** (20种):
  - 谷物: Corn, Rice, Wheat, OtherGrain
  - 油料: Soybean, OilCrop, OilPalm
  - 糖料: SugarCrop
  - 其他: RootTuber, Vegetables, Fruits, Legumes, NutsSeeds, MiscCrop, FiberCrop
  - 饲料: FodderGrass, FodderHerb, Pasture
  - 能源: biomass
  - 林业: Forest

**可用于分配的数据**:
- ✅ `demand balances by crop commodity` 有省级数据（63个区域，包含31个省）

---

### 2. 畜牧业生产 (Livestock Production)

**查询**: `meat and dairy production by type`

- **空间分辨率**: 仅国家级（China）
- **畜产品类型** (5种):
  - Beef (牛肉)
  - Dairy (乳制品)
  - Pork (猪肉)
  - Poultry (禽肉)
  - SheepGoat (羊肉)

**可用于分配的数据**:
- ❌ `demand balances by meat and dairy commodity` **也是国家级**（32个区域，无省级）
- ⚠️ **问题**: 畜牧业需求数据也没有省级分辨率

---

### 3. 农作物需求 (Crop Demand)

**查询**: `demand balances by crop commodity`

- **空间分辨率**: ✅ 省级 + 国家级
- **区域数**: 63个（31个省 + 32个全球区域）
- **需求类型**:
  - FoodDemand_Staples (主食需求)
  - FoodDemand_NonStaples (非主食需求)
  - FeedCrops (饲料需求)
  - NonFoodDemand_Crops (非食品需求)
  - regional biomass (生物质能源需求)

---

## ⚠️ 关键挑战

### 挑战 1: 农作物生产需要分配

**问题**: 国家级生产 → 需要分配到31个省

**解决方案**: ✅ 使用省级作物需求数据进行分配
```
省级生产 = 国家级生产 × (省级需求 / 全国需求)
```

### 挑战 2: 畜牧业生产和需求都是国家级

**问题**:
- 畜牧业生产：国家级
- 畜牧业需求：也是国家级
- **无法使用需求数据进行分配**

**可能的解决方案**:

#### 方案 A: 使用饲料需求作为代理 ✅ **推荐**
```r
# 假设：畜牧业生产与饲料需求成比例
# FeedCrops 需求有省级数据
省级畜牧业生产 = 国家级畜牧业生产 × (省级饲料需求 / 全国饲料需求)
```

#### 方案 B: 使用外部统计数据
- 使用国家统计局的省级畜牧业生产数据
- 计算历史分配系数
- 应用到 GCAM 未来情景

#### 方案 C: 使用人口分配
- 简单但不精确
- 仅作为最后备选

#### 方案 D: 仅提供国家级数据
- 如果 GAINS 可以接受国家级畜牧业数据
- 最简单但信息损失最大

---

## 📋 GCAM2GAINS 映射策略（最终版）

### 农作物部门

| 数据类型 | GCAM 分辨率 | 分配方法 | 分配依据 |
|---------|------------|---------|---------|
| 作物生产 | 国家级 | 基于需求分配 | `demand balances by crop commodity` (省级) |
| 作物需求 | 省级 | 直接使用 | 无需分配 |

**实施步骤**:
1. 提取国家级作物生产（20种作物）
2. 提取省级作物需求（31个省）
3. 计算各省需求占全国比例
4. 分配生产到各省
5. 映射到 GAINS 格式

---

### 畜牧业部门

| 数据类型 | GCAM 分辨率 | 分配方法 | 分配依据 |
|---------|------------|---------|---------|
| 畜牧业生产 | 国家级 | 基于饲料需求分配 | `demand balances by crop commodity` - FeedCrops (省级) |
| 畜牧业需求 | 国家级 | 基于饲料需求分配 | 同上 |

**实施步骤**:
1. 提取国家级畜牧业生产（5种畜产品）
2. 提取省级饲料作物需求（FeedCrops）
3. 计算各省饲料需求占全国比例
4. 分配畜牧业生产到各省
5. 映射到 GAINS 格式

**假设**:
- 畜牧业生产与饲料消费成正比
- 各省饲料需求反映了畜牧业规模

---

## 🔧 更新后的实施方案

### Phase 0: 数据验证（已完成）✅

- ✅ 农作物生产：国家级
- ✅ 农作物需求：省级
- ✅ 畜牧业生产：国家级
- ✅ 畜牧业需求：国家级
- ✅ 饲料需求：省级（可用于畜牧业分配）

### Phase 1: 开发分配算法（2周）

#### 1.1 农作物分配函数
```r
allocate_crop_production <- function(national_prod, provincial_demand, crop_mapping) {
  # 基于省级作物需求分配国家级生产
}
```

#### 1.2 畜牧业分配函数
```r
allocate_livestock_production <- function(national_prod, provincial_feed_demand, livestock_feed_mapping) {
  # 基于省级饲料需求分配国家级畜牧业生产
  # 需要建立畜产品-饲料类型的映射关系
}
```

#### 1.3 验证函数
```r
validate_allocation <- function(allocated_data, national_data) {
  # 确保省级总和 = 国家级
  # 检查分配系数的合理性
}
```

### Phase 2: 创建映射文件（1周）

需要创建的映射文件：

1. **`gcam2gains_crop_production.csv`**
   - 作物类型 → GAINS 部门
   - 作物类型 → 需求部门（用于分配）

2. **`gcam2gains_livestock_production.csv`**
   - 畜产品类型 → GAINS 部门
   - 畜产品类型 → 饲料类型（用于分配）

3. **`livestock_feed_mapping.csv`** (新增)
   - 畜产品 → 主要饲料类型
   - 用于畜牧业分配

4. **`provincial_allocation_coefficients.csv`**
   - 存储计算好的分配系数

### Phase 3: 开发转换函数（2-3周）

### Phase 4: 验证测试（2周）

---

## 📊 畜产品-饲料映射关系（建议）

| 畜产品 | 主要饲料类型 | 备注 |
|--------|------------|------|
| Beef | Corn, FodderGrass, FodderHerb | 牛主要消费粗饲料和谷物 |
| Dairy | Corn, FodderGrass, FodderHerb | 奶牛饲料结构类似肉牛 |
| Pork | Corn, Soybean | 猪主要消费谷物和豆粕 |
| Poultry | Corn, Soybean | 禽类主要消费谷物和豆粕 |
| SheepGoat | FodderGrass, FodderHerb | 羊主要消费粗饲料 |

**分配权重建议**:
- 反刍动物（Beef, Dairy, SheepGoat）: 70% 粗饲料 + 30% 谷物
- 单胃动物（Pork, Poultry）: 80% 谷物 + 20% 豆粕

---

## ⏱️ 最终时间估算

| 阶段 | 工作内容 | 时间 |
|------|---------|------|
| Phase 0 | 数据验证 | ✅ 已完成 |
| Phase 1 | 开发分配算法（作物+畜牧业） | 2周 |
| Phase 2 | 创建映射文件（10个） | 1周 |
| Phase 3 | 开发转换函数 | 2-3周 |
| Phase 4 | 验证测试 | 2周 |
| **总计** | | **7-8周** |

---

## 🎯 下一步行动

### 立即执行

1. ✅ **数据结构验证** - 已完成
2. ⏭️ **设计畜产品-饲料映射关系**
   - 确定各畜产品的主要饲料类型
   - 设定分配权重

3. ⏭️ **开发作物分配算法原型**
   - 测试 2-3 种作物
   - 验证分配结果

4. ⏭️ **开发畜牧业分配算法原型**
   - 测试基于饲料需求的分配方法
   - 与统计数据对比验证

### 下周执行

5. **完善分配算法**
6. **创建所有映射文件**
7. **集成到主工作流**

---

## 📝 关键结论

1. **农作物**: 可以使用省级需求数据进行分配 ✅
2. **畜牧业**: 需要使用省级饲料需求作为代理进行分配 ⚠️
3. **验证数据库**: 所有开发使用 China60Ref
4. **总工作量**: 7-8周

**最大风险**: 基于饲料需求分配畜牧业生产的准确性需要验证

**缓解措施**:
- 与统计局数据对比
- 提供不确定性估计
- 考虑使用外部数据校准

---

**验证完成日期**: 2026-04-18
**下次更新**: 分配算法原型完成后
