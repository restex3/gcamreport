# GCAM2GAINS 映射扩展方案（修订版）

**日期**: 2026-04-18
**验证数据库**: China60Ref (E:/GCAM/GCAM-China_v7.1/output/China60Ref)

---

## ⚠️ 关键发现：农业数据的空间分辨率问题

### 数据结构验证结果

通过对 China60Ref 数据库的检查，发现：

| 查询 | 省级数据 | 国家级数据 | 说明 |
|------|---------|-----------|------|
| `ag production by crop type` | ❌ 无 | ✅ 有 | **农业生产只有国家级数据** |
| `demand balances by crop commodity` | ✅ 有 | ✅ 有 | 农产品需求有省级数据 |
| `land allocation by crop and water source` | ❌ 无 | ✅ 有 | 土地分配只有国家级数据 |

### 核心挑战

**GCAM-China 的农业生产数据是国家级的，需要分配到各省才能用于 GAINS 映射。**

---

## 🎯 解决方案

### 方案 A：使用分配系数（推荐）

基于历史数据或其他数据源，将国家级农业生产分配到各省。

#### 分配方法选项

1. **基于土地面积分配**
   - 使用 `land allocation by crop and water source` 的省级数据
   - 但该查询也是国家级的，不可行

2. **基于农产品需求分配** ✅ **推荐**
   - 使用 `demand balances by crop commodity` 的省级数据
   - 假设：生产与需求成比例
   - 公式：`省级生产 = 国家级生产 × (省级需求 / 全国需求)`

3. **基于外部统计数据分配**
   - 使用国家统计局的省级农业生产数据
   - 计算历史分配系数
   - 应用到 GCAM 未来情景

4. **基于人口分配**
   - 简单但不精确
   - 仅作为最后的备选方案

### 方案 B：仅使用国家级数据

如果 GAINS 可以接受国家级数据，则直接映射，不进行省级分配。

---

## 📊 推荐实施方案（方案 A-2）

### Step 1: 提取国家级农业生产数据

```r
# 从 China60Ref 提取国家级农业生产
ag_production_national <- rgcam::getQuery(prj, "ag production by crop type", "China60ref") %>%
  filter(region == "China")

# 作物类型：
# Corn, Rice, Wheat, OtherGrain (谷物)
# Soybean, OilCrop, OilPalm (油料作物)
# SugarCrop (糖料作物)
# RootTuber, Vegetables, Fruits, Legumes, NutsSeeds, MiscCrop, FiberCrop (其他作物)
# FodderGrass, FodderHerb (饲料作物)
# biomass (能源作物)
# Forest (林业)
```

### Step 2: 提取省级农产品需求数据

```r
# 提取省级需求数据
ag_demand_provincial <- rgcam::getQuery(prj, "demand balances by crop commodity", "China60ref") %>%
  filter(region %in% c("China", provinces))

# 计算各省需求占全国需求的比例
demand_shares <- ag_demand_provincial %>%
  group_by(sector, input, year) %>%
  mutate(
    national_demand = sum(value[region == "China"]),
    provincial_share = value / national_demand
  ) %>%
  filter(region != "China")
```

### Step 3: 分配国家级生产到各省

```r
# 建立作物-需求的映射关系
crop_demand_mapping <- data.frame(
  crop = c("Corn", "Rice", "Wheat", "Soybean", "OilCrop", ...),
  demand_sector = c("FoodDemand_Staples", "FoodDemand_Staples", ...)
)

# 分配生产数据
ag_production_provincial <- ag_production_national %>%
  left_join(crop_demand_mapping, by = c("sector" = "crop")) %>%
  left_join(demand_shares, by = c("demand_sector" = "sector", "year")) %>%
  mutate(provincial_production = value * provincial_share)
```

### Step 4: 映射到 GAINS 格式

```r
# 转换为 GAINS 格式
gains_ag_production <- ag_production_provincial %>%
  left_join(gcam2gains_crop_mapping, by = c("sector" = "gcam_commodity")) %>%
  mutate(
    gains_value = provincial_production * conversion_factor,
    gains_unit = gains_unit
  ) %>%
  select(region, gains_sector, gains_activity, year, gains_value, gains_unit)
```

---

## 📁 更新后的映射文件结构

### 1. 农业部门映射（3+1个文件）

#### 1.1 农作物生产映射 (`gcam2gains_ag_crop_production.csv`)

