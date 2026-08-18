[CmdletBinding()]
param()
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$Root = [IO.Path]::GetFullPath($PSScriptRoot)
. (Join-Path $Root '02_scripts/powershell/A8RuntimeResolver.ps1')
$Python = Resolve-A8MWorksPython
& $Python -B (Join-Path $Root '02_scripts/audit/verify_submission_package.py') --root $Root
if ($LASTEXITCODE -ne 0) { throw 'submission package verification failed' }
