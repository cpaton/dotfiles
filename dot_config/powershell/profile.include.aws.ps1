function ssm()
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 1)]
        [string]
        $Instance,
        [Parameter(Position = 2)]
        [string]
        $ProfileName,
        [Parameter(Position = 3)]
        [string]
        $Region
    )

    $command = "aws ssm start-session --target $Instance"
    if ($ProfileName)
    {
        $command += " --profile $ProfileName"
    }
    if ($Region)
    {
        $command += " --region $Region"
    }
    Write-Verbose $command
    Invoke-Expression $command
}