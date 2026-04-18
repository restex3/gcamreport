# 重新编译 GCAMChina7.1 的映射数据
# 需要先加载 gcamreport 包以使用 gather_map 函数

# 1. 加载 gcamreport 包
devtools::load_all(".", reset = TRUE)

# 2. 运行数据文件生成脚本
source("inst/extdata/saveDataFiles_GCAMChina7.1.R")

cat("\n映射数据已重新编译！\n")
cat("现在可以运行导出脚本了。\n")
