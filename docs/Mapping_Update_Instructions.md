# gcamreport 映射文件更新说明

**日期**: 2026-04-19
**问题**: 修改 CSV 映射文件后，gcamreport 仍然使用旧的映射

---

## 问题原因

gcamreport 将映射文件编译成 R 数据对象（.rda 文件），存储在包内部。

**证据**:
```r
# R/data.R 中定义了数据对象
"co2_tech_map_v7.1"
"co2_tech_map_v7.2"
"co2_tech_map_v8.2"
```

这意味着：
- ❌ 直接修改 CSV 文件不会生效
- ✅ 需要重新构建包才能使用新的映射

---

## 解决方案

### 方法 1: 重新构建包（推荐）

```r
# 在 gcamreport 根目录
devtools::document()
devtools::load_all()
```

**优点**:
- ✅ 正确的方法
- ✅ 更新所有数据对象

**缺点**:
- ⚠️ 需要开发环境
- ⚠️ 需要重新加载包

---

### 方法 2: 安装包

```r
# 在 gcamreport 根目录
devtools::install()
```

**优点**:
- ✅ 永久安装
- ✅ 所有 R 会话都能使用

**缺点**:
- ⚠️ 需要更多时间
- ⚠️ 可能需要管理员权限

---

### 方法 3: 使用 GCAM-China-reporting

如果 gcamreport 的问题难以解决，可以考虑使用 GCAM-China-reporting：

```r
# 使用 GCAM-China-reporting 的方法
source("/e/GCAM/GCAM_tools/GCAM-China-reporting/Reporting.R")
```

**优点**:
- ✅ 专门为 GCAM-China 设计
- ✅ 已验证可用

**缺点**:
- ⚠️ 不同的工作流程
- ⚠️ 可能需要修改代码

---

## 当前状态

### 已完成
- ✅ 修改了 CSV 映射文件
  - ag_production_map.csv (GAINS 修正)
  - land_use_map.csv (GAINS 修正)
  - CO2_tech_map.csv (666 个映射)

- ✅ 重新构建了包
  ```r
  devtools::document()
  devtools::load_all()
  ```

### 测试中
- ⏳ 使用重新构建的包进行测试
- ⏳ 验证映射是否生效

---

## 重要提示

### 每次修改映射文件后

**必须执行**:
```r
devtools::load_all()
```

或者：
```r
devtools::install()
```

### 验证映射是否加载

```r
# 检查 CO2 映射
co2_map <- gcamreport::co2_tech_map_vGCAMChina7.1
nrow(co2_map)  # 应该是 666

# 检查畜牧业映射
ag_map <- gcamreport::ag_production_map_vGCAMChina7.1
ag_map[ag_map$sector == "Beef", ]  # 应该包含 GAINS 修正
```

---

## 建议

### 短期
1. ✅ 使用 `devtools::load_all()` 重新加载
2. ⏳ 测试验证
3. ⏭️ 如果成功，安装包

### 长期
1. ⏭️ 创建自动化脚本
2. ⏭️ 在 CI/CD 中自动重新构建
3. ⏭️ 文档化这个流程

---

## 相关文件

- **映射文件**: `inst/extdata/mappings/GCAMChina7.1/*.csv`
- **数据定义**: `R/data.R`
- **数据对象**: `data/*.rda`

---

**创建日期**: 2026-04-19
**状态**: 测试中
**下次更新**: 测试完成后
