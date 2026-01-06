# $script:BaseCompleter = (Get-Command TabExpansion2).ScriptBlock
#
# function global:TabExpansion2 {
#     param($line, $lastWord)
#
#     $results = & $script:BaseCompleter $line $lastWord
#
#     # If multiple candidates → pass through fzf
#     if ($results.CompletionMatches.Count -gt 1) {
#         $selected = $results.CompletionMatches.CompletionText | fzf
#         if ($selected) {
#             # Replace results with just the chosen one
#             $results.CompletionMatches = @(
#                 [System.Management.Automation.CompletionResult]::new(
#                     $selected, $selected, 'ParameterValue', $selected
#                 )
#             )
#         }
#         else {
#             $results.CompletionMatches = @()
#         }
#     }
#
#     return $results
# }
#

<#
.SYNOPSIS
Wraps TabExpansion2 to provide fuzzy selection via fzf when multiple completions are available.
#>
function Invoke-FuzzyTabExpansion2
{
    [CmdletBinding()]
    param()

    $line   = $null
    $cursor = 0
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState(
        [ref]$line,
        [ref]$cursor
    )

    # $beforeCursor = $line.Substring(0, $cursor)
    # $lastWord = $beforeCursor -replace '.*[ ;|&]',''

    $completion = TabExpansion2 $line $cursor

    $completionMatches = $completion.CompletionMatches
    if (-not $completionMatches -or $completionMatches.Count -eq 0)
    {
        return
    }

    if ($completionMatches.Count -eq 1)
    {
        $choice = $completionMatches[0].CompletionText
    } else
    {
        $choice = $completionMatches.CompletionText | fzf "--height=~$([Math]::Max(10, $completionMatches.Count))" --min-height=10 --reverse --prompt="$line> "
        if (-not $choice)
        {
            return
        }
    }

    # Write-Host "Replacment $($completion.ReplacmentIndex) : $($completion.ReplacementLength)"

    [Microsoft.PowerShell.PSConsoleReadLine]::Replace(
        $completion.ReplacementIndex,
        $completion.ReplacementLength,
        $choice
    )

    # $newLine =
    #     $beforeCursor.Substring(0, $beforeCursor.Length - $lastWord.Length) +
    #     $choice +
    #     $line.Substring($cursor)
    #
    # $newCursor = ($beforeCursor.Length - $lastWord.Length) + $choice.Length
    #
    # [Microsoft.PowerShell.PSConsoleReadLine]::Replace(0, $line.Length, $newLine)
    # [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($newCursor)
}

if ($IsLinux)
{
    Set-PSReadLineKeyHandler -Key Ctrl+Spacebar -ScriptBlock { Invoke-FuzzyTabExpansion2 } -BriefDescription "Fuzzy Tab Completion" -Description "Invoke Fuzzy Tab Completion using fzf"
} else
{
    # On windows when run through PSReadline keyhandler input and output is redirected
    # This means fzf defaults to its fallback behavior and uses the full screen which can be a jarring experience
    # So use alternative keybinding to offer both experiences
    Set-PSReadLineKeyHandler -Chord Ctrl+Spacebar -Function MenuComplete
}
Set-PSReadLineKeyHandler -Chord Ctrl+. -ScriptBlock { Invoke-FuzzyTabExpansion2 } -BriefDescription "Fuzzy Tab Completion" -Description "Invoke Fuzzy Tab Completion using fzf"
Set-PSReadLineKeyHandler -Chord Ctrl+OemPeriod -ScriptBlock { Invoke-FuzzyTabExpansion2 } -BriefDescription "Fuzzy Tab Completion" -Description "Invoke Fuzzy Tab Completion using fzf"
