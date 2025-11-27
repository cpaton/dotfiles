# Convention to use Ctrl+s as the prefix for custom key bindings
# Use [System.Console]::ReadKey() to see the keys as seen by .Net / PowerShell

<#
.SYNOPSIS
Copy the current path to the clipboard.
#>
function Copy-CurrentPath() {
    [CmdletBinding()]
    param()

    $clipboardArgs = @{}
    if (Test-Path env:TMUX) {
        $clipboardArgs['AsOSC52'] = $true
    }

    Set-Clipboard -Value ($ExecutionContext.SessionState.Path.CurrentLocation.Path) @clipboardArgs
}
Set-PSReadLineKeyHandler -Chord 'Ctrl+s,c' `
    -ScriptBlock { Copy-CurrentPath } `
    -BriefDescription 'copy path' `
    -Description 'Copy current path'

$env:VISUAL="nvim"
Set-PSReadLineKeyHandler -Key 'Ctrl+s,e' -Function ViEditVisually

