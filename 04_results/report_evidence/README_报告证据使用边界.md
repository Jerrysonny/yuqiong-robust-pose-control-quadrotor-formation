# 报告证据层使用边界

本目录把分散的权威指标整理为可复算、可追溯的报告数据底稿。正式主算法统一显示为 `RA-GCA-CGHTE`；`RA-GCA/V8`仅作为版本消融与回滚基线，`PP-CBF`是独立上层安全监督器。

## 阅读顺序

1. `01_five_controller_scene_coverage.csv`：先确认每种算法实际覆盖了哪些场景。
2. `02_standard_step_pid_vs_main.csv`与`03_five_controller_common_scenes.csv`：查看官方基线和五对象公共比较。
3. `04_algorithm_evolution_ablation.csv`与`05_parameter_11_paired.csv`：查看Base、V8、正式主算法的演进及参数鲁棒性证据。
4. `06_project_regression_32_summary.json`：查看32项项目回归集汇总和未完成边界。
5. `07_disturbance_tradeoff.csv`、`08_compound_stress_tradeoff.csv`、`09_formation_pp_cbf.csv`：查看局部优势、代价与安全收益。
6. `10_claim_evidence_index.csv`：从报告结论回溯到raw、生成脚本和哈希清单。

## 关键边界

- 32项是项目内部回归集，不是比赛官方规定的32项测试。
- 32/32逐项配对门通过，但预注册参数保持目标未通过，`required_parameter_retention=false`必须保留。
- V30、H60、Wilson下界和配对bootstrap尚未完成，不得写成已通过。
- 三事件外扰中，`CP-INDI`的RMSE为`0.0621232821298252 m`，优于正式主算法约`0.294903761473424 m`；该局部优势不得删去或模糊。
- 复合应力结果支持“RMSE改善伴随部分峰值或恢复时间代价”，不支持“所有指标全面优于”。
- 编队结果中，`formation_rmse_m`是FormationMetricsV8定义的队形误差RMSE硬门指标；“三机全局位置跟踪RMSE”是另一项跟踪指标，两者不得混写。
- 五对象公共对照和复合应力指标来自本目录最小规范化快照；后续复算只依赖包内文件。

## 复算与校验

在包根目录执行以下命令，将证据重建到显式指定的包外目录：

```powershell
$Out = Join-Path ([IO.Path]::GetTempPath()) 'A8_report_evidence_recomputed'
.\RECOMPUTE_REPORT_EVIDENCE.ps1 -OutputDirectory $Out
```

只校验包内冻结证据且不写入包内：

```powershell
.\RECOMPUTE_REPORT_EVIDENCE.ps1 -Check
```

生成器会核对64份raw的SHA256。只有维护者显式调用Python生成器的`--build-package-evidence`模式时才允许重建本目录；普通复算拒绝输出到源文件包内部。

`REPORT_EVIDENCE_MANIFEST.json`记录本层输入与输出哈希，但按定义不包含其自身哈希。
