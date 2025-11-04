# Configuration
$machineConfig = @{}
New-Variable -Name "MachineConfiguartion" -Value $machineConfig -Scope Global -Force

$machineConfig.InitialDirectory = Resolve-Path ~
$machineConfig.ConfigRoot = Join-Path ( Resolve-Path ~ ) ".config"
$machineConfig.GitRoot = Join-Path ~ "git"


if ($IsWindows) {
    if (Test-Path C:\_cp) {
        $machineConfig.InitialDirectory = 'C:\_cp'
        $machineConfig.GitRoot = 'C:\_cp'
    }
}

$machineConfig.PowerShell = @{
    ConfigRoot = Join-Path $machineConfig.ConfigRoot "powershell"
}
$machineConfig.PowerShell.LocalModulesRoot = Join-Path $machineConfig.PowerShell.ConfigRoot "modules-local"

# Core bootstrap
if (-not (Test-Path env:HOME)) {
    Write-Verbose "Setting HOME environment variable..."
    $env:HOME = Resolve-Path ~
}

if (-not (Test-Path $machineConfig.PowerShell.LocalModulesRoot)) {
    Write-Verbose "Creating PowerShell local modules root"
    New-Item -Path $machineConfig.PowerShell.LocalModulesRoot -ItemType Directory -Force | Out-Null
}
$environmentVariablePathSeparator = ";"
if ($IsLinux) {
    $environmentVariablePathSeparator = ":"
}
$env:PSModulePath = "$($machineConfig.PowerShell.LocalModulesRoot)$($environmentVariablePathSeparator)$($env:PSModulePath)"

# Use XDG_CONFIG_HOME if set
if (-not (Test-Path env:XDG_CONFIG_HOME)) {
    $env:XDG_CONFIG_HOME = Join-Path ( Resolve-Path ~ ) ".config"
}

# Load include flies
$includes = Get-ChildItem -Path $PSScriptRoot -Filter profile.include.*.ps1 | Sort-Object -Property Name
foreach ( $script in $includes ) {
    Write-Verbose "Importing $($script.FullName)..."
    # . Invoke-Expression ( [io.file]::ReadAllText($script.FullName) )
    . $script.FullName
}

# Modules
Import-Module Terminal-Icons -ErrorAction SilentlyContinue
Import-Module posh-git -ErrorAction SilentlyContinue

# Initial prompt
oh-my-posh --init --shell pwsh --config ( Join-Path $machineConfig.ConfigRoot "oh-my-posh/shell.omp.json" ) | Invoke-Expression

if ($IsLinux) {
    $originalPrompt = (Get-Command prompt).ScriptBlock
    function prompt {
        # Set the process current working directory as this doesn't happen by default on Linux
        # which means tools like tmux-ressurect won't restore the correct directory
        if ($ExecutionContext.SessionState.Path.CurrentLocation.Provider.Name -eq "FileSystem") {
            [System.Environment]::CurrentDirectory = $ExecutionContext.SessionState.Path.CurrentLocation.Path
        }
        & $originalPrompt
    }
}

$isTmux = $null -ne $env:TMUX
if (-not $isTmux) {
    # Write-Host "OUTSIDE - PWD: $PWD CWD: $((get-item /proc/$PID/cwd).ResolvedTarget)"
    Set-Location $machineConfig.InitialDirectory
}
else {
    # Write-Host "TMUX - PWD: $PWD CWD: $((get-item /proc/$PID/cwd).ResolvedTarget)"
}
