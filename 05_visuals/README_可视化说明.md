# 可视化说明

本目录保留三类正式资产：

- `assets/static`：3张ARDG-RGPC展示静态图，覆盖典型任务、参数统计和编队安全。
- `assets/gif`：6个ARDG-RGPC动画，覆盖参数响应、推力尺度、队形变换和PP-CBF作用。
- `assets/report_final_20260816`：最终仿真报告实际采用的30幅编号PNG。

最终报告另有28张编号表。图表来源、生成入口和SHA256统一登记在`../08_provenance/FINAL_REPORT_ASSET_INDEX.csv`。矢量底稿和必要派生数据位于`assets/report_sources`。

三张静态图和六个GIF由`build_finals_visuals_20260816.py`从最终算法直接证据生成。其尺寸、帧数、哈希和视觉检查结果登记在`FINALS_VISUAL_REVISION_MANIFEST_20260816.json`；GIF均为1280 x 720、36帧。

最终报告图只读验收：

```powershell
. ..\02_scripts\powershell\A8RuntimeResolver.ps1
$Python = Resolve-A8MWorksPython
& $Python -B .\verify_final_report_assets.py --check
```

完整材料预检：

```powershell
..\RUN_ALL.ps1 -Mode Precheck
```

正式图件已经冻结。需要修改时，应先更新直接证据和源图，再同步资产索引、视觉清单、报告冻结文件和整包SHA256清单。
