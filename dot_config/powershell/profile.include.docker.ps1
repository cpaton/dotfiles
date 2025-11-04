function dcr() {
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [Parameter()]
        [switch]
        $Aws,
        [Parameter()]
        [switch]
        $Bash,
        [Parameter()]
        [switch]
        $PowerShell,
        [Parameter()]
        [AllowEmptyString()]
        [AllowNull()]
        $Src,
        [Parameter()]
        $SrcWorkDir,
        [Parameter(ValueFromRemainingArguments)]
        $OtherArgs
    )

    $commandParts = @("docker container run --rm -it")

    if ($Aws) {
        $commandParts += "--mount type=bind,source=$(Resolve-Path ~/.aws),target=/root/.aws"
    }
    if ($Bash) {
        $commandParts += "--entrypoint /bin/bash"
    }
    if ($PowerShell) {
        $commandParts += "--entrypoint /usr/bin/pwsh"
    }
    if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('Src')) {
        if ([string]::IsNullOrWhiteSpace($Src)) {
            $Src = "/host"
        }
        $commandParts += "--mount type=bind,source=$($PWD),target=$($Src)"
    }
    if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('SrcWorkDir')) {
        if ([string]::IsNullOrWhiteSpace($SrcWorkDir)) {
            $SrcWorkDir = "/host"
        }
        $commandParts += "--mount type=bind,source=$($PWD),target=$($SrcWorkDir) --workdir $($SrcWorkDir)"
    }

    $commandParts += @( $OtherArgs )
    $fullCommand = $commandParts -join " "
    Write-Host $fullCommand
    Invoke-Expression $fullCommand
}