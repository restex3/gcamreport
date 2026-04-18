# gcamreport 项目结构整理总结

## 完成的改进

### 1. 目录结构优化
- **创建 `dev_scripts/` 目录**：集中存放开发和测试脚本
  - 移入所有临时测试脚本（GCAM-China 测试、区域检查等）
  - 添加 README 说明各脚本用途

- **创建 `docs/` 目录**：组织项目文档
  - `docs/gcam-china/`：GCAM-China 专项文档
  - 移入 AGENTS.md、CHANGELOG_SUMMARY.md 等文档
  - 添加 README 说明文档结构

### 2. 配置文件更新
- **`.Rbuildignore`**：排除非包文件
  - 开发脚本目录
  - 文档目录
  - 示例和输出目录
  - CI/CD 配置文件

- **`.gitignore`**：优化忽略规则
  - 保留 docs/ 源文件，只忽略生成的网站文件
  - 明确忽略输出和临时文件

### 3. 清理工作
- 删除根目录的临时文件（test.dat、备份文件等）
- 移除散落的测试脚本和数据文件

## 最终项目结构

```
gcamreport/
├── R/                    # R 包源代码
├── inst/                 # 包安装文件（mappings, queries, templates）
├── man/                  # 函数文档
├── tests/                # 单元测试
├── vignettes/            # 用户教程
├── data/                 # 包数据
├── dev_scripts/          # 开发脚本（不打包）
├── docs/                 # 项目文档（不打包）
│   └── gcam-china/       # GCAM-China 文档
├── examples/             # 示例数据（不打包）
├── output/               # 输出目录（不打包）
├── paper/                # 论文相关
├── DESCRIPTION           # 包描述文件
├── NAMESPACE             # 命名空间
└── README.md             # 主说明文档
```

这样的结构更清晰，符合 R 包开发的最佳实践。
