# GCAM2GAINS 映射扩展方案

**日期**: 2026-04-18
**目标**: 扩展 GCAM2GAINS 映射，覆盖农业和其他工业产品部门

---

## 📋 现状分析

### 已完成的映射（能源部分）

根据现有文件，已经实现了：

1. **Primary Energy** - `primary_energy_map.csv`
   - 化石燃料（煤、油、气）
   - 生物质能源
   - 核能
   - 可再生能源（水电、风电、太阳能、地热）

2. **Final Energy** - `final_energy_map_gcamchina.csv`
   - 工业部门（水泥、化工、钢铁、有色金属）
   - 商业部门
   - 居民部门
   - 交通部门 - `transport_final_en_map_gcamchina.csv`

### 缺失的映射（需要扩展）

1. **农业部门**
   - 农作物生产
   - 畜牧业生产
   - 农业需求（食品、饲料、生物能源）

2. **其他工业产品**
   - 化工产品（氨、化肥）
   - 非金属矿物（水泥、铝）
   - 纸浆和纸张
   - 其他工业产品

---

## 🎯 GCAM2GAINS 映射方案

### 方案概述

GAINS（Greenhouse gas - Air pollution Interactions and Synergies）模型需要以下类型的数据：

1. **活动水平数据** (Activity Data)
   - 农业生产量
   - 工业产品产量
   - 能源消费

2. **排放因子相关数据**
   - 按技术/工艺分类的生产
   - 按燃料类型分类的能源消费

---

## 📊 建议的映射文件结构

### 1. 农业部门映射

#### 1.1 农作物生产映射 (`gcam2gains_ag_crop_production.csv`)

```csv
# GCAM to GAINS Agricultural Crop Production Mapping
gcam_sector,gcam_commodity,gains_sector,gains_activity,gains_unit,conversion_factor,notes
Agricultural Production,Corn,AGRICULTURE,CROP_CEREALS_MAIZE,kt,1000,Corn/Maize production
Agricultural Production,Rice,AGRICULTURE,CROP_CEREALS_RICE,kt,1000,Rice production (paddy)
Agricultural Production,Wheat,AGRICULTURE,CROP_CEREALS_WHEAT,kt,1000,Wheat production
Agricultural Production,OtherGrain,AGRICULTURE,CROP_CEREALS_OTHER,kt,1000,Other cereals
Agricultural Production,Soybean,AGRICULTURE,CROP_OILSEEDS_SOYBEAN,kt,1000,Soybean production
Agricultural Production,OilCrop,AGRICULTURE,CROP_OILSEEDS_OTHER,kt,1000,Other oil crops
Agricultural Production,OilPalm,AGRICULTURE,CROP_OILSEEDS_PALM,kt,1000,Oil palm production
Agricultural Production,SugarCrop,AGRICULTURE,CROP_SUGAR,kt,1000,Sugar crops
Agricultural Production,RootTuber,AGRICULTURE,CROP_ROOTS_TUBERS,kt,1000,Root and tuber crops
Agricultural Production,Vegetables,AGRICULTURE,CROP_VEGETABLES,kt,1000,Vegetables
Agricultural Production,Fruits,AGRICULTURE,CROP_FRUITS,kt,1000,Fruits
Agricultural Production,FiberCrop,AGRICULTURE,CROP_FIBER,kt,1000,Fiber crops
Agricultural Production,biomass,AGRICULTURE,CROP_ENERGY,kt,1000,Energy crops
```

#### 1.2 畜牧业生产映射 (`gcam2gains_ag_livestock_production.csv`)

```csv
# GCAM to GAINS Livestock Production Mapping
gcam_sector,gcam_commodity,gains_sector,gains_activity,gains_unit,conversion_factor,notes
Agricultural Production,Beef,AGRICULTURE,LIVESTOCK_CATTLE_MEAT,kt,1000,Beef production
Agricultural Production,Dairy,AGRICULTURE,LIVESTOCK_CATTLE_DAIRY,kt,1000,Dairy production
Agricultural Production,Pork,AGRICULTURE,LIVESTOCK_PIGS,kt,1000,Pork production
Agricultural Production,Poultry,AGRICULTURE,LIVESTOCK_POULTRY,kt,1000,Poultry production
Agricultural Production,SheepGoat,AGRICULTURE,LIVESTOCK_SHEEP_GOAT,kt,1000,Sheep and goat production
```

