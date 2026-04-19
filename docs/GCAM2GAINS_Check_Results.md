# GCAM2GAINS 映射检查结果和修正方案

**日期**: 2026-04-19

---

## 检查结果总结

### ✅ 已经正确的映射

1. **发电技术** (elec_gen_map_gcamchina.csv)
   - ✅ 使用 `Secondary Energy|Electricity|Coal|w/o CCS`
   - ✅ 使用 `Secondary Energy|Electricity|Gas|w/ CCS`
   - ✅ 正确区分了 w/ CCS 和 w/o CCS

2. **交通能源** (transport_final_en_map_gcamchina.csv)
   - ✅ 使用 `Final Energy|Transportation|...`
   - ✅ 变量名正确

3. **工业能源** (final_energy_map_gcamchina.csv)
   - ✅ 有细分到 `Final Energy|Industry|Chemicals|...`
   - ✅ 有细分到 `Final Energy|Industry|Cement|...`
   - ✅ 有 `Final Energy|Non-Energy Use|...`

4. **建筑能源** (final_energy_map_gcamchina.csv)
   - ✅ 使用 `Final Energy|Residential and Commercial|...`
   - ✅ 变量名正确

### ⚠️ 需要修正的映射

#### 1. 土地利用 (land_use_map.csv)

**问题**: 变量名与 GAINS 不完全匹配

**需要修正的行**:
- 第13行: Forest
- 第36行: OtherArableLand
- 第41行: Pasture

#### 2. 一次能源转换 (primary_energy_map.csv)

**问题**: 缺少 `Primary Energy|...|Convert` 变量

GAINS 需要:
- `Primary Energy|Coal|Convert`
- `Primary Energy|Gas|Convert`
- `Primary Energy|Oil|Convert`
- `Primary Energy|Biomass|Convert`

但 gcamreport 当前只有:
- `Primary Energy|Coal|w/o CCS`
- `Primary Energy|Gas|w/o CCS`

**原因**: 这些变量可能需要从不同的查询中提取（能源转换部门）

#### 3. 资源开采

**问题**: 需要检查是否有 `Resource|Extraction|...` 变量

---

## 立即执行的修正

### 修正 1: 土地利用映射

