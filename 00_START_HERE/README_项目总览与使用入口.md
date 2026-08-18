# 项目总览与使用入口

## 1. 项目内容

主算法为角残差驱动守卫型鲁棒几何位姿控制（Angular-Residual-Driven Guarded Robust Geometric Pose Control，ARDG-RGPC）。控制器完成位置及滚转、俯仰约化姿态控制，并通过转子转速力矩重构、角残差判别、滞回守卫、渐变补偿、幅值与变化率约束及安全旁路提高扰动条件下的工程可控性。

## 2. 环境要求

- MWORKS Sysplorer 2026a；
- MWORKS Syslab 2026a与`julia-ty`；
- Windows PowerShell 5.1或更高版本；
- 运行仿真时只保留一个Sysplorer实例。

## 3. 目录

- `01_models`：官方物理模型、ARDG-RGPC控制器、场景包装和比较算法；
- `02_scripts`：仿真运行、结果评价和只读验收脚本；
- `04_results/report_evidence`：报告采用的结构化指标和统计结果；
- `05_visuals`：30幅报告图、3幅静态展示图和6个动画；
- `06_supplementary_evidence`：最终算法与官方PID的直接原始证据；
- `08_provenance`：报告冻结、资产来源、哈希和整包审计记录。

## 4. 场景套件

| 套件 | 数量 | 内容 |
|---|---:|---|
| `finals_core` | 20 | 18项代表性回归与2项机体系角扰动 |
| `regression18` | 18 | 单机轨迹、标准阶跃、风扰和传感器退化 |
| `supplementary` | 14 | 参数、编队与PP-CBF场景 |
| `full_registered` | 34 | 全部注册场景 |

## 5. 推荐操作

```powershell
.\RUN_ALL.ps1 -Mode Precheck

$Output = Join-Path $env:USERPROFILE 'A8_runs\finals_core'
.\RUN_ALL.ps1 -Mode Simulate -Suite finals_core -Output $Output

$Output = Join-Path $env:USERPROFILE 'A8_runs\all_scenes'
.\RUN_ALL.ps1 -Mode Simulate -Suite full_registered -Output $Output
```

正式场景已自动连接四路转子转速、补偿使能和连续仿真时间。角扰动场景生成`raw.csv`、`ardg_diagnostics.csv`和`execution_status.json`。

## 6. 结果边界

- 20组随机参数对照中，ARDG-RGPC相对官方PID的20组位置RMSE均更低，中位降幅为87.63%；
- 三事件外力扰动恢复场景中，位置RMSE由官方PID的0.306769 m降至0.269476 m，降低12.16%；
- 两个角扰动场景中，官方PID的姿态事件IAE更低，ARDG-RGPC的电机总变差低约2.58%；
- 18项代表性回归、11项预设参数、6项复合应力和3项编队安全场景均保留最终算法直接证据。

报告对优势和代价分别陈述，不使用单一加权总分替代各项指标。
