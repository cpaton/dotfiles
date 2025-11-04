<#
.SYNOPSIS
Manages machine configuration in Git using non standard directory setup.  Utility to make it behave like calling git
#>
function dotfiles {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments = $true)]
        $Args
    )

    $homeDirectory = Resolve-Path ~
    $dotFilesGitDirectory = Join-Path $homeDirectory "dotfiles\.git"
    git --git-dir $dotFilesGitDirectory --work-tree $homeDirectory $Args
}

function cmt() {
    $repositoryRoot = Split-Path ( Get-GitDirectory )
    Push-Location $repositoryRoot
    try {
        tgit commit $args
    }
    finally {
        Pop-Location
    }
}

function gpr() { git pull --rebase }