#### 1.3 农业能源消费映射 (`gcam2gains_ag_energy.csv`)

```csv
# GCAM to GAINS Agricultural Energy Consumption Mapping
gcam_sector,gcam_fuel,gains_sector,gains_fuel,gains_activity,gains_unit,conversion_factor
agricultural energy use,electricity,AGRICULTURE,ELECTRICITY,ENERGY_USE,PJ,1
agricultural energy use,refined liquids,AGRICULTURE,DIESEL,ENERGY_USE,PJ,1
agricultural energy use,gas,AGRICULTURE,NATURAL_GAS,ENERGY_USE,PJ,1
agricultural energy use,coal,AGRICULTURE,COAL,ENERGY_USE,PJ,1
```

---

### 2. 工业产品映射

#### 2.1 化工产品映射 (`gcam2gains_chemical_production.csv`)

```csv
# GCAM to GAINS Chemical Production Mapping
gcam_sector,gcam_product,gains_sector,gains_activity,gains_unit,conversion_factor,notes
Production|Chemicals,Ammonia,INDUSTRY_CHEMICALS,AMMONIA_PRODUCTION,kt NH3,1000,Ammonia production
Production|Chemicals,Nitrogen Fertilizer,INDUSTRY_CHEMICALS,FERTILIZER_N,kt N,1000,Nitrogen fertilizer
chemical,High-Value Chemicals,INDUSTRY_CHEMICALS,HVC_PRODUCTION,PJ,1,High-value chemicals (energy basis)
chemical feedstocks,coal,INDUSTRY_CHEMICALS,FEEDSTOCK_COAL,PJ,1,Coal feedstock
chemical feedstocks,gas,INDUSTRY_CHEMICALS,FEEDSTOCK_GAS,PJ,1,Gas feedstock
chemical feedstocks,refined liquids,INDUSTRY_CHEMICALS,FEEDSTOCK_OIL,PJ,1,Oil feedstock
```

#### 2.2 非金属矿物映射 (`gcam2gains_nonmetallic_minerals.csv`)

```csv
# GCAM to GAINS Non-Metallic Minerals Mapping
gcam_sector,gcam_product,gains_sector,gains_activity,gains_unit,conversion_factor,notes
Production|Non-Metallic Minerals,Cement,INDUSTRY_CEMENT,CEMENT_PRODUCTION,Mt,1,Cement production
cement,electricity,INDUSTRY_CEMENT,ELECTRICITY,PJ,1,Cement electricity use
process heat cement,coal,INDUSTRY_CEMENT,COAL,PJ,1,Cement coal use
process heat cement,gas,INDUSTRY_CEMENT,NATURAL_GAS,PJ,1,Cement gas use
process heat cement,refined liquids,INDUSTRY_CEMENT,OIL,PJ,1,Cement oil use
process heat cement,hydrogen,INDUSTRY_CEMENT,HYDROGEN,PJ,1,Cement hydrogen use
```

#### 2.3 钢铁产品映射（扩展）(`gcam2gains_iron_steel.csv`)

```csv
# GCAM to GAINS Iron and Steel Mapping (Extended)
gcam_sector,gcam_subsector,gcam_technology,gains_sector,gains_technology,gains_activity,gains_unit,conversion_factor
iron and steel,BLASTFUR,BLASTFUR,INDUSTRY_STEEL,BF_BOF,STEEL_PRODUCTION,Mt,1
iron and steel,BLASTFUR,BLASTFUR CCS,INDUSTRY_STEEL,BF_BOF_CCS,STEEL_PRODUCTION,Mt,1
iron and steel,BLASTFUR,BLASTFUR with hydrogen,INDUSTRY_STEEL,BF_BOF_H2,STEEL_PRODUCTION,Mt,1
iron and steel,BLASTFUR,Biomass-based,INDUSTRY_STEEL,BF_BOF_BIOMASS,STEEL_PRODUCTION,Mt,1
iron and steel,EAF with scrap,EAF with scrap,INDUSTRY_STEEL,EAF_SCRAP,STEEL_PRODUCTION,Mt,1
iron and steel,EAF with DRI,EAF with DRI,INDUSTRY_STEEL,EAF_DRI,STEEL_PRODUCTION,Mt,1
iron and steel,EAF with DRI,EAF with DRI CCS,INDUSTRY_STEEL,EAF_DRI_CCS,STEEL_PRODUCTION,Mt,1
iron and steel,EAF with DRI,Hydrogen-based DRI,INDUSTRY_STEEL,EAF_H2DRI,STEEL_PRODUCTION,Mt,1
```

