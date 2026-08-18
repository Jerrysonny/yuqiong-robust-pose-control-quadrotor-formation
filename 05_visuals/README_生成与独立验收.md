# ARDG-RGPC可视化素材生成与验收

## 资产范围

| 类型 | 数量 | 位置 | 用途 |
|---|---:|---|---|
| 发布静态图 | 3 | `assets/static` | 典型任务、参数统计和编队安全展示 |
| 单主题GIF | 6 | `assets/gif` | 参数响应、推力尺度、队形变换和PP-CBF动态展示 |
| 最终报告图 | 30 | `assets/report_final_20260816` | 与正式仿真报告图号逐项对应 |
| 图件底稿 | 51 | `assets/report_sources/vectors` | 27张SVG和24张PDF |

最终报告另有28张编号表。图表数据或模型来源统一登记在`../08_provenance/FINAL_REPORT_ASSET_INDEX.csv`，不保存表格截图。

## 数据口径

- 正式主算法：`ARDG-RGPC`。
- 报告结构化证据：`../04_results/report_evidence`。
- 最终直接原始证据：`../06_supplementary_evidence`中的`ardg_rgpc_*_final`目录。
- 最终图派生数据：`assets/report_sources/data`。
- 正式算法身份：`../MAIN_ALGORITHM.json`。

所有公开主算法图件必须来自最终算法直接证据。官方PID、几何控制基线、CAP-ADRC和CP-INDI只在已登记的同场景比较中使用，不外推到未运行场景。

## 只读验收

```powershell
. ..\02_scripts\powershell\A8RuntimeResolver.ps1
$Python = Resolve-A8MWorksPython
& $Python -B .\verify_final_report_assets.py --check
..\RUN_ALL.ps1 -Mode Precheck
```

验收内容包括：

- 3张发布静态图、6个GIF和30张最终报告图的数量、尺寸与SHA256；
- 6个GIF的1280 x 720画布和36帧合同；
- 30张报告图的来源、生成入口和最终图号；
- 30幅图、28张表与58页报告冻结口径；
- 对外算法名称、路径卫生和直接证据边界。

## QA文件

- `FINALS_VISUAL_REVISION_MANIFEST_20260816.json`：静态图、GIF、关键报告图及源数据的决赛生成与验收记录。
- `qa/静态图联系表.png`：3张发布静态图总览。
- `qa/GIF首中末帧联系表.png`：6个GIF的首帧、中帧和末帧总览。
- `qa/final_report_static_qa.json`：30张最终报告图的机器可读记录。
- `qa/最终报告30图联系表.png`：最终报告图缩略总览。
