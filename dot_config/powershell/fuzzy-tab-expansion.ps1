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

function Invoke-FuzzyTabExpansion {
    [CmdletBinding()]
    param()

    $line   = $null
$cursor = 0

[Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState(
    [ref]$line,
    [ref]$cursor
)

    $beforeCursor = $line.Substring(0, $cursor)

    # 2. Determine the last word being completed
    $lastWord = $beforeCursor -replace '.*[ ;|&]',''
    $completion = TabExpansion2 $beforeCursor $cursor

    $matches = $completion.CompletionMatches
    if (-not $matches -or $matches.Count -eq 0) { return }

    if ($matches.Count -eq 1) {
        $choice = $matches[0].CompletionText
    }
    else {
        $choice = $matches.CompletionText | fzf
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

Set-PSReadLineKeyHandler -Chord "Ctrl+s,t" -ScriptBlock { Invoke-FuzzyTabExpansion }

