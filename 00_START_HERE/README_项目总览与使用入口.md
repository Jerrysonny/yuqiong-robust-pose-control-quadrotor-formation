# 项目总览与使用入口

## 1. 项目定位

本项目面向A8四旋翼无人机位姿控制系统设计优化赛题，提供完整MWORKS模型、控制器、场景包装、Sysplorer运行器、Syslab指标实现、测试和可追溯结果证据。

当前正式主算法：

- 中文名：置信门控悬停推力估计增强的约化姿态几何控制与约束感知分配算法。
- 英文名：Reduced-Attitude Geometric Control with Constraint-Aware Allocation Enhanced by Confidence-Gated Hover-Thrust Estimation。
- 简称：`RA-GCA-CGHTE`。
- 正式类：`A8FormalRAGCACGHTE_20260715`。
- 控制范围：约化姿态、无偏航控制。

历史V8控制器仅用于回归核对和工程回滚。`PP-CBF`是独立的三机编队上层安全监督器，不属于低层主控制器的改名版本。

## 2. 运行环境

- MWORKS Sysplorer 2026a。
- MWORKS Syslab 2026a与`julia-ty`。
- Windows PowerShell 5.1或更高版本。
- 建议可用内存16 GB及以上。

本源文件夹不包含MWORKS商业运行时。脚本优先读取`MWORKS_PYTHON`，随后查询Sysplorer 2026a安装注册表和本地固定磁盘上的标准安装目录；`julia-ty`优先读取`JULIA_TY`，随后查询`PATH`。

自动探测失败时，可先按实际安装位置设置当前PowerShell会话：

```powershell
$env:MWORKS_PYTHON = '<Sysplorer安装目录>\External\python64\python.exe'
$env:JULIA_TY = '<julia-ty完整路径>'
```

需要长期使用时，将相同路径写入当前用户环境变量，然后重新打开PowerShell：

```powershell
[Environment]::SetEnvironmentVariable('MWORKS_PYTHON', $env:MWORKS_PYTHON, 'User')
[Environment]::SetEnvironmentVariable('JULIA_TY', $env:JULIA_TY, 'User')
```

尖括号内容必须替换为本机实际路径。

## 3. 目录浏览

- `01_models`：官方四旋翼模型、正式主控制器、场景包装、PID、V8、PP-CBF和精选辅助对照。
- `02_scripts`：Sysplorer运行、Syslab评价、构建器、审计与可视化脚本。
- `config`：主算法、场景、求解器和指标合同。
- `04_results/report_evidence`：报告可引用指标、边界说明、来源快照和证据哈希。
- `05_visuals`：3张发布静态图、28张最终报告图、6个单主题GIF，以及图件源数据和生成来源。
- `06_supplementary_evidence`：32个项目回归场景的主算法/V8配对raw，共64个CSV。
- `test`：正式发布、报告证据、可视化和入口合同测试。
- `08_provenance`：来源、依赖、版权与许可证状态、最终图表索引、材料准入表和复制映射。

## 4. 推荐入口

只读静态验收：

```powershell
.\RUN_QUICK_VERIFY.ps1
```

完整主控制器场景运行：

```powershell
$Output = Join-Path $env:USERPROFILE 'A8_runs\Scene04'
.\RUN_ALL.ps1 -Mode Simulate -Scene Scene04 -Output $Output
```

只读校验报告证据：

```powershell
.\RECOMPUTE_REPORT_EVIDENCE.ps1 -Check
```

`Simulate`和`All`模式必须显式提供包外绝对输出目录，包内输出会被拒绝。批量运行32个注册场景会消耗较长时间，并要求已经启动且仅保留一个Sysplorer实例。运行器不会调用`ClearAll`或`ChangeDirectory`，也不会自动启动或关闭Sysplorer。

## 5. 模型加载顺序

1. `01_models/official/QuadrotorModel/package.mo`。
2. `01_models/dependencies/A8FormalPidTwin/package.mo`与编队依赖。
3. `01_models/sysblock`中的正式主控制器及PP-CBF组件。
4. `01_models/modelica`中的对应场景包装。
5. 由`02_scripts/sysplorer/run_main_controller.py`按所选场景加载和运行。

辅助对照模型位于`01_models/comparators`，其直接验证范围见`ALGORITHM_REGISTRY.csv`。这些模型不参与默认主算法加载。

## 6. 接口与固定参数

正式控制器输入为11维参考、18维状态和2维分配约束，输出4路电机命令及16维诊断。采样周期为0.01 s。

固定增强参数：

- 激活协方差阈值：0.00253218969247675。
- 激活持续时间：0.10 s。
- 尺度应用速率：0.868 s^-1。
- 每步尺度变化上限：0.00868。

正式发布禁止从命令行覆盖这些参数。

## 7. 结果与声明边界

32项配对数据是项目内部建立的完整回归集。每个场景包含当前主算法和V8各一份Sysplorer时序CSV。

配对矩阵中32/32场景通过同条件配对门、物理门和覆盖门；预先冻结的高标准参数保持比总门未通过。因此本包不把该数据表述为“全部决选门通过”或“所有指标全面优于V8”。用户结合A8官方目标、已知场景表现和工程价值，正式确定`RA-GCA-CGHTE`为主算法。

`04_results/report_evidence`将五对象公共比较、参数变化、外扰取舍、复合应力代价和PP-CBF安全指标整理为结构化底稿。V30、H60、Wilson下界和配对bootstrap尚未完成，证据层不会将其写成已通过。最终报告28幅图和26张编号表均已在`FINAL_REPORT_ASSET_INDEX.csv`中登记来源。

## 8. 已知边界

- 控制器采用约化姿态无偏航口径。
- CAP-ADRC和CP-INDI只在五个公共单机场景中直接验证。
- RA-GCA/Base只有四个公共场景直接证据。
- 补充raw不替代官方模型、运行脚本和指标合同。
- 正式开源许可证尚未确定，详见`08_provenance/版权与许可证状态.md`。
