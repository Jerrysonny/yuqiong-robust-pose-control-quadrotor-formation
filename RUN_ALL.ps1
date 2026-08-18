[CmdletBinding()]
param(
    [ValidateSet('Precheck', 'Simulate', 'All')]
    [string]$Mode = 'Precheck',
    [int]$Port = 49152,
    [string[]]$Scene = @(),
    [ValidateSet('finals_core', 'regression18', 'supplementary', 'full_registered')]
    [string]$Suite = 'finals_core',
    [string]$Output
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$Root = [IO.Path]::GetFullPath($PSScriptRoot)
$RuntimeResolver = Join-Path $Root '02_scripts/powershell/A8RuntimeResolver.ps1'
if (-not (Test-Path -LiteralPath $RuntimeResolver -PathType Leaf)) { throw 'Runtime resolver is missing.' }
. $RuntimeResolver

# 仿真结果必须写到包外目录，避免污染提交源文件和冻结证据。
function Invoke-Precheck {
    & (Join-Path $Root 'RUN_QUICK_VERIFY.ps1')
}

function Resolve-ExternalOutput {
    # 输出目录必须位于封包外，防止仿真结果改变提交文件集合。
    if ([string]::IsNullOrWhiteSpace($Output)) {
        throw '-Output is required for Simulate and All modes and must point outside the source package.'
    }
    if (-not [IO.Path]::IsPathRooted($Output)) {
        throw '-Output must be an absolute path outside the source package.'
    }
    $outputPath = [IO.Path]::GetFullPath($Output)
    $packagePrefix = $Root.TrimEnd([IO.Path]::DirectorySeparatorChar) + [IO.Path]::DirectorySeparatorChar
    if ($outputPath.Equals($Root, [StringComparison]::OrdinalIgnoreCase) -or
        $outputPath.StartsWith($packagePrefix, [StringComparison]::OrdinalIgnoreCase)) {
        throw '-Output must not be the source package or any directory inside it.'
    }
    return $outputPath
}

function Invoke-Simulate([string]$Python, [string]$OutputPath) {
    # 显式场景优先；未指定时运行经批准的20项决赛核心套件。
    $arguments = @(
        '-B',
        (Join-Path $Root '02_scripts/sysplorer/run_main_controller.py'),
        '--workspace', $Root,
        '--port', [string]$Port,
        '--output', $OutputPath
    )
    foreach ($item in $Scene) {
        $arguments += @('--scene', $item)
    }
    if ($Scene.Count -eq 0) {
        $arguments += @('--scene', $Suite)
    }
    & $Python @arguments
    if ($LASTEXITCODE -ne 0) { throw 'main-controller simulation failed' }
}

$Python = Resolve-A8MWorksPython
# Simulate和All均先执行完整预检，区别保留给后续流程扩展。
switch ($Mode) {
    'Precheck' { Invoke-Precheck }
    'Simulate' { $OutputPath = Resolve-ExternalOutput; Invoke-Precheck; Invoke-Simulate $Python $OutputPath }
    'All' { $OutputPath = Resolve-ExternalOutput; Invoke-Precheck; Invoke-Simulate $Python $OutputPath }
}