#### 2.4 有色金属映射 (`gcam2gains_nonferrous_metals.csv`)

```csv
# GCAM to GAINS Non-Ferrous Metals Mapping
gcam_sector,gcam_product,gains_sector,gains_activity,gains_unit,conversion_factor,notes
Production|Non-Ferrous Metals,Aluminum Oxide,INDUSTRY_ALUMINUM,ALUMINA_PRODUCTION,Mt,1,Alumina production
Production|Non-Ferrous Metals,Aluminum,INDUSTRY_ALUMINUM,ALUMINUM_PRODUCTION,Mt,1,Aluminum production
alumina,coal,INDUSTRY_ALUMINUM,COAL,PJ,1,Alumina coal use
alumina,gas,INDUSTRY_ALUMINUM,NATURAL_GAS,PJ,1,Alumina gas use
aluminum,electricity,INDUSTRY_ALUMINUM,ELECTRICITY,PJ,1,Aluminum electricity use
```

#### 2.5 纸浆和纸张映射 (`gcam2gains_pulp_paper.csv`)

```csv
# GCAM to GAINS Pulp and Paper Mapping
gcam_sector,gcam_product,gains_sector,gains_activity,gains_unit,conversion_factor,notes
Production|Pulp and Paper,Paper,INDUSTRY_PAPER,PAPER_PRODUCTION,Mt,1,Paper production
paper,electricity,INDUSTRY_PAPER,ELECTRICITY,PJ,1,Paper electricity use
process heat paper,coal,INDUSTRY_PAPER,COAL,PJ,1,Paper coal use
process heat paper,gas,INDUSTRY_PAPER,NATURAL_GAS,PJ,1,Paper gas use
process heat paper,biomass,INDUSTRY_PAPER,BIOMASS,PJ,1,Paper biomass use
waste biomass for paper,biomass,INDUSTRY_PAPER,WASTE_BIOMASS,PJ,1,Waste biomass for paper
```

---

## 🔧 实施步骤

### Phase 1: 创建映射文件（1-2周）

1. **创建农业映射文件**
   - `gcam2gains_ag_crop_production.csv`
   - `gcam2gains_ag_livestock_production.csv`
   - `gcam2gains_ag_energy.csv`

2. **创建工业产品映射文件**
   - `gcam2gains_chemical_production.csv`
   - `gcam2gains_nonmetallic_minerals.csv`
   - `gcam2gains_iron_steel.csv`
   - `gcam2gains_nonferrous_metals.csv`
   - `gcam2gains_pulp_paper.csv`

3. **创建主映射索引文件**
   - `gcam2gains_master_mapping.csv` - 所有映射的索引

### Phase 2: 开发转换函数（2-3周）

在 `R/functions.R` 中添加新函数：

```r
# 农业部门转换
get_gains_ag_crop_production <- function(data, mapping) {
  # 转换 GCAM 农作物生产数据到 GAINS 格式
}

get_gains_ag_livestock_production <- function(data, mapping) {
  # 转换 GCAM 畜牧业生产数据到 GAINS 格式
}

get_gains_ag_energy <- function(data, mapping) {
  # 转换 GCAM 农业能源消费到 GAINS 格式
}

# 工业产品转换
get_gains_chemical_production <- function(data, mapping) {
  # 转换 GCAM 化工产品数据到 GAINS 格式
}

get_gains_industrial_production <- function(data, mapping) {
  # 通用工业产品转换函数
}
```

### Phase 3: 集成到主工作流（1周）

在 `R/main.R` 中添加 GAINS 导出功能：

```r
export_to_gains <- function(gcam_data, output_path, sectors = "all") {
  # 主导出函数
  # sectors: c("energy", "agriculture", "industry", "all")

  gains_data <- list()

  if (sectors %in% c("energy", "all")) {
    gains_data$energy <- convert_energy_to_gains(gcam_data)
  }

  if (sectors %in% c("agriculture", "all")) {
    gains_data$agriculture <- convert_agriculture_to_gains(gcam_data)
  }

  if (sectors %in% c("industry", "all")) {
    gains_data$industry <- convert_industry_to_gains(gcam_data)
  }

  # 写入 GAINS 格式文件
  write_gains_format(gains_data, output_path)
}
```

