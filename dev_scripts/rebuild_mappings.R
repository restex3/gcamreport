# 重新编译 GCAMChina7.1 的映射数据
# 需要先加载 gcamreport 包以使用 gather_map 函数

find_repo_dir <- function() {
  candidates <- c(".", "..", "../..", "E:/GCAM/GCAM_tools/gcamreport")

  for (candidate in candidates) {
    candidate_path <- tryCatch(
      normalizePath(candidate, winslash = "/", mustWork = TRUE),
      error = function(...) NULL
    )

    if (!is.null(candidate_path) &&
        file.exists(file.path(candidate_path, "DESCRIPTION"))) {
      return(candidate_path)
    }
  }

  stop(
    "Could not locate the gcamreport repository root. Run this script from the repo root or from dev_scripts/."
  )
}

repo_dir <- find_repo_dir()

# 1. 加载 gcamreport 包
devtools::load_all(repo_dir, reset = TRUE)

# 2. 运行数据文件生成脚本
source(file.path(repo_dir, "inst", "extdata", "saveDataFiles_GCAMChina7.1.R"))

cat("\n映射数据已重新编译！\n")
cat("现在可以运行导出脚本了。\n")
