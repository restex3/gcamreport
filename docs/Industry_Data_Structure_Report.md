# GCAM-China 工业数据结构验证报告

**验证日期**: 2026-04-18
**数据库**: China60Ref (E:/GCAM/GCAM-China_v7.1/output/China60Ref)

---

## 📊 工业数据结构验证结果汇总

| 数据类型 | 查询名称 | 省级数据 | 国家级数据 | 区域数 | 部门数 | 备注 |
|---------|---------|---------|-----------|--------|--------|------|
| **工业产出** | `industry primary output by sector` | ✅ 有 | ✅ 有 | 63 | 22 | 31个省份 + 全球区域 |
| **工业能源** | `industry final energy by tech and fuel` | ✅ 有 | ❌ 无 | 62 | 20 | 31个省份，无国家级 |
| **钢铁来源** | `regional iron and steel sources` | ❌ 无 | ✅ 有 | 32 | 1 | 仅全球区域 |
| **钢铁生产** | `iron and steel production by tech` | ✅ 有 | ✅ 有 | 62 | 1 | 30个省份 + 全球区域 |
| **钢铁价格** | `iron and steel prices` | ✅ 有 | ✅ 有 | 63 | 1 | 31个省份 + 全球区域 |
| **化工价格** | `chemical prices` | ✅ 有 | ✅ 有 | 63 | 1 | 31个省份 + 全球区域 |
| **铝价格** | `aluminum prices` | ❌ 无 | ❌ 无 | 31 | 1 | 全球区域，无中国省份 |
| **纸价格** | `paper prices` | ❌ 无 | ❌ 无 | 31 | 1 | 全球区域，无中国省份 |

---

## 🔍 详细发现

### 1. 工业产出 (Industry Primary Output)

**查询**: `industry primary output by sector`

- **空间分辨率**: ✅ 省级 + 国家级
- **区域数**: 63个（31个省 + 32个全球区域）
- **工业部门** (22个):
  - 能源使用: agricultural energy use, construction energy use, mining energy use, other industrial energy use, chemical energy use
  - 原料: construction feedstocks, other industrial feedstocks, chemical feedstocks, waste biomass for paper
  - 加工热: process heat cement, process heat food processing, process heat paper
  - 主要产品: cement, chemical, construction, iron and steel, aluminum, paper, food processing

**关键结论**: ✅ **工业产出数据已有省级分辨率，无需分配！**

---

### 2. 工业能源消费 (Industry Final Energy)

**查询**: `industry final energy by tech and fuel`

- **空间分辨率**: ✅ 省级（仅省级，无国家级汇总）
- **区域数**: 62个（31个省 + 31个全球区域，不包括China）
- **工业部门** (20个):
  - agricultural energy use
  - ammonia (氨)
  - cement (水泥)
  - construction energy use
  - construction feedstocks
  - food processing (食品加工)
  - iron and steel (钢铁)
  - mining energy use
  - other industrial energy use
  - other industrial feedstocks
  - process heat cement
  - process heat food processing
  - waste biomass for paper
  - alumina (氧化铝)
  - aluminum (铝)
  - chemical
  - paper
  - glass
  - N fertilizer (氮肥)

**数据维度**:
- sector (部门)
- subsector (子部门)
- technology (技术)
- input (燃料类型)

**关键结论**: ✅ **工业能源数据已有省级分辨率，且包含详细的技术和燃料信息！**

---

### 3. 钢铁生产 (Iron and Steel Production)

**查询**: `iron and steel production by tech`

- **空间分辨率**: ✅ 省级 + 国家级
- **区域数**: 62个（30个省 + 32个全球区域）
- **技术类型** (33个子部门):
  - BLASTFUR (高炉)
  - EAF (电弧炉)
  - DRI (直接还原铁)
  - 各种燃料技术（Biomass, Coal, Gas, Hydrogen等）

**关键结论**: ✅ **钢铁生产数据已有省级分辨率，包含详细的生产技术信息！**

---

## ⚖️ 农业 vs 工业数据结构对比

| 特征 | 农业部门 | 工业部门 |
|------|---------|---------|
| **生产数据** | ❌ 仅国家级 | ✅ 省级 + 国家级 |
| **需求数据** | ✅ 省级（作物）<br>❌ 国家级（畜牧业） | ✅ 省级 |
| **能源消费** | ✅ 省级 | ✅ 省级 |
| **技术细节** | 较少 | 非常详细（技术、燃料） |
| **是否需要分配** | ✅ 需要 | ❌ 不需要 |

---

## 🎯 GCAM2GAINS 映射策略差异

### 农业部门映射策略

```
国家级生产 → 基于需求/饲料分配 → 省级生产 → GAINS格式
```

**挑战**: 需要开发分配算法

---

### 工业部门映射策略

```
省级数据 → 直接映射 → GAINS格式
```

**优势**:
- ✅ 数据已有省级分辨率
- ✅ 无需分配算法
- ✅ 技术和燃料信息详细
- ✅ 可以直接进行部门映射

**工作重点**:
1. 创建 GCAM 工业部门 → GAINS 部门的映射表
2. 创建 GCAM 技术/燃料 → GAINS 技术/燃料的映射表
3. 开发格式转换函数

---

