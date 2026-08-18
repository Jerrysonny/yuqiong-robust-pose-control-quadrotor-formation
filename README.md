# 驭穹稳控：四旋翼鲁棒位姿控制与编队安全仿真

本包提供MWORKS模型、ARDG-RGPC主控制器、34项注册场景、运行脚本、仿真报告、正式图表、动画和可追溯实验结果。

首次使用请阅读`00_START_HERE/README_项目总览与使用入口.md`。只读预检执行：

```powershell
.\RUN_ALL.ps1 -Mode Precheck
```

单场景仿真示例：

```powershell
$Output = Join-Path $env:USERPROFILE 'A8_runs\BODY_ROLL_POS'
.\RUN_ALL.ps1 -Mode Simulate -Scene BODY_ROLL_POS -Output $Output
```

仿真输出必须写入本包之外的目录，避免改变提交文件和冻结证据。

用户手册：`用户手册_驭穹稳控_基于MWORKS的四旋翼鲁棒位姿控制与编队安全仿真.docx`。
