# TODO: 修复 CO2 技术映射

**日期**: 2026-04-19
**优先级**: 高
**影响**: 阻塞 gcamreport 完整运行

---

## 问题描述

`CO2_tech_map_vGCAMChina7.1.csv` 缺少 CCS 技术的映射，导致 gcamreport 运行失败。

**错误信息**:
```
Error in left_join_strict: Some rows in the left dataset do not have matching keys in the right dataset.
Missing mappings for 95 technologies including:
- electricity, biomass, biomass (conv CCS)
- electricity, biomass, biomass (IGCC CCS)
- electricity, coal, coal (conv pul CCS)
- electricity, coal, coal (IGCC CCS)
- electricity, gas, gas (CC CCS)
- electricity, gas, gas (steam/CT CCS)
... (89 more)
```

---

## 需要添加的映射

在 `inst/extdata/mappings/GCAMChina7.1/CO2_tech_map.csv` 中添加：

```csv
# 发电 - 生物质 CCS
electricity,biomass,biomass (conv CCS),Emissions|CO2,Emissions|CO2|Energy and Industrial Processes,Emissions|CO2|Energy,Emissions|CO2|Energy|Supply,Emissions|CO2|Energy|Supply|Electricity,,,,,3.666667
electricity,biomass,biomass (IGCC CCS),Emissions|CO2,Emissions|CO2|Energy and Industrial Processes,Emissions|CO2|Energy,Emissions|CO2|Energy|Supply,Emissions|CO2|Energy|Supply|Electricity,,,,,3.666667

# 发电 - 煤炭 CCS
electricity,coal,coal (conv pul CCS),Emissions|CO2,Emissions|CO2|Energy and Industrial Processes,Emissions|CO2|Energy,Emissions|CO2|Energy|Supply,Emissions|CO2|Energy|Supply|Electricity,,,,,3.666667
electricity,coal,coal (IGCC CCS),Emissions|CO2,Emissions|CO2|Energy and Industrial Processes,Emissions|CO2|Energy,Emissions|CO2|Energy|Supply,Emissions|CO2|Energy|Supply|Electricity,,,,,3.666667

# 发电 - 天然气 CCS
electricity,gas,gas (CC CCS),Emissions|CO2,Emissions|CO2|Energy and Industrial Processes,Emissions|CO2|Energy,Emissions|CO2|Energy|Supply,Emissions|CO2|Energy|Supply|Electricity,,,,,3.666667
electricity,gas,gas (steam/CT CCS),Emissions|CO2,Emissions|CO2|Energy and Industrial Processes,Emissions|CO2|Energy,Emissions|CO2|Energy|Supply,Emissions|CO2|Energy|Supply|Electricity,,,,,3.666667

# ... (其他 89 个技术)
```

---

## 解决方案

### 方案 1: 手动添加（推荐）

1. 查看完整的错误日志，获取所有缺失的技术列表
2. 对于每个缺失的技术，添加对应的映射行
3. 映射格式与非 CCS 版本相同

### 方案 2: 自动生成

创建脚本，对于每个有 CCS 版本的技术，自动生成对应的映射：

```r
# 读取现有映射
co2_map <- read.csv("CO2_tech_map.csv")

# 找到所有非 CCS 技术
non_ccs <- co2_map %>% filter(!grepl("CCS", technology))

# 为每个技术生成 CCS 版本
ccs_map <- non_ccs %>%
  mutate(technology = paste(technology, "CCS"))

# 合并并保存
full_map <- rbind(co2_map, ccs_map)
write.csv(full_map, "CO2_tech_map_updated.csv", row.names = FALSE)
```

---

## 验证步骤

修复后，运行：

```r
gcamreport::generate_report(
  db_path = 'E:/GCAM/GCAM-China_v7.1/output',
  db_name = 'China60Ref',
  prj_name = 'test',
  scenarios = 'China60ref',
  GCAM_version = 'vGCAMChina7.1'
)
```

应该不再报错。

---

## 注意事项

**这个问题与 GAINS 映射修正无关**

- GAINS 映射修正（畜牧业和土地利用）已经完成
- CO2 映射问题是 gcamreport 原有的问题
- 两者可以独立修复

---

**创建日期**: 2026-04-19
**状态**: 待修复
**负责人**: TBD
