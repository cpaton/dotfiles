__ProfileOnIdleInitialization "fuzzy" {
    Import-Module PSFzf -ErrorAction SilentlyContinue -Global
    Set-PsFzfOption -PSReadlineChordReverseHistory Ctrl+r
}

function Set-LocationFuzzy() {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]
        $Directory = "~",
        [Parameter()]
        [switch]
        $All
    )

    $fdCommand = "fd --type directory $($All ? '--no-ignore --hidden' : '') . $Directory"

    $selection = Invoke-Expression $fdCommand | fzf
    if ($null -ne $selection) {
        Set-Location $selection
    }
}
New-Alias -Name fcd -Value Set-LocationFuzzy

function Find-FuzzyDirectory() {
    [CmdletBinding()]
    param()

    $selection = fd --type directory . ~ | fzf
    if ($null -ne $selection) {
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert($selection)
    }
    else {
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert("")
    }
}
Set-PSReadLineKeyHandler -Chord 'Ctrl+f,d' -ScriptBlock { Find-FuzzyDirectory } -BriefDescription 'fzf directory' -Description 'Find Fuzzy Directory'

function Find-FuzzyFile() {
    [CmdletBinding()]
    param()

    $selection = fd --type file . . | fzf
    if ($null -ne $selection) {
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert($selection)
    }
    else {
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert("")
    }
}
Set-PSReadLineKeyHandler -Chord 'Ctrl+f,f' -ScriptBlock { Find-FuzzyFile } -BriefDescription 'fzf file' -Description 'Find Fuzzy File'

function Find-FuzzyFileHome() {
    [CmdletBinding()]
    param()

    $selection = fd --type file . ~ | fzf
    if ($null -ne $selection) {
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert($selection)
    }
    else {
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert("")
    }
}
Set-PSReadLineKeyHandler -Chord 'Ctrl+f,h' -ScriptBlock { Find-FuzzyFileHome } -BriefDescription 'fzf file ~' -Description 'Find Fuzzy File under home'