```csv
# GCAM to GAINS Agricultural Crop Production Mapping
gcam_commodity,demand_sector,gains_sector,gains_activity,gains_unit,conversion_factor,notes
Corn,FoodDemand_Staples,AGRICULTURE,CROP_CEREALS_MAIZE,kt,1000,Use FoodDemand_Staples for allocation
Rice,FoodDemand_Staples,AGRICULTURE,CROP_CEREALS_RICE,kt,1000,Use FoodDemand_Staples for allocation
Wheat,FoodDemand_Staples,AGRICULTURE,CROP_CEREALS_WHEAT,kt,1000,Use FoodDemand_Staples for allocation
OtherGrain,FoodDemand_Staples,AGRICULTURE,CROP_CEREALS_OTHER,kt,1000,Use FoodDemand_Staples for allocation
Soybean,FoodDemand_NonStaples,AGRICULTURE,CROP_OILSEEDS_SOYBEAN,kt,1000,Use FoodDemand_NonStaples for allocation
OilCrop,FoodDemand_NonStaples,AGRICULTURE,CROP_OILSEEDS_OTHER,kt,1000,Use FoodDemand_NonStaples for allocation
SugarCrop,FoodDemand_NonStaples,AGRICULTURE,CROP_SUGAR,kt,1000,Use FoodDemand_NonStaples for allocation
RootTuber,FoodDemand_Staples,AGRICULTURE,CROP_ROOTS_TUBERS,kt,1000,Use FoodDemand_Staples for allocation
Vegetables,FoodDemand_NonStaples,AGRICULTURE,CROP_VEGETABLES,kt,1000,Use FoodDemand_NonStaples for allocation
Fruits,FoodDemand_NonStaples,AGRICULTURE,CROP_FRUITS,kt,1000,Use FoodDemand_NonStaples for allocation
biomass,regional biomass,AGRICULTURE,CROP_ENERGY,kt,1000,Use regional biomass demand for allocation
```

#### 1.2 畜牧业生产映射 (`gcam2gains_ag_livestock_production.csv`)

**注意**: 畜牧业数据也需要检查是否有省级数据

```csv
# GCAM to GAINS Livestock Production Mapping
gcam_commodity,demand_sector,gains_sector,gains_activity,gains_unit,conversion_factor,allocation_method
Beef,FoodDemand_NonStaples,AGRICULTURE,LIVESTOCK_CATTLE_MEAT,kt,1000,Use regional beef demand
Dairy,FoodDemand_NonStaples,AGRICULTURE,LIVESTOCK_CATTLE_DAIRY,kt,1000,Use regional dairy demand
Pork,FoodDemand_NonStaples,AGRICULTURE,LIVESTOCK_PIGS,kt,1000,Use regional pork demand
Poultry,FoodDemand_NonStaples,AGRICULTURE,LIVESTOCK_POULTRY,kt,1000,Use regional poultry demand
SheepGoat,FoodDemand_NonStaples,AGRICULTURE,LIVESTOCK_SHEEP_GOAT,kt,1000,Use regional sheepgoat demand
```

#### 1.3 省级分配系数文件 (`provincial_allocation_coefficients.csv`)

**新增文件**：存储计算好的分配系数

```csv
# Provincial Allocation Coefficients for Agriculture
province,crop_type,demand_sector,year,allocation_share,data_source
AH,Corn,FoodDemand_Staples,2020,0.045,Calculated from GCAM demand
AH,Corn,FoodDemand_Staples,2025,0.046,Calculated from GCAM demand
BJ,Corn,FoodDemand_Staples,2020,0.012,Calculated from GCAM demand
...
```

#### 1.4 农业能源消费映射 (`gcam2gains_ag_energy.csv`)

**需要检查**: 农业能源消费是否有省级数据

---

## 🔧 实施步骤（修订版）

### Phase 0: 数据可用性验证（1周）

1. **检查所有农业相关查询的空间分辨率**
   ```r
   # 需要检查的查询
   - ag production by crop type (已确认：国家级)
   - demand balances by crop commodity (已确认：省级)
   - livestock production (待检查)
   - agricultural energy use (待检查)
   ```

2. **验证分配方法的可行性**
   - 测试需求数据是否完整覆盖所有作物
   - 检查是否存在需求为零但生产不为零的情况
   - 评估分配误差

3. **准备外部验证数据**
   - 收集国家统计局省级农业生产数据
   - 用于验证分配结果的合理性

### Phase 1: 开发分配算法（2周）

1. **创建分配函数**
   ```r
   allocate_national_to_provincial <- function(
     national_data,
     provincial_demand,
     crop_demand_mapping
   ) {
     # 实现分配逻辑
   }
   ```

2. **处理特殊情况**
   - 需求为零的省份
   - 新增作物（历史期没有需求）
   - 能源作物的特殊处理

3. **验证分配结果**
   - 确保省级总和等于国家级
   - 检查分配系数的合理性
   - 与历史统计数据对比

