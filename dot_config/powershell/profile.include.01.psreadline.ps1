Import-Module CompletionPredictor -ErrorAction SilentlyContinue

# Import-Module PSReadline
# Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
function OnViModeChange
{
    if ($args[0] -eq 'Command')
    {
        # Set the cursor to a block.
        Write-Host -NoNewLine "`e[2 q"
    } else
    {
        # Set the cursor to a blinking block.
        # Write-Host -NoNewLine "`e[1 q"
        # Set the cursor to a blinking underline.
        # Write-Host -NoNewLine "`e[3 q"
        # Set the cursor to a vertical line.
        Write-Host -NoNewLine "`e[6 q"
    }
}
Set-PSReadLineOption -ViModeIndicator Script -ViModeChangeHandler $Function:OnViModeChange
Set-PSReadLineOption -EditMode Vi

Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadLineOption -PredictionSource HistoryAndPlugin
Set-Psreadlineoption -PredictionViewStyle ListView
Set-PsReadLineOption -MaximumHistoryCount 10000
Set-PSReadLineOption -AddToHistoryHandler { param([string]$line) return $true }

Set-PSReadLineKeyHandler -Key Tab -Function TabCompleteNext
Set-PSReadLineKeyHandler -Key Shift+Tab -Function TabCompletePrevious
Set-PSReadLineKeyHandler -Key Ctrl+Spacebar -Function MenuComplete
Set-PSReadLineKeyHandler -Key Ctrl+D2 -Function MenuComplete

# Use [System.Console]::ReadKey() to see the keys as seen by .Net / PowerShell

# Store history file in roaming data
$consoleHistoryFolder = Join-Path $MachineConfiguration.RoamingAppDataRoot "PSReadLine"
if (-not (Test-Path $consoleHistoryFolder)) {
    New-Item -Path $consoleHistoryFolder -ItemType Directory -Force | Out-Null
}
Set-PSReadLineOption -HistorySavePath ( Join-Path $consoleHistoryFolder "ConsoleHost_history.txt" )
