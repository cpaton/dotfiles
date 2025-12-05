# Configuration
$machineConfig = . ( Join-Path $PSScriptRoot "machine-config.ps1" )
New-Variable -Name "MachineConfiguration" -Value $machineConfig -Scope Global -Force

# $env:POWERSHELL_PROFILE_DEBUG = 1

if ($env:POWERSHELL_PROFILE_DEBUG) {
    $logFolder = Split-Path -Path $MachineConfiguration.PowerShell.ProfileLogPath -Parent
    if (-not (Test-Path $logFolder)) {
        New-Item -ItemType Directory -Path $logFolder -Force | Out-Null
    }
    Add-Content `
        -Path $MachineConfiguration.Powershell.ProfileLogPath `
        -Value "[$([datetime]::Now.ToString("o"))] Profile starting..."
}

# XDG Environment setup
if (-not (Test-Path -Path env:XDG_CONFIG_HOME)) {
    $env:XDG_CONFIG_HOME = $MachineConfiguration.ConfigRoot
}
if (-not (Test-Path -Path env:XDG_DATA_HOME)) {
   $env:XDG_DATA_HOME = $MachineConfiguration.LocalAppDataRoot
}
if (-not (Test-Path -Path env:XDG_CACHE_HOME)) {
    $env:XDG_CACHE_HOME = $MachineConfiguration.CacheRoot
}
if (-not (Test-Path -Path env:XDG_STATE_HOME)) {
    $env:XDG_STATE_HOME = $MachineConfiguration.StateRoot
}

# Looking to optimize profile loading to get to an interactive prompt as soon as possible
# Some profile stuff is needed, but not immediately, so can that initialization be run in the background?
# This is trickier than it would seem due to scoping rules within PowerShell - see resources for more info
#
# - https://fsackur.github.io/2023/11/20/Deferred-profile-loading-for-better-performance/
# - https://devblogs.microsoft.com/powershell/optimizing-your-profile/
#
# For example this separate space in terms of variables, functions, aliases etc
# $script:AsyncRunspace = [runspacefactory]::CreateRunspace()
# $script:AsyncRunspace.Open()
# $script:AsyncRunspace.SessionStateProxy.SetVariable('MachineConfiguration', $MachineConfiguration)
#
# $ps = [powershell]::Create()
# $ps.Runspace = $script:AsyncRunspace
# $ps.AddScript({
#     param($ProfilePath)
#
#     . $ProfilePath
# }) | Out-Null
# $ps.AddArgument( ( Join-Path $PSScriptRoot "profile.all-hosts.runspace.ps1" ) ) | Out-Null
# $ps.BeginInvoke() | Out-Null

