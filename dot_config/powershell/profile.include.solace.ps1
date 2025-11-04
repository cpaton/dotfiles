if (-not (Test-Path 'C:\Program Files (x86)\SolAdmin')) {
    return
}

function Start-SolAdmin()
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [ArgumentCompleter( {
            param ( $commandName,
                    $parameterName,
                    $wordToComplete,
                    $commandAst,
                    $fakeBoundParameters )
            $soaFiles = Get-ChildItem -Path E:\Settings -Filter *.soa
            $soaFiles | Foreach-Object { [System.IO.Path]::GetFileNameWithoutExtension($_.Name) } | Where-Object { $_ -like "*$($wordToComplete)*" }
        } )]
        [string]
        $Environment
    )

    $solAdminPath = 'C:\Program Files (x86)\SolAdmin'

    Push-Location $solAdminPath
    try
    {
        $command = "& '$solAdminPath\bin\run.bat'"
        if ($Environment)
        {
            $command +=  " -soa 'E:\Settings\$($Environment).soa'"
        }
        Write-Verbose $command
        Invoke-Expression $command
    }
    finally
    {
        Pop-Location
    }
}

New-Alias -Name solAdmin -Value Start-SolAdmin -Force