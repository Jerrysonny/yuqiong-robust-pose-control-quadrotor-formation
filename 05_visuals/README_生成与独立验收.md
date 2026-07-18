# RA-GCA-CGHTE可视化素材

## 资产范围

| 类型 | 数量 | 位置 | 用途 |
|---|---:|---|---|
| 发布静态图 | 3 | `assets/static` | 快速展示典型任务、参数鲁棒性和编队安全 |
| 单主题GIF | 6 | `assets/gif` | 动态展示推力估计、队形变换和PP-CBF作用 |
| 最终报告图 | 28 | `assets/report_static` | 与正式仿真报告图号逐项对应 |
| 图件底稿 | 47 | `assets/report_sources/vectors` | 24张SVG和23张PDF |

最终报告另有26张编号表。表格数据或模型来源与28幅图统一登记在`08_provenance/FINAL_REPORT_ASSET_INDEX.csv`，不保存表格截图。

## 数据口径

- 正式主算法32项raw：`06_supplementary_evidence/ra_gca_cg_hte_32_raw`。
- 历史回归raw：`06_supplementary_evidence/ra_gca_v8_32_raw`，仅用于补充核对和工程回滚。
- 报告结构化证据：`04_results/report_evidence`。
- 最终图派生数据：`assets/report_sources/data`。
- 正式算法身份：`MAIN_ALGORITHM.json`。

发布静态图和GIF由`generate_visuals.js`离线生成；最终报告图按冻结原图集中准入，不从Word嵌入媒体反向提取。Sysblock和Sysplorer结构图采用实际模型导出。

## 生成环境

生成器优先读取`A8_PYTHON`，其次读取`MWORKS_PYTHON`，随后查询Sysplorer 2026a注册表、标准安装目录和`PATH`。Python必须能够导入Pillow。Node依赖优先使用`PLAYWRIGHT_CORE_PATH`和`PNGJS_PATH`，也支持当前项目、`NODE_PATH`和全局npm目录；浏览器可通过`CHROME_PATH`指定。

```powershell
$env:A8_SOURCE_PACKAGE_ROOT = (Resolve-Path '..').Path
$env:A8_PYTHON = '<可导入Pillow的python.exe完整路径>'
node .\generate_visuals.js
```

尖括号内容需替换为本机实际路径。生成结果只写入隔离暂存区，不直接覆盖正式资产。

## 只读验收

```powershell
$env:A8_SOURCE_PACKAGE_ROOT = (Resolve-Path '..').Path
node .\verify_assets.js

$Python = $env:MWORKS_PYTHON
& $Python -B .\verify_final_report_assets.py --check
```

验收内容包括：

- 3张发布静态图、6个GIF和28张最终报告图的数量与SHA256；
- 28张报告图的尺寸、来源、生成入口和最终图号；
- 64份raw的来源哈希；
- GIF帧数、帧延迟和首中末帧；
- 图件文字、裁切、遮挡和正式算法名称。

## QA文件

- `qa/qa_report.json`：发布静态图和GIF验收结果。
- `qa/pillow_encoding_report.json`：GIF编码与逐帧重读结果。
- `qa/final_report_static_qa.json`：28张最终报告图的机器可读记录。
- `qa/最终报告28图联系表.png`：最终报告图缩略总览。
