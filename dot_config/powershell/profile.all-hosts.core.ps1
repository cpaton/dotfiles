<#
.SYNOPSIS
Main logic of all hosts profile
#>

# Core bootstrap
if (-not (Test-Path env:HOME)) {
    Write-Verbose "Setting HOME environment variable..."
    $env:HOME = Resolve-Path ~
}

if (-not (Test-Path $MachineConfiguration.PowerShell.LocalModulesRoot)) {
    Write-Verbose "Creating PowerShell local modules root"
    New-Item -Path $MachineConfiguration.PowerShell.LocalModulesRoot -ItemType Directory -Force | Out-Null
}
$environmentVariablePathSeparator = ";"
if ($IsLinux) {
    $environmentVariablePathSeparator = ":"
}
if (-not ($env:PSModulePath.StartsWith($MachineConfiguration.PowerShell.LocalModulesRoot))) {
    $env:PSModulePath = "$($MachineConfiguration.PowerShell.LocalModulesRoot)$($environmentVariablePathSeparator)$($env:PSModulePath)"
}

# ensure XDG_CONFIG_HOME is set
if (-not (Test-Path env:XDG_CONFIG_HOME)) {
    Add-Content -Path $logPath -Value "Setting XDG_CONFIG_HOME to $($machineConfiguration.ConfigRoot)"
    $env:XDG_CONFIG_HOME = $MachineConfiguration.ConfigRoot
}

# Load include flies
$includes = Get-ChildItem -Path $PSScriptRoot -File -Filter profile.include.*.ps1 | Sort-Object -Property Name
foreach ( $script in $includes ) {
    if ($env:POWERSHELL_PROFILE_DEBUG) {
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        Write-Host "[$([datetime]::Now.ToString("o"))] Importing $($script.FullName)..."
    }
    # . Invoke-Expression ( [io.file]::ReadAllText($script.FullName) )
    . $script.FullName
    if ($env:POWERSHELL_PROFILE_DEBUG) {
        $sw.Stop()
        Write-Host "[$([datetime]::Now.ToString("o"))] Imported $($script.FullName) ($($sw.ElapsedMilliseconds.ToString("#,#")))"
    }
}

$isTmux = $null -ne $env:TMUX
if (-not $isTmux) {
    # Write-Host "OUTSIDE - PWD: $PWD CWD: $((get-item /proc/$PID/cwd).ResolvedTarget)"
    Set-Location $MachineConfiguration.InitialDirectory
}
else {
    # Write-Host "TMUX - PWD: $PWD CWD: $((get-item /proc/$PID/cwd).ResolvedTarget)"
}
