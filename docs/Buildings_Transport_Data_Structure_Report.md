# GCAM-China 建筑和交通数据结构验证报告

**验证日期**: 2026-04-18
**数据库**: China60Ref (E:/GCAM/GCAM-China_v7.1/output/China60Ref)

---

## 📊 建筑和交通数据结构验证结果汇总

### 建筑部门 (Buildings)

| 数据类型 | 查询名称 | 省级数据 | 国家级数据 | 区域数 | 部门数 | 备注 |
|---------|---------|---------|-----------|--------|--------|------|
| **建筑服务成本** | `building service costs` | ✅ 有 | ❌ 无 | 62 | 176 | 31个省份，无国家级 |
| **建筑能源消费** | `building total final energy by service` | ✅ 有 | ❌ 无 | 62 | 176 | 31个省份，无国家级 |
| **建筑面积** | `building floorspace` | ✅ 有 | ❌ 无 | 62 | - | 31个省份，无国家级 |

### 交通部门 (Transport)

| 数据类型 | 查询名称 | 省级数据 | 国家级数据 | 区域数 | 部门数 | 备注 |
|---------|---------|---------|-----------|--------|--------|------|
| **交通模式成本** | `costs of transport modes` | ✅ 有 | ❌ 无 | 62 | 8 | 31个省份，20种模式 |
| **交通能源消费** | `transport final energy by mode and fuel` | ✅ 有 | ❌ 无 | 62 | 8 | 31个省份，15种模式 |
| **交通服务产出** | `transport service output by mode` | ✅ 有 | ❌ 无 | 62 | 8 | 31个省份，20种模式 |
| **交通技术产出** | `transport service output by tech and vintage` | ✅ 有 | ❌ 无 | 62 | 8 | 31个省份，详细技术 |
| **燃料价格** | `fuel prices to transport` | ✅ 有 | ✅ 有 | 63 | - | 31个省份 + 全球区域 |

---

## 🔍 详细发现

### 1. 建筑部门 (Buildings)

#### 1.1 建筑能源消费

**查询**: `building total final energy by service`

- **空间分辨率**: ✅ 省级（仅省级，无国家级汇总）
- **区域数**: 62个（31个省 + 31个全球区域）
- **服务类型** (176个部门):
  - **商业建筑** (comm):
    - comm cooling (商业制冷)
    - comm heating (商业供暖)
    - comm others (商业其他)
  - **居民建筑** (resid):
    - resid cooling modern_d1-d10 (居民制冷，按收入分组)
    - resid heating modern_d1-d10 (居民供暖，按收入分组)
    - resid others modern_d1-d10 (居民其他，按收入分组)

**数据维度**:
- region (区域)
- sector (服务类型)
- year (年份)
- value (能源消费量，EJ)

**关键结论**: ✅ **建筑能源消费数据已有省级分辨率，按服务类型和收入组详细分类！**

---

#### 1.2 建筑面积

**查询**: `building floorspace`

- **空间分辨率**: ✅ 省级
- **区域数**: 62个（31个省 + 31个全球区域）
- **建筑类型**:
  - comm (商业建筑)
  - resid (居民建筑)

**单位**: billion m² (十亿平方米)

**关键结论**: ✅ **建筑面积数据已有省级分辨率！**

---

### 2. 交通部门 (Transport)

#### 2.1 交通能源消费

**查询**: `transport final energy by mode and fuel`

- **空间分辨率**: ✅ 省级（仅省级，无国家级汇总）
- **区域数**: 62个（31个省 + 31个全球区域）
- **交通部门** (8个):
  - trn_aviation_intl (国际航空)
  - trn_freight (货运)
  - trn_freight_road (公路货运)
  - trn_pass (客运)
  - trn_pass_road (公路客运)
  - trn_pass_road_LDV (轻型客车)
  - trn_pass_road_LDV_4W (四轮轻型客车)
  - trn_shipping_intl (国际航运)

- **交通模式** (15种):
  - **航空**: International Aviation, Domestic Aviation
  - **铁路**: Freight Rail, Passenger Rail, HSR (高铁)
  - **公路货运**: Heavy truck, Medium truck, Light truck
  - **公路客运**: Bus, LDV, 2W and 3W
  - **水运**: Domestic Ship

- **燃料类型**:
  - electricity (电力)
  - refined liquids (成品油)
  - natural gas (天然气)
  - hydrogen (氢能)
  - biofuels (生物燃料)

