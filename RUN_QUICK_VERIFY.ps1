[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$Root = [IO.Path]::GetFullPath($PSScriptRoot)
$RuntimeResolver = Join-Path $Root '02_scripts/powershell/A8RuntimeResolver.ps1'
if (-not (Test-Path -LiteralPath $RuntimeResolver -PathType Leaf)) { throw 'Runtime resolver is missing.' }
. $RuntimeResolver

# Python和Julia分别承担静态检查与Syslab指标复算。
$Python = Resolve-A8MWorksPython
$Julia = Resolve-A8JuliaTy

& (Join-Path $Root 'test/test_runtime_resolution.ps1')

# 快速验收只读取冻结材料，依次检查Python、Syslab、证据、图件和整包清单。
$PythonTests = @(
    'test/test_release_static.py',
    'test/test_report_evidence.py',
    'test/test_report_visuals.py',
    'test/test_evidence_entrypoints.py'
)
foreach ($Test in $PythonTests) {
    # 任一子检查失败立即停止，不继续掩盖后续错误。
    & $Python -B (Join-Path $Root $Test)
    if ($LASTEXITCODE -ne 0) { throw "Python verification failed: $Test" }
}

# 先检查指标模块，再检查五控制器证据和最终图件。
& $Julia (Join-Path $Root 'test/test_campaign_package.jl')
if ($LASTEXITCODE -ne 0) { throw 'Syslab campaign metric tests failed' }

& $Julia (Join-Path $Root '02_scripts/syslab/build_five_scene_comparison.jl') --check
if ($LASTEXITCODE -ne 0) { throw 'five-controller evidence check failed' }

& (Join-Path $Root 'RECOMPUTE_REPORT_EVIDENCE.ps1') -Check
& $Python -B (Join-Path $Root '05_visuals/verify_final_report_assets.py') --check
if ($LASTEXITCODE -ne 0) { throw 'final report visual check failed' }

& $Python -B (Join-Path $Root '02_scripts/audit/package_audit.py') --root $Root --verify-manifest
if ($LASTEXITCODE -ne 0) { throw 'package audit failed' }