### Phase 4: 验证和测试（1-2周）

1. **单元测试**
   - 测试每个转换函数
   - 验证单位转换
   - 检查数据完整性

2. **集成测试**
   - 使用 China60Ref 数据库测试完整工作流
   - 与 GAINS 团队确认输出格式
   - 验证数据合理性

3. **文档编写**
   - 映射文档
   - 使用教程
   - API 文档

---

## 📝 映射设计原则

### 1. 部门对应

| GCAM 部门 | GAINS 部门 |
|-----------|-----------|
| Agricultural Production | AGRICULTURE |
| Final Energy\|Industry | INDUSTRY_* |
| Production\|Chemicals | INDUSTRY_CHEMICALS |
| Production\|Steel | INDUSTRY_STEEL |
| Production\|Cement | INDUSTRY_CEMENT |

### 2. 单位转换

| GCAM 单位 | GAINS 单位 | 转换因子 |
|-----------|-----------|---------|
| Mt | kt | 1000 |
| EJ | PJ | 1000 |
| Mt NH3 | kt NH3 | 1000 |
| Mt N | kt N | 1000 |

### 3. 时间分辨率

- GCAM: 5年间隔（2020, 2025, 2030...）
- GAINS: 需要年度数据
- **解决方案**: 线性插值或保持5年间隔

### 4. 空间分辨率

- GCAM-China: 31个省份
- GAINS: 可能需要不同的区域划分
- **解决方案**: 提供省级数据，由 GAINS 团队聚合

---

## 🎯 优先级建议

### 高优先级（立即实施）

1. **农作物生产映射** - GAINS 排放计算的基础
2. **畜牧业生产映射** - 甲烷排放的关键
3. **化工产品映射** - 工业排放的重要来源

### 中优先级（后续实施）

4. **钢铁技术映射** - 已有基础，需扩展
5. **水泥生产映射** - 重要的 CO2 排放源
6. **有色金属映射** - 能源密集型产业

### 低优先级（可选）

7. **纸浆和纸张映射** - 相对较小的排放源
8. **其他工业产品** - 按需添加

---

## 📦 交付物

### 1. 映射文件（CSV格式）
- 8个部门映射文件
- 1个主索引文件

### 2. R 代码
- 转换函数（`R/functions_gains.R`）
- 主导出函数（`R/export_gains.R`）
- 单元测试（`tests/testthat/test-gains.R`）

### 3. 文档
- 映射规范文档（`docs/GCAM2GAINS_Mapping_Specification.md`）
- 使用教程（`docs/GCAM2GAINS_Tutorial.md`）
- API 参考（`man/export_to_gains.Rd`）

### 4. 示例
- 示例脚本（`examples/gcam2gains_example.R`）
- 示例输出（`examples/gains_output_sample/`）

---

## ⏱️ 时间估算

| 阶段 | 工作量 | 时间 |
|------|--------|------|
| Phase 1: 映射文件 | 创建8个映射文件 | 1-2周 |
| Phase 2: 转换函数 | 开发和调试 | 2-3周 |
| Phase 3: 集成 | 主工作流集成 | 1周 |
| Phase 4: 验证测试 | 测试和文档 | 1-2周 |
| **总计** | | **5-8周** |

---

## 🔍 关键考虑因素

### 1. 与 GAINS 团队协调
- 确认 GAINS 所需的具体格式
- 确认部门和活动分类
- 确认单位和转换因子

### 2. 数据可用性
- 检查 GCAM-China 是否输出所有需要的变量
- 确认查询文件是否包含必要的查询
- 识别数据缺口

### 3. 质量控制
- 实施数据验证检查
- 与历史数据对比
- 与其他数据源交叉验证

### 4. 可维护性
- 模块化设计
- 清晰的文档
- 版本控制

---

## 📞 下一步行动

1. **与 GAINS 团队会议** - 确认需求和格式
2. **数据可用性检查** - 验证 GCAM-China 输出
3. **创建第一个映射文件** - 从农作物生产开始
4. **开发原型转换函数** - 验证可行性
5. **迭代改进** - 根据反馈调整

---

**联系人**: [你的名字]
**最后更新**: 2026-04-18
