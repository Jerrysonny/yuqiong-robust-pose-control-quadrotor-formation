# 可视化说明

本目录保留两类正式资产：

- `assets/static`和`assets/gif`：3张发布静态图和6个单主题GIF。
- `assets/report_static`：最终仿真报告实际采用的28幅PNG，文件名与`FIG_*`资产编号一致。

最终报告图的矢量底稿和必要派生数据位于`assets/report_sources`，来源、生成入口和SHA256统一登记在`../08_provenance/FINAL_REPORT_ASSET_INDEX.csv`。原章节生成器作为来源记录保存在`../08_provenance/report_generation_sources/scripts`，不作为默认运行入口。

发布静态图和GIF的开发生成入口为`generate_visuals.js`。可通过`A8_PYTHON`或`MWORKS_PYTHON`指定Pillow Python，通过`PLAYWRIGHT_CORE_PATH`、`PNGJS_PATH`和`CHROME_PATH`覆盖Node模块或浏览器位置；未设置时生成器会查询注册表、标准安装目录、`PATH`和全局npm目录。生成入口只写隔离暂存区。

只读验收：

```powershell
$Python = $env:MWORKS_PYTHON
& $Python -B .\verify_final_report_assets.py --check

$env:A8_SOURCE_PACKAGE_ROOT = (Resolve-Path '..').Path
node .\verify_assets.js
```

最终报告图已经冻结，不通过修改图例或从Word解包图片重建。需要变更图件时，应先更新正式数据和原始图，再同步资产索引、视觉清单及整包SHA256清单。