**数据维度**:
- region (区域)
- sector (交通部门)
- mode (交通模式)
- input (燃料类型)
- year (年份)
- value (能源消费量，EJ)

**关键结论**: ✅ **交通能源消费数据已有省级分辨率，按模式和燃料详细分类！**

---

#### 2.2 交通服务产出

**查询**: `transport service output by mode`

- **空间分辨率**: ✅ 省级
- **区域数**: 62个（31个省 + 31个全球区域）
- **交通模式** (20种):
  - **非机动**: Walk (步行), Cycle (自行车)
  - **公共交通**: Bus, HSR, Passenger Rail, Domestic Aviation
  - **私人交通**: LDV, 2W and 3W
  - **货运**: road (公路货运)
  - **国际**: International Aviation

**单位**:
- 客运: million pass-km (百万人公里)
- 货运: million ton-km (百万吨公里)

**关键结论**: ✅ **交通服务产出数据已有省级分辨率，包含客运和货运！**

---

#### 2.3 交通技术细节

**查询**: `transport service output by tech and vintage`

- **空间分辨率**: ✅ 省级
- **区域数**: 62个（31个省 + 31个全球区域）
- **技术类型**:
  - BEV (纯电动)
  - PHEV (插电混动)
  - FCEV (燃料电池)
  - ICE (内燃机)
  - Hybrid (混合动力)
  - 按年份分组 (vintage)

**关键结论**: ✅ **交通技术数据已有省级分辨率，包含详细的技术类型和年份信息！**

---

## ⚖️ 各部门数据结构对比

| 部门 | 生产/产出数据 | 能源消费数据 | 需求数据 | 是否需要分配 | 工作量估算 |
|------|-------------|-------------|---------|-------------|-----------|
| **农业** | ❌ 国家级 | ✅ 省级 | ✅ 省级（作物）<br>❌ 国家级（畜牧业） | ✅ 需要 | 7-8周 |
| **工业** | ✅ 省级 | ✅ 省级 | ✅ 省级 | ❌ 不需要 | 3-4周 |
| **建筑** | ✅ 省级 | ✅ 省级 | ✅ 省级 | ❌ 不需要 | 2-3周 |
| **交通** | ✅ 省级 | ✅ 省级 | ✅ 省级 | ❌ 不需要 | 2-3周 |

---

## 🎯 GCAM2GAINS 映射策略

### 建筑部门映射策略

```
省级建筑能源数据 → 按服务类型映射 → GAINS格式
```

**优势**:
- ✅ 数据已有省级分辨率
- ✅ 服务类型详细（制冷、供暖、其他）
- ✅ 按收入组分类（d1-d10）
- ✅ 无需分配算法

**工作重点**:
1. 创建 GCAM 建筑服务 → GAINS 建筑部门的映射表
2. 处理收入组聚合（如果GAINS不需要这么细的分类）
3. 开发格式转换函数

---

### 交通部门映射策略

```
省级交通能源数据 → 按模式和燃料映射 → GAINS格式
```

**优势**:
- ✅ 数据已有省级分辨率
- ✅ 交通模式详细（客运、货运、航空、铁路、公路、水运）
- ✅ 燃料类型详细
- ✅ 技术信息详细（电动、混动、燃料电池等）
- ✅ 无需分配算法

**工作重点**:
1. 创建 GCAM 交通模式 → GAINS 交通部门的映射表
2. 创建 GCAM 燃料类型 → GAINS 燃料类型的映射表
3. 处理国际交通（航空、航运）的特殊情况
4. 开发格式转换函数

---

## 📋 需要创建的映射文件

### 建筑部门

1. **`gcam2gains_buildings_services.csv`**
   - GCAM 建筑服务 → GAINS 建筑部门
   - 处理 comm/resid 分类
   - 处理 cooling/heating/others 分类

2. **`gcam2gains_buildings_income_groups.csv`**
   - GCAM 收入组 (d1-d10) → GAINS 分类
   - 如果需要聚合

### 交通部门

1. **`gcam2gains_transport_modes.csv`**
   - GCAM 交通模式 → GAINS 交通部门
   - 20种交通模式的映射

2. **`gcam2gains_transport_fuels.csv`**
   - GCAM 燃料类型 → GAINS 燃料类型
   - 用于交通能源消费数据映射

3. **`gcam2gains_transport_technologies.csv`**
   - GCAM 技术 → GAINS 技术
   - BEV, PHEV, FCEV, ICE等

---

## 🔧 实施方案

### 建筑部门 (2-3周)

#### Phase 1: 映射表设计（0.5周）

