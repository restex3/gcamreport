# gcamreport 项目当前状态

**日期**: 2026-04-18
**分支**: dev-gcamchina_support
**最新提交**: ef6f11ce - Add dedicated GCAM-China support and maintenance docs

---

## 📊 项目概览

**gcamreport** 是一个 R 包，用于从 GCAM 输出生成符合 IAMC 标准的报告数据集。

- **版本**: 1.0.0
- **支持的 GCAM 版本**: 6.0, 7.0, 7.1, 7.2, 8.2, GCAM-China 7.1
- **许可证**: MIT

---

## 📁 目录结构

```
gcamreport/
├── R/                      # R 包源代码 (5个核心文件)
├── inst/                   # 包安装文件
│   ├── extdata/
│   │   ├── mappings/       # 6个 GCAM 版本的映射文件
│   │   ├── queries/        # 查询定义
│   │   └── template/       # 模板文件
│   └── gcamreport_ui/      # Shiny UI
├── man/                    # 函数文档
├── tests/                  # 单元测试
├── vignettes/              # 用户教程 (7个)
├── data/                   # 包数据
│
├── dev_scripts/            # 开发脚本 (25KB, 不打包)
│   ├── GCAM-China_*.R      # GCAM-China 测试脚本
│   ├── rebuild_mappings.R  # 重建映射
│   └── README.md
│
├── docs/                   # 项目文档 (50KB, 不打包)
│   ├── gcam-china/         # GCAM-China 专项文档
│   │   ├── README_GCAM-China.md
│   │   ├── GCAM-China_AGENT_MANUAL.md
│   │   ├── GCAM-China_IMPROVEMENTS.md
│   │   └── GCAM_CHINA_WORK_PLAN.md
│   ├── AGENTS.md
│   ├── CHANGELOG_SUMMARY.md
│   ├── PROJECT_STRUCTURE.md
│   └── README.md
│
├── examples/               # 示例数据 (83MB, 不打包)
├── output/                 # 输出目录 (5.7MB, 不打包)
└── paper/                  # 论文相关

标准 R 包文件:
├── DESCRIPTION             # 包描述
├── NAMESPACE               # 命名空间
├── README.md               # 主文档
├── NEWS.md                 # 更新日志
├── LICENCE                 # 许可证
└── .Rbuildignore           # 构建排除规则
```

---

## 🔄 Git 状态

### 待提交的更改 (已暂存)

**配置文件更新:**
- `.Rbuildignore` - 添加开发目录排除规则
- `.gitignore` - 优化忽略规则

**文件重组 (10个文件移动):**
- 6个文件 → `dev_scripts/` (开发脚本)
- 4个文件 → `docs/` (项目文档)

**新增文件:**
- `dev_scripts/README.md` - 开发脚本说明
- `docs/README.md` - 文档目录说明
- `docs/PROJECT_STRUCTURE.md` - 项目结构文档

### 文件统计
- **移动**: 10个文件 (R=6, MD=4)
- **新增**: 5个文件 (R=3, MD=2, CSV=1, DAT=1)
- **修改**: 2个配置文件

---

## ✅ 整理成果

### 根目录清理
- ✅ 移除 8个临时测试脚本
- ✅ 移除 6个散落的文档文件
- ✅ 删除备份和临时文件
- ✅ 根目录现在只保留标准 R 包文件

### 新增组织结构
- ✅ `dev_scripts/` - 集中管理开发脚本
- ✅ `docs/gcam-china/` - GCAM-China 专项文档
- ✅ 每个目录都有 README 说明

### 配置优化
- ✅ `.Rbuildignore` 排除开发文件
- ✅ `.gitignore` 保留文档源文件，只忽略生成文件

---

## 📦 R 包信息

### 核心功能
- 从 GCAM 数据库生成标准化报告
- 支持多个 GCAM 版本和 GCAM-China
- 交互式 Shiny UI
- 导出为 CSV/XLSX/RData 格式

### 依赖包
- **数据处理**: dplyr, tidyr, tibble, readr
- **GCAM**: rgcam, rpackageutils
- **可视化**: ggplot2, shiny, shinydashboard
- **其他**: xml2, writexl, rrapply

---

## 🎯 下一步建议

1. **提交更改**:
   ```bash
   git commit -m "Reorganize project structure: move dev scripts and docs"
   ```

2. **可选清理** (如果需要):
   - 考虑清理 `examples/` 中的大文件 (83MB)
   - 考虑清理 `output/` 中的输出文件 (5.7MB)

3. **验证构建**:
   ```r
   devtools::check()
   ```

---

## 📝 注意事项

- 所有更改已暂存，可以直接提交
- 开发脚本和文档已排除在 R 包构建之外
- 项目结构现在符合 R 包开发最佳实践
- GCAM-China 相关文档已集中管理