## 📋 工业部门 GCAM2GAINS 映射需求

### 需要创建的映射文件

1. **`gcam2gains_industry_sectors.csv`**
   - GCAM 工业部门 → GAINS 工业部门
   - 22个 GCAM 部门的映射

2. **`gcam2gains_industry_fuels.csv`**
   - GCAM 燃料类型 → GAINS 燃料类型
   - 用于能源消费数据映射

3. **`gcam2gains_industry_technologies.csv`**
   - GCAM 技术 → GAINS 技术
   - 特别是钢铁、水泥等重点行业

4. **`gcam2gains_industrial_products.csv`**
   - GCAM 产品 → GAINS 产品
   - cement, steel, aluminum, chemical, paper等

---

## 🔧 实施方案（工业部门）

### Phase 1: 映射表设计（1周）

创建以下映射关系：

#### 1.1 主要工业产品映射
| GCAM Sector | GAINS Sector | 备注 |
|-------------|--------------|------|
| cement | Cement | 水泥 |
| iron and steel | Iron & Steel | 钢铁 |
| aluminum | Aluminum | 铝 |
| chemical | Chemicals | 化工 |
| paper | Pulp & Paper | 造纸 |
| ammonia | Ammonia | 氨/化肥 |
| food processing | Food Processing | 食品加工 |

#### 1.2 能源使用部门映射
| GCAM Sector | GAINS Sector | 备注 |
|-------------|--------------|------|
| agricultural energy use | Agriculture Energy | 农业能源 |
| construction energy use | Construction | 建筑能源 |
| mining energy use | Mining | 采矿能源 |
| other industrial energy use | Other Industry | 其他工业 |

#### 1.3 燃料类型映射
需要映射的燃料类型（从 `input` 列）：
- Coal (煤炭)
- Natural Gas (天然气)
- Electricity (电力)
- Biomass (生物质)
- Oil (石油)
- Hydrogen (氢能)
- Heat (热力)

### Phase 2: 开发转换函数（1-2周）

```r
convert_industry_to_gains <- function(gcam_data, sector_mapping, fuel_mapping) {
  # 1. 提取省级工业数据
  # 2. 应用部门映射
  # 3. 应用燃料映射
  # 4. 转换为 GAINS 格式
  # 5. 验证数据完整性
}
```

### Phase 3: 验证测试（1周）

- 验证所有工业部门都有映射
- 验证省级数据完整性
- 与 GAINS 格式要求对比

---

## ⏱️ 工作量估算对比

| 部门 | 数据分配 | 映射表创建 | 转换函数 | 验证测试 | 总计 |
|------|---------|-----------|---------|---------|------|
| **农业** | 2周 | 1周 | 2-3周 | 2周 | 7-8周 |
| **工业** | ❌ 不需要 | 1周 | 1-2周 | 1周 | 3-4周 |

**工业部门工作量显著减少的原因**:
- ✅ 无需开发分配算法
- ✅ 无需验证分配准确性
- ✅ 数据结构更清晰
- ✅ 技术信息更完整

---

## 🎯 下一步行动

### 立即执行

1. ✅ **工业数据结构验证** - 已完成
2. ⏭️ **设计工业部门映射表**
   - 确定 GCAM → GAINS 部门对应关系
   - 确定燃料类型映射
   - 确定技术类型映射

3. ⏭️ **创建映射 CSV 文件**
   - `gcam2gains_industry_sectors.csv`
   - `gcam2gains_industry_fuels.csv`
   - `gcam2gains_industry_technologies.csv`

### 下周执行

4. **开发工业数据转换函数**
5. **测试转换结果**
6. **集成到主工作流**

---

## 📝 关键结论

### 工业部门

1. **数据可用性**: ✅ 工业产出和能源消费数据已有省级分辨率
2. **映射复杂度**: ⭐⭐ 中等（主要是部门和燃料映射）
3. **开发难度**: ⭐⭐ 中等（无需分配算法）
4. **工作量**: 3-4周

### 农业部门

1. **数据可用性**: ⚠️ 生产数据仅国家级，需要分配
2. **映射复杂度**: ⭐⭐⭐⭐ 高（需要分配算法 + 映射）
3. **开发难度**: ⭐⭐⭐⭐ 高（分配算法验证）
4. **工作量**: 7-8周

### 总体策略建议

**建议优先顺序**:
1. **先做工业部门** (3-4周)
   - 数据结构简单
   - 无需分配
   - 可以快速完成
   - 建立工作流程

2. **再做农业部门** (7-8周)
   - 需要分配算法
   - 需要更多验证
   - 可以借鉴工业部门的经验

**总工作量**: 10-12周

---

## 🔄 与农业部门的协同

虽然工业和农业的数据结构不同，但有些共同点：

1. **能源消费**: 两者都有省级能源消费数据
   - `agricultural energy use` (工业查询中)
   - 可以统一处理

2. **映射格式**: 可以使用相同的映射文件结构
   - sector mapping
   - fuel mapping
   - technology mapping

3. **转换函数**: 可以共享部分代码
   - 格式转换逻辑
   - 验证函数
   - 输出格式化

---

**验证完成日期**: 2026-04-18
**下次更新**: 工业部门映射表设计完成后