**建筑服务映射**:
| GCAM Service | GAINS Sector | 备注 |
|--------------|--------------|------|
| comm cooling | Commercial Cooling | 商业制冷 |
| comm heating | Commercial Heating | 商业供暖 |
| comm others | Commercial Other | 商业其他 |
| resid cooling | Residential Cooling | 居民制冷 |
| resid heating | Residential Heating | 居民供暖 |
| resid others | Residential Other | 居民其他 |

#### Phase 2: 开发转换函数（1-1.5周）

```r
convert_buildings_to_gains <- function(gcam_data, service_mapping) {
  # 1. 提取省级建筑数据
  # 2. 聚合收入组（如果需要）
  # 3. 应用服务类型映射
  # 4. 转换为 GAINS 格式
  # 5. 验证数据完整性
}
```

#### Phase 3: 验证测试（0.5周）

---

### 交通部门 (2-3周)

#### Phase 1: 映射表设计（0.5周）

**交通模式映射**:
| GCAM Mode | GAINS Sector | 备注 |
|-----------|--------------|------|
| LDV | Passenger Road - LDV | 轻型客车 |
| Bus | Passenger Road - Bus | 公交 |
| 2W and 3W | Passenger Road - 2W/3W | 两轮/三轮 |
| Passenger Rail | Passenger Rail | 客运铁路 |
| HSR | Passenger Rail - HSR | 高铁 |
| Domestic Aviation | Domestic Aviation | 国内航空 |
| Heavy truck | Freight Road - Heavy | 重型货车 |
| Medium truck | Freight Road - Medium | 中型货车 |
| Light truck | Freight Road - Light | 轻型货车 |
| Freight Rail | Freight Rail | 货运铁路 |

#### Phase 2: 开发转换函数（1-1.5周）

```r
convert_transport_to_gains <- function(gcam_data, mode_mapping, fuel_mapping) {
  # 1. 提取省级交通数据
  # 2. 应用模式映射
  # 3. 应用燃料映射
  # 4. 处理国际交通
  # 5. 转换为 GAINS 格式
  # 6. 验证数据完整性
}
```

#### Phase 3: 验证测试（0.5周）

---

## ⏱️ 总体工作量估算（更新）

| 部门 | 数据分配 | 映射表创建 | 转换函数 | 验证测试 | 总计 |
|------|---------|-----------|---------|---------|------|
| **农业** | 2周 | 1周 | 2-3周 | 2周 | 7-8周 |
| **工业** | ❌ 不需要 | 1周 | 1-2周 | 1周 | 3-4周 |
| **建筑** | ❌ 不需要 | 0.5周 | 1-1.5周 | 0.5周 | 2-3周 |
| **交通** | ❌ 不需要 | 0.5周 | 1-1.5周 | 0.5周 | 2-3周 |
| **总计** | | | | | **14-18周** |

---

## 🎯 优先级建议（更新）

### 方案 A: 按难度递增（推荐）

1. **建筑部门** (2-3周) - 最简单
   - 服务类型少
   - 数据结构清晰
   - 快速建立工作流程

2. **交通部门** (2-3周) - 简单
   - 模式较多但清晰
   - 可以复用建筑部门的经验

3. **工业部门** (3-4周) - 中等
   - 部门多但数据完整
   - 技术信息详细

4. **农业部门** (7-8周) - 最复杂
   - 需要分配算法
   - 需要更多验证

**总时间**: 14-18周（按顺序执行）

---

### 方案 B: 按重要性优先

如果 GAINS 团队对某些部门有优先需求，可以调整顺序。

---

## 📝 关键结论

### 数据可用性总结

1. **农业部门**: ⚠️ 生产数据仅国家级，需要分配
2. **工业部门**: ✅ 所有数据已有省级分辨率
3. **建筑部门**: ✅ 所有数据已有省级分辨率
4. **交通部门**: ✅ 所有数据已有省级分辨率

### 工作量总结

- **无需分配的部门** (工业、建筑、交通): 7-10周
- **需要分配的部门** (农业): 7-8周
- **总工作量**: 14-18周

### 实施建议

1. **先完成简单部门** (建筑、交通、工业)
   - 快速产出结果
   - 建立标准工作流程
   - 积累经验

2. **最后处理复杂部门** (农业)
   - 有充足时间开发分配算法
   - 可以借鉴前面的经验
   - 有更多时间验证

---

**验证完成日期**: 2026-04-18
**下次更新**: 开始创建映射表后
