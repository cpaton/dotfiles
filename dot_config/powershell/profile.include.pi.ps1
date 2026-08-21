function Start-PiCodingAgent() {
    [CmdletBinding()]
    param(
        [Parameter()]
        [ArgumentCompleter({
                param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
                if ($null -ne $tpIcapAws -and $null -ne $tpIcapAws.AwsAccounts) {
                    $tpIcapAws.AwsAccounts.Keys | Where-Object { $_ -like "$wordToComplete*" } | Sort-Object
                }
            })]
        [string]
        $AwsAccount = 'tpicap-pace-sandbox',
        [Parameter()]
        [ArgumentCompleter({
                param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
                try {
                    (Get-AWSRegion).Region | Where-Object { $_ -like "$wordToComplete*" } | Sort-Object
                }
                catch {
                }
            })]
        [string]
        $AwsRegion = 'eu-west-1',
        [Parameter()]
        [string]
        $AwsRole = 'DevOps',
        [Parameter()]
        [string]
        $Role
    )

    $ErrorActionPreference = 'Stop'
    $PSNativeCommandUseErrorActionPreference = $true

    $envVarsToRestore = @{}

    function TempSetEnvVar {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory, Position = 1)]
            [string]
            $Name,
            [Parameter(Mandatory, Position = 2)]
            [string]
            $Value
        )

        $envVarsToRestore[$Name] = (Get-Item "env:$Name" -ErrorAction SilentlyContinue).Value
        Set-Item -Path "env:$Name" -Value $Value
    }

    $awsProfile = "$($AwsAccount)-$($AwsRole)"
    awssso -AwsAccount $AwsAccount -Role $AwsRole -ProfileName $awsProfile

    Unlock-GpgVault
    Unlock-ApexVault

    TempSetEnvVar 'AWS_PROFILE' $awsProfile
    TempSetEnvVar 'AWS_REGION' $AwsRegion

    $commandParts = @('pi')
    if ($Role) {
        $commandParts += @('--role', $Role)
    }

    try {
        Invoke-Expression -Command ( $commandParts -join ' ' )
    }
    finally {
        foreach ($name in $envVarsToRestore.Keys) {
            Set-Item -Path "env:$name" -Value $envVarsToRestore[$name]
        }
    }
}
New-Alias -Name pp -Value Start-PiCodingAgent -Force