### Phase 2: 创建映射文件（1周）

1. **农业映射文件** (4个)
   - 作物生产映射（含分配方法）
   - 畜牧业生产映射（含分配方法）
   - 分配系数文件
   - 农业能源映射

2. **工业映射文件** (5个)
   - 保持原方案不变

### Phase 3: 开发转换函数（2-3周）

```r
# 在 R/functions_gains.R 中添加

get_gains_ag_crop_production_provincial <- function(prj, scenario, mapping) {
  # 1. 提取国家级生产数据
  national_prod <- get_national_ag_production(prj, scenario)

  # 2. 提取省级需求数据
  provincial_demand <- get_provincial_ag_demand(prj, scenario)

  # 3. 计算分配系数
  allocation_coef <- calculate_allocation_coefficients(
    provincial_demand, mapping
  )

  # 4. 分配到各省
  provincial_prod <- allocate_national_to_provincial(
    national_prod, allocation_coef
  )

  # 5. 转换为 GAINS 格式
  gains_format <- convert_to_gains_format(provincial_prod, mapping)

  return(gains_format)
}
```

### Phase 4: 验证和测试（2周）

1. **单元测试**
   - 测试分配算法
   - 验证质量守恒（省级总和 = 国家级）
   - 检查单位转换

2. **与外部数据对比**
   - 历史期与统计局数据对比
   - 评估分配误差范围
   - 识别异常值

3. **完整工作流测试**
   - 使用 China60Ref 运行完整流程
   - 生成 GAINS 输入文件
   - 文档编写

---

## ⏱️ 更新后的时间估算

| 阶段 | 工作内容 | 时间 |
|------|---------|------|
| Phase 0 | 数据可用性验证 | 1周 |
| Phase 1 | 开发分配算法 | 2周 |
| Phase 2 | 创建映射文件 | 1周 |
| Phase 3 | 开发转换函数 | 2-3周 |
| Phase 4 | 验证和测试 | 2周 |
| **总计** | | **8-9周** |

---

## 🔍 关键风险和缓解措施

### 风险 1: 分配方法不准确

**缓解措施**:
- 使用多种分配方法进行对比
- 与历史统计数据验证
- 提供不确定性估计

### 风险 2: 需求数据不完整

**缓解措施**:
- 检查所有作物的需求数据覆盖率
- 对缺失数据使用人口或GDP分配
- 记录所有假设和限制

### 风险 3: 畜牧业数据也是国家级

**缓解措施**:
- 立即检查畜牧业数据结构
- 如果是国家级，使用相同的分配方法
- 考虑使用饲料需求作为分配依据

---

## 📝 下一步行动（优先级排序）

### 立即执行（本周）

1. ✅ **检查农业生产数据结构** - 已完成
2. ⏭️ **检查畜牧业生产数据结构**
   ```r
   # 运行检查脚本
   source("dev_scripts/check_livestock_structure.R")
   ```

3. ⏭️ **检查农业能源消费数据结构**
   ```r
   # 检查 agricultural energy use 查询
   ```

4. ⏭️ **测试需求数据的完整性**
   - 验证所有作物都有对应的需求数据
   - 检查时间序列的连续性

### 下周执行

5. **开发分配算法原型**
   - 实现基于需求的分配方法
   - 测试 2-3 种作物

6. **验证分配结果**
   - 与统计局数据对比
   - 评估误差范围

7. **决定最终方案**
   - 基于验证结果选择分配方法
   - 确定是否需要外部数据

---

## 📦 更新后的交付物

### 1. 映射文件（9个CSV文件）
- 农业部门：4个（含分配系数文件）
- 工业部门：5个

### 2. R 代码
- 分配算法（`R/allocation_functions.R`）
- GAINS转换函数（`R/functions_gains.R`）
- 主导出函数（`R/export_gains.R`）
- 验证脚本（`dev_scripts/validate_allocation.R`）

### 3. 文档
- 分配方法说明（`docs/Provincial_Allocation_Method.md`）
- 映射规范（`docs/GCAM2GAINS_Mapping_Specification.md`）
- 验证报告（`docs/Allocation_Validation_Report.md`）

### 4. 验证数据
- 分配系数文件（CSV）
- 验证对比结果（CSV）
- 误差分析报告（PDF）

---

**关键结论**: GCAM-China 的农业生产数据是国家级的，必须开发省级分配算法才能用于 GAINS 映射。推荐使用基于省级需求数据的分配方法。

**验证数据库**: 所有开发和测试都应使用 China60Ref 数据库进行验证。

**最后更新**: 2026-04-18
