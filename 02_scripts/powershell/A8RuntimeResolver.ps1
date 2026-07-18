function Get-A8SysplorerInstallRoots {
    [CmdletBinding()]
    param()
    foreach ($key in @(
        'HKCU:\SOFTWARE\TongYuan\MWORKS.Sysplorer 2026a',
        'HKLM:\SOFTWARE\TongYuan\MWORKS.Sysplorer 2026a',
        'HKLM:\SOFTWARE\WOW6432Node\TongYuan\MWORKS.Sysplorer 2026a'
    )) {
        $item = Get-ItemProperty -LiteralPath $key -ErrorAction SilentlyContinue
        if ($item -and -not [string]::IsNullOrWhiteSpace($item.InstallPath)) {
            [IO.Path]::GetFullPath([string]$item.InstallPath)
        }
    }
}

function Get-A8FixedDriveRoots {
    [CmdletBinding()]
    param()
    foreach ($drive in [IO.DriveInfo]::GetDrives()) {
        if ($drive.IsReady -and $drive.DriveType -eq [IO.DriveType]::Fixed) {
            $drive.RootDirectory.FullName
        }
    }
}

function Resolve-A8MWorksPython {
    [CmdletBinding()]
    param(
        [AllowNull()][string]$EnvironmentPath = $env:MWORKS_PYTHON,
        [AllowEmptyCollection()][string[]]$RegistryInstallRoots,
        [AllowEmptyCollection()][string[]]$FixedDriveRoots
    )
    if (-not [string]::IsNullOrWhiteSpace($EnvironmentPath)) {
        if (Test-Path -LiteralPath $EnvironmentPath -PathType Leaf) {
            return [IO.Path]::GetFullPath($EnvironmentPath)
        }
        throw @'
MWORKS_PYTHON is set but does not point to a file.
Current session:
  $env:MWORKS_PYTHON = '<Sysplorer install directory>\External\python64\python.exe'
Permanent user setting:
  [Environment]::SetEnvironmentVariable('MWORKS_PYTHON', '<full python.exe path>', 'User')
Open a new PowerShell window and run RUN_QUICK_VERIFY.ps1 again.
'@
    }
    $installRoots = if ($PSBoundParameters.ContainsKey('RegistryInstallRoots')) {@($RegistryInstallRoots)} else {@(Get-A8SysplorerInstallRoots)}
    $driveRoots = if ($PSBoundParameters.ContainsKey('FixedDriveRoots')) {@($FixedDriveRoots)} else {@(Get-A8FixedDriveRoots)}
    $candidates = [Collections.Generic.List[string]]::new()
    foreach ($root in $installRoots) {
        if (-not [string]::IsNullOrWhiteSpace($root)) {$candidates.Add((Join-Path $root 'External\python64\python.exe'))}
    }
    foreach ($root in $driveRoots) {
        if ([string]::IsNullOrWhiteSpace($root)) { continue }
        foreach ($relative in @(
            'MWORKS\Sysplorer 2026a\External\python64\python.exe',
            'Program Files\MWORKS\Sysplorer 2026a\External\python64\python.exe',
            'Program Files (x86)\MWORKS\Sysplorer 2026a\External\python64\python.exe'
        )) {$candidates.Add((Join-Path $root $relative))}
    }
    $seen = @{}
    foreach ($candidate in $candidates) {
        $full = [IO.Path]::GetFullPath($candidate)
        if ($seen.ContainsKey($full)) { continue }
        $seen[$full] = $true
        if (Test-Path -LiteralPath $full -PathType Leaf) { return $full }
    }
    throw @'
MWORKS Python was not found in MWORKS_PYTHON, the Sysplorer 2026a registry entries, or standard local-drive locations.
Current session:
  $env:MWORKS_PYTHON = '<Sysplorer install directory>\External\python64\python.exe'
Permanent user setting:
  [Environment]::SetEnvironmentVariable('MWORKS_PYTHON', '<full python.exe path>', 'User')
Open a new PowerShell window and run RUN_QUICK_VERIFY.ps1 again.
'@
}

function Resolve-A8JuliaTy {
    [CmdletBinding()]
    param([AllowNull()][string]$EnvironmentPath = $env:JULIA_TY, [switch]$SkipPathProbe)
    if (-not [string]::IsNullOrWhiteSpace($EnvironmentPath)) {
        if (Test-Path -LiteralPath $EnvironmentPath -PathType Leaf) { return [IO.Path]::GetFullPath($EnvironmentPath) }
        throw @'
JULIA_TY is set but does not point to a file.
Current session:
  $env:JULIA_TY = '<full julia-ty path>'
Permanent user setting:
  [Environment]::SetEnvironmentVariable('JULIA_TY', '<full julia-ty path>', 'User')
Open a new PowerShell window and run RUN_QUICK_VERIFY.ps1 again.
'@
    }
    if (-not $SkipPathProbe) {
        $command = Get-Command julia-ty -ErrorAction SilentlyContinue
        if ($command) {
            $path = if ($command.Path) {$command.Path} else {$command.Source}
            if ($path -and (Test-Path -LiteralPath $path -PathType Leaf)) { return [IO.Path]::GetFullPath($path) }
        }
    }
    throw @'
julia-ty was not found in JULIA_TY or PATH.
Current session:
  $env:JULIA_TY = '<full julia-ty path>'
Permanent user setting:
  [Environment]::SetEnvironmentVariable('JULIA_TY', '<full julia-ty path>', 'User')
Open a new PowerShell window and run RUN_QUICK_VERIFY.ps1 again.
'@
}
