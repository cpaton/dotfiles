. __ProfileCachedInitialization 'zoxide' {
    if ($null -ne (Get-Command zoxide -ErrorAction SilentlyContinue)) {
        zoxide init --cmd zz powershell | Out-String
        # zoxide init powershell --no-cmd | Out-String
    }
}

function ZoxideWrapper {
    [cmdletbinding()]
    param(
        [parameter(position = 0)]
        [argumentcompleter( {
                param ( $commandname,
                    $parametername,
                    $wordtocomplete,
                    $commandast,
                    $fakeboundparameters )
                zoxide query --list $wordtocomplete
            } )]
        [string]
        $directory
    )

    __zoxide_z $directory
}
New-Alias -Name z -Value ZoxideWrapper -Force
