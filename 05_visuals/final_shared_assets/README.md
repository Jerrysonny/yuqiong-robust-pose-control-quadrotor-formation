# ARDG-RGPC 决赛统一图件

本目录是决赛仿真报告、代码开发文档、PPT和视频的唯一新增图件来源。

## 图件

- 图A：ARDG-RGPC结构增量。
- 图B：两个新增机体系角扰动场景对比。
- 图C：三事件外力扰动恢复场景的位置误差对比。
- 图D：18项代表性回归汇总。
- 图E：物理约束多目标参数优化与最终定型。
- 图F：生成代码、高分辨率计时和安全集成摘要。

## 使用规则

1. 报告、开发文档、PPT和视频只引用`png`或`pdf`目录中的正式输出，不自行重算数字。
2. 图例只使用`ARDG-RGPC`和“升级前主算法”，不得显示内部版本、候选或任务编号。
3. 图B中的姿态事件IAE按`8.00-12.25 s`积分，扰动窗口为`8.00-8.25 s`。
4. 图C中的位置RMSE按`0-30 s`全程三维位置误差计算。
5. `FINAL_ASSET_INDEX.json`记录源数据、输出哈希和每张图的计算指标。
6. `qa/FINAL_ASSET_QA.json`必须为`pass=true`后，图件才允许进入下游材料。

## 重新生成

在正式工作副本根目录运行：

```powershell
. .\02_scripts\powershell\A8RuntimeResolver.ps1
$Python = Resolve-A8MWorksPython
& $Python .\05_visuals\final_shared_assets\generate_final_shared_assets.py
```