$backgroundSessionState = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
$backgroundSessionState.Variables.Add(
    (New-Object System.Management.Automation.Runspaces.SessionStateVariableEntry `
        'MachineConfiguration', $MachineConfiguration, 'Shared machine config')
)

# Run background initialization scripts one at a time in the background
$backgroundJobsExecutor = [runspacefactory]::CreateRunspacePool(1, 1, $backgroundSessionState, $Host)
$backgroundJobsExecutor.Open()
$script:asyncScripts = [System.Collections.ArrayList]::Synchronized((New-Object System.Collections.ArrayList))

<#
.SYNOPSIS
Helper function for performing cached initialization of a PowerShell session.
Initialization code is run in the background which should create a script to initializatize the PowerShell session
This script is cached and then run directly next time synchronously, as well as refreshed in the background
#>
function __ProfileCachedInitialization {
    param(
        # Logical name of the initialization
        [Parameter(Mandatory, Position = 0)]
        [string]
        $CacheKey,
        # Initialization logic.  Should return strings representing PowerShell code to initialize the session
        [Parameter(Mandatory, Position = 1)]
        [scriptblock]
        $ScriptBlock
    )

    if (-not (Test-Path $MachineConfiguration.PowerShell.CacheRoot)) {
        New-Item -ItemType Directory -Path $MachineConfiguration.PowerShell.CacheRoot -Force | Out-Null
    }

    # If we have cached output from a previous run execute it now in the current scope
    # This allows this to run in Global scope avoiding some of the nastiness around argument completers for example
    $cachePath = Join-Path $MachineConfiguration.PowerShell.CacheRoot "profile-cache-$($CacheKey).ps1"
    if (Test-Path $cachePath) {
        . $cachePath
    }

    # Given scriptblock should return strings representing the script to run during normal profile initialization
    # We store this output into a file to run next time
    $wrapper = [scriptblock]::Create({
        param(
            [Parameter(Mandatory, Position = 0)]
            [string]
            $CacheKey,
            [Parameter(Mandatory, Position = 1)]
            [string]
            $CachePath,
            [Parameter(Mandatory, Position = 2)]
            [string]
            $initialization,
            [Parameter(Mandatory, Position = 3)]
            [string]
            $ProfileLogPath
        )

        try {
            $results = Invoke-Expression $initialization
            $results | Out-File -FilePath $cachePath -Encoding UTF8 -Force
        }
        catch {
            Add-Content `
                -Path $ProfileLogPath `
                -Value "[$([datetime]::Now.ToString("o"))] Error caching profile initialization for key $($CacheKey) : $_"
        }
    })

    # Run the script block in the background
    $ps = [powershell]::Create()
    $ps.RunspacePool = $backgroundJobsExecutor
    $ps.AddScript($wrapper.ToString()).AddArgument($CacheKey).AddArgument($cachePath).AddArgument($ScriptBlock.ToString()).AddArgument($MachineConfiguration.PowerShell.ProfileLogPath) | Out-Null
    $handle = $ps.BeginInvoke()
    $jobRecord = [PSCustomObject]@{
        CacheKey            = $CacheKey
        PowerShellInstance = $ps
        Handle             = $handle
    }
    $script:asyncScripts.Add($jobRecord) | Out-Null
}

<#
.SYNOPSIS
Performs background initialization of a PowerShell session during idle time.
#>
function __ProfileOnIdleInitialization() {
    [CmdletBinding()]
    param(
        # Logical name of the initialization
        [Parameter(Mandatory, Position = 0)]
        [string]
        $Key,
        # Initialization logic.
        [Parameter(Mandatory, Position = 1)]
        [scriptblock]
        $Initialization
    )

    $wrapped = [scriptblock]::Create(@"
        try {
            & ([scriptblock]::Create('$($Initialization.ToString())'))
        }
        catch {
            Add-Content ``
                -Path '$($MachineConfiguration.PowerShell.ProfileLogPath)' ``
                -Value "[`$([datetime]::Now.ToString("o"))] Error caching profile initialization for key $($Key) : `$_"
        }
"@)

    Register-EngineEvent -SourceIdentifier "PowerShell.OnIdle" -MaxTriggerCount 1 -SupportEvent -Action $wrapped | Out-Null
}

. ( Join-Path $PSScriptRoot "profile.all-hosts.core.ps1" )

# if we didn't run any background jobs no need for the more complicated logic below
if ($script:asyncScripts.Length -le 0) {
    return
}

# To properly cleanup the background initialization temporarily wrap the prompt function
# to check when all jobs have completed and then run cleanup logic

if (-not (Test-Path function:\__OriginalPrompt)) {
    Copy-Item function:\prompt function:\__OriginalPrompt
}

$script:originalPromptWithoutBackgroundProcessing = (Get-Command prompt).ScriptBlock
function prompt {
    $completed = @()
    foreach ($job in @($script:asyncScripts)) {
        if ($job.PowerShellInstance -and $job.Handle.IsCompleted) {
            if ($env:POWERSHELL_PROFILE_DEBUG) {
                Write-Warning "Job $($job.CacheKey) has finished"
            }
            try {
                $completed += $job
                $job.PowerShellInstance.EndInvoke($job.Handle) | Out-Null
            }
            catch {
                Write-Warning "Error executing $($job.CacheKey): $_"
            }
            finally {
                $job.PowerShellInstance.Dispose()
            }
        }
    }

    # Remove completed jobs
    foreach ($c in $completed) {
        $script:asyncScripts.Remove($c) | Out-Null
    }

    # Restore original prompt if queue is empty
    if ($script:asyncScripts.Count -eq 0) {
        try {
            if ($env:POWERSHELL_PROFILE_DEBUG) {
                Write-Warning "Restoring original prompt function..."
            }
            Copy-Item function:\__OriginalPrompt function:\prompt -Force

            $backgroundJobsExecutor.Close()
            $backgroundJobsExecutor.Dispose()
            Remove-Variable -Name backgroundJobsExecutor
        }
        catch {
            Write-Warning "Error restoring original prompt: $_"
        }
    }

    # Render normal prompt
    & script:__OriginalPrompt
}
