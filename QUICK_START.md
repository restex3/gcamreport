# gcamreport 快速入门教程

## 1. 安装

```r
# 安装 devtools（如果还没有）
install.packages("devtools")

# 安装 gcamreport（GCAM-China 支持版本）
devtools::install_github("restex3/gcamreport", ref = "dev-gcamchina_support")
```

## 2. 基本用法：读取 GCAM 数据库

```r
# 加载包
library(gcamreport)

# 设置参数
db_path <- "E:/GCAM/GCAM-China_v8.0/output/"  # 数据库文件夹路径
db_name <- "database_basexdb"                  # 数据库名称（不含 .basex 扩展名）
prj_name <- "my_project.dat"                   # 项目文件名（会自动创建）
scenarios <- "Reference"                       # 场景名称
GCAM_version <- "vGCAMChina8.0"                # GCAM 版本（或 "vGCAMChina7.1"）

# 生成报告
report <- generate_report(
  db_path = db_path,
  db_name = db_name,
  prj_name = prj_name,
  scenarios = scenarios,
  GCAM_version = GCAM_version
)

# 查看结果
head(report)
```

## 3. 支持的 GCAM 版本

- `"v6.0"` - GCAM-core 6.0
- `"v7.0"` - GCAM-core 7.0
- `"v7.1"` - GCAM-core 7.1
- `"v7.2"` - GCAM-core 7.2
- `"vGCAMChina7.1"` - GCAM-China 7.1
- `"vGCAMChina8.0"` - GCAM-China 8.0 ✨ **新增！**

## 4. 多场景示例

```r
# 读取多个场景
scenarios <- c("ref", "policy1", "policy2")

report <- generate_report(
  db_path = "E:/GCAM/output/",
  db_name = "my_database",
  prj_name = "multi_scenario.dat",
  scenarios = scenarios,
  GCAM_version = "vGCAMChina7.1 or vGCAMChina8.0"
)
```

## 5. 使用交互式 UI

```r
library(gcamreport)

# 方式 1：直接加载已有的报告数据
launch_gcamreport_ui(
  data_path = "path/to/your/report.RData",
  GCAM_version = "vGCAMChina7.1 or vGCAMChina8.0"
)

# 方式 2：传入数据框
launch_gcamreport_ui(
  data = report,
  GCAM_version = "vGCAMChina7.1 or vGCAMChina8.0"
)
```

## 6. 保存结果

```r
# 保存为 CSV
write.csv(report, "gcam_report.csv", row.names = FALSE)

# 保存为 RData
save(report, file = "gcam_report.RData")
```

## 常见问题

### 找不到数据库
确保 `db_path` 指向包含 `.basex` 文件的文件夹，`db_name` 是数据库名称（不含扩展名）。

### 项目文件路径
`prj_name` 可以是相对路径或绝对路径。如果文件不存在，会自动创建。

### GCAM-China 特定功能
使用 `GCAM_version = "vGCAMChina7.1 or vGCAMChina8.0"` 会自动启用 GCAM-China 特定的变量映射和聚合规则。

## 更多信息

- 完整文档：[README.md](README.md)
- GCAM-China 文档：[docs/gcam-china/README_GCAM-China.md](docs/gcam-china/README_GCAM-China.md)
- GitHub 仓库：https://github.com/restex3/gcamreport
