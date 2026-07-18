[CmdletBinding()]
param()
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$Root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$Resolver = Join-Path $Root '02_scripts\powershell\A8RuntimeResolver.ps1'
if (-not (Test-Path -LiteralPath $Resolver -PathType Leaf)) { throw 'Runtime resolver is missing.' }
. $Resolver
function Assert-A8Equal([string]$Expected, [string]$Actual, [string]$Message) {if (-not $Expected.Equals($Actual,[StringComparison]::OrdinalIgnoreCase)){throw "$Message Expected=$Expected Actual=$Actual"}}
function Assert-A8True([bool]$Condition,[string]$Message){if(-not $Condition){throw $Message}}
$originalMWorksPython=$env:MWORKS_PYTHON
$originalJuliaTy=$env:JULIA_TY
$tempBase=[IO.Path]::GetFullPath([IO.Path]::GetTempPath())
$tempRoot=Join-Path $tempBase ('A8_runtime_resolution_'+[Guid]::NewGuid().ToString('N'))
try {
    [IO.Directory]::CreateDirectory($tempRoot)|Out-Null
    $explicitPython=Join-Path $tempRoot 'explicit\python.exe';[IO.Directory]::CreateDirectory((Split-Path $explicitPython -Parent))|Out-Null;[IO.File]::WriteAllBytes($explicitPython,[byte[]](1))
    $resolved=Resolve-A8MWorksPython -EnvironmentPath $explicitPython -RegistryInstallRoots @() -FixedDriveRoots @();Assert-A8Equal ([IO.Path]::GetFullPath($explicitPython)) $resolved 'Explicit MWORKS_PYTHON was not preferred.'
    $invalidMessage=$null;try{Resolve-A8MWorksPython -EnvironmentPath (Join-Path $tempRoot 'missing\python.exe') -RegistryInstallRoots @() -FixedDriveRoots @()}catch{$invalidMessage=$_.Exception.Message};Assert-A8True ($invalidMessage -and $invalidMessage.Contains('SetEnvironmentVariable')) 'Invalid MWORKS_PYTHON guidance is incomplete.'
    $registryRoot=Join-Path $tempRoot 'registry\Sysplorer 2026a';$registryPython=Join-Path $registryRoot 'External\python64\python.exe';[IO.Directory]::CreateDirectory((Split-Path $registryPython -Parent))|Out-Null;[IO.File]::WriteAllBytes($registryPython,[byte[]](2));$resolved=Resolve-A8MWorksPython -EnvironmentPath $null -RegistryInstallRoots @($registryRoot) -FixedDriveRoots @();Assert-A8Equal ([IO.Path]::GetFullPath($registryPython)) $resolved 'Registry root was not resolved.'
    $driveRoot=Join-Path $tempRoot 'drive';$drivePython=Join-Path $driveRoot 'MWORKS\Sysplorer 2026a\External\python64\python.exe';[IO.Directory]::CreateDirectory((Split-Path $drivePython -Parent))|Out-Null;[IO.File]::WriteAllBytes($drivePython,[byte[]](3));$resolved=Resolve-A8MWorksPython -EnvironmentPath $null -RegistryInstallRoots @() -FixedDriveRoots @($driveRoot);Assert-A8Equal ([IO.Path]::GetFullPath($drivePython)) $resolved 'Fixed-drive root was not resolved.'
    $env:MWORKS_PYTHON=$null;$resolved=Resolve-A8MWorksPython;Assert-A8True (Test-Path -LiteralPath $resolved -PathType Leaf) 'Automatic MWORKS Python discovery failed.'
    $explicitJulia=Join-Path $tempRoot 'julia\julia-ty.bat';[IO.Directory]::CreateDirectory((Split-Path $explicitJulia -Parent))|Out-Null;[IO.File]::WriteAllText($explicitJulia,'@echo off');$resolved=Resolve-A8JuliaTy -EnvironmentPath $explicitJulia -SkipPathProbe;Assert-A8Equal ([IO.Path]::GetFullPath($explicitJulia)) $resolved 'Explicit JULIA_TY was not preferred.'
    $env:JULIA_TY=$null;$resolved=Resolve-A8JuliaTy;Assert-A8True (Test-Path -LiteralPath $resolved -PathType Leaf) 'julia-ty PATH discovery failed.'
    Write-Output 'runtime_resolution_tests=pass'
} finally {
    [Environment]::SetEnvironmentVariable('MWORKS_PYTHON',$originalMWorksPython,'Process');[Environment]::SetEnvironmentVariable('JULIA_TY',$originalJuliaTy,'Process')
    if(Test-Path -LiteralPath $tempRoot -PathType Container){$resolvedTemp=[IO.Path]::GetFullPath($tempRoot);if(-not $resolvedTemp.StartsWith($tempBase,[StringComparison]::OrdinalIgnoreCase)-or $resolvedTemp.Length -le $tempBase.Length){throw 'Refusing to remove an unexpected runtime-test path.'};[IO.Directory]::Delete($resolvedTemp,$true)}
}
