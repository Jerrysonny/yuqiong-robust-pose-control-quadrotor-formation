# 决赛仿真报告证据层

本目录只服务于对外材料中的可复算结论。唯一主算法名称为 `ARDG-RGPC`；比较对象包括赛题官方 PID、`RA-GCA/Base`、`CAP-ADRC`、`CP-INDI`，`PP-CBF`作为独立上层编队安全监督器。

## 直接证据

- 18项代表性回归、11项预设参数、20组随机参数、三事件外力扰动和三组编队结果均链接最终算法直接结果。
- 20组随机参数与三事件外力扰动均提供官方 PID 对照。
- 两个机体系角扰动场景同时提供官方 PID 与 ARDG-RGPC 直接结果，并分别报告姿态误差、位置误差和电机总变差。
- 六组复合参数与外扰联合应力均由 ARDG-RGPC 直接运行，三次外扰事件和物理检查记录随包提供。

## 使用边界

- 不把辅助算法在个别场景的结果外推为全场景排名。
- 不把参数搜索表述为全局最优。
- 不把未由最终算法直接运行的数据归入 ARDG-RGPC 结论。
- 报告、PPT和视频中的数字应从本目录或其索引的直接源文件读取。

## 复算

在包根目录执行：

```powershell
.\RECOMPUTE_REPORT_EVIDENCE.ps1 -Check
```

重建到包外目录：

```powershell
$Out = Join-Path ([IO.Path]::GetTempPath()) 'A8_finals_report_evidence'
.\RECOMPUTE_REPORT_EVIDENCE.ps1 -OutputDirectory $Out
```
