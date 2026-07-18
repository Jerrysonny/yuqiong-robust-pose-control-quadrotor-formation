# 核心结果与复算说明

本目录保持精简：`release_regression_6`保存6个代表场景的干净会话逐字节复现摘要，`report_evidence`保存报告可引用的结构化证据。完整时序CSV只在`06_supplementary_evidence`保存一份。

## 推荐入口

- `report_evidence/README_报告证据使用边界.md`：阅读顺序和声明边界。
- `report_evidence/REPORT_EVIDENCE_MANIFEST.json`：证据输入与输出哈希。
- `RECOMPUTE_REPORT_EVIDENCE.ps1 -Check`：只读校验冻结证据。
- `RECOMPUTE_REPORT_EVIDENCE.ps1 -OutputDirectory <包外绝对路径>`：在包外确定性重建。

32项配对矩阵由`02_scripts/syslab/run_campaign_evaluation.jl`复算；该入口要求V8、正式主算法raw目录和包外输出目录。其结果是项目回归证据，不是官方规定的32项测试。

`02_scripts/evaluation/evaluate_manifest_campaign.py`服务于尚未完成的开发/验证/留出统计流程，不是当前32项报告证据的复算入口，禁止据此声称V30、H60、Wilson或bootstrap已经完成。
