$script:BaseCompleter = (Get-Command TabExpansion2).ScriptBlock

function global:TabExpansion2 {
    param($line, $lastWord)

    $results = & $script:BaseCompleter $line $lastWord

    # If multiple candidates → pass through fzf
    if ($results.CompletionMatches.Count -gt 1) {
        $selected = $results.CompletionMatches.CompletionText | fzf
        if ($selected) {
            # Replace results with just the chosen one
            $results.CompletionMatches = @(
                [System.Management.Automation.CompletionResult]::new(
                    $selected, $selected, 'ParameterValue', $selected
                )
            )
        }
        else {
            $results.CompletionMatches = @()
        }
    }

    return $results
}

