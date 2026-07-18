[CmdletBinding(DefaultParameterSetName = 'Build')]
param(
    [Parameter(Mandatory = $true, ParameterSetName = 'Build')]
    [ValidateNotNullOrEmpty()]
    [string]$OutputDirectory,

    [Parameter(Mandatory = $true, ParameterSetName = 'Check')]
    [switch]$Check
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$Root = [IO.Path]::GetFullPath($PSScriptRoot).TrimEnd('\', '/')
$Generator = Join-Path $Root '02_scripts/evaluation/build_report_evidence.py'
$RuntimeResolver = Join-Path $Root '02_scripts/powershell/A8RuntimeResolver.ps1'
if (-not (Test-Path -LiteralPath $Generator -PathType Leaf)) {
    throw 'Report evidence generator is missing.'
}
if (-not (Test-Path -LiteralPath $RuntimeResolver -PathType Leaf)) { throw 'Runtime resolver is missing.' }
. $RuntimeResolver

# 与主入口共用MWORKS Python，避免解释器和依赖版本不一致。
$Python = Resolve-A8MWorksPython

# 重建模式仅允许写入包外目录；检查模式不产生新文件。
if ($Check) {
    # 检查模式只比对现有证据，不创建或覆盖任何文件。
    & $Python -B $Generator --check
} else {
    $Output = [IO.Path]::GetFullPath($OutputDirectory).TrimEnd('\', '/')
    $RootPrefix = $Root + [IO.Path]::DirectorySeparatorChar
    if (
        $Output.Equals($Root, [StringComparison]::OrdinalIgnoreCase) -or
        $Output.StartsWith($RootPrefix, [StringComparison]::OrdinalIgnoreCase)
    ) {
        throw 'OutputDirectory must be outside the source package.'
    }
    & $Python -B $Generator --output-dir $Output
}

if ($LASTEXITCODE -ne 0) {
    throw "Report evidence operation failed with exit code $LASTEXITCODE."
}
