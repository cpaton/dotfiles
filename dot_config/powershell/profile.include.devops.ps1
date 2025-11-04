function Invoke-DevOpsLocal() {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments)]
        $DevOpsArgs
    )

    $devopsBinary = "devops"
    if ($IsWindows) {
        $devopsBinary = "devops.exe"
    }

    $devOpsPath = Join-Path $machineConfig.GitRoot "devops/cli/$($devopsBinary)"
    if (-not (Test-Path $devOpsPath)) {
        throw "Devops CLI not found at $devOpsPath"
    }

    & $devOpsPath $DevOpsArgs
}
New-Alias -Name ldo -Value Invoke-DevOpsLocal -Force

function Invoke-DevOpsOneDeployLocal() {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments)]
        $DevOpsArgs
    )

    $devopsBinary = "devops"
    if ($IsWindows) {
        $devopsBinary = "devops.exe"
    }

    $devOpsPath = Join-Path $machineConfig.GitRoot "devops/cli/$($devopsBinary)"
    if (-not (Test-Path $devOpsPath)) {
        throw "Devops CLI not found at $devOpsPath"
    }

    & $devOpsPath onedeploy $DevOpsArgs
}
New-Alias -Name lod -Value Invoke-DevOpsOneDeployLocal -Force

function Invoke-DevOpsOneDeployLocalConfigMerge() {
    [CmdletBinding()]
    param()

    Invoke-DevOpsLocal onedeploy config-merge
}
New-Alias -Name lodcm -Value Invoke-DevOpsOneDeployLocalConfigMerge -Force

function Invoke-DevOpsOneDeployLocalPlan() {
    [CmdletBinding()]
    param()

    Invoke-DevOpsLocal onedeploy plan --display
}
New-Alias -Name lodp -Value Invoke-DevOpsOneDeployLocalPlan -Force

function Invoke-DevOpsOneDeployLocalPipelineUpdate() {
    [CmdletBinding()]
    param()

    Invoke-DevOpsLocal onedeploy pipeline-update
}
New-Alias -Name lodpu -Value Invoke-DevOpsOneDeployLocalPipelineUpdate -Force

function Invoke-DevOpsOneDeployLocalCycle() {
    [CmdletBinding()]
    param(
        [Parameter()]
        [switch]
        $Plan
    )

    if ($Plan) {
        Invoke-DevOpsLocal onedeploy cycle --plan
    }
    else {
        Invoke-DevOpsLocal onedeploy cycle
    }
}
New-Alias -Name lodc -Value Invoke-DevOpsOneDeployLocalCycle -Force

function Invoke-DevOps() {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments)]
        $DevOpsArgs
    )

    $devopsBinary = "devops"
    if ($IsWindows) {
        $devopsBinary = "devops.exe"
    }

    & $devopsBinary $DevOpsArgs
}

function Invoke-DevOpsOneDeploy() {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments)]
        $DevOpsArgs
    )

    $devopsBinary = "devops"
    if ($IsWindows) {
        $devopsBinary = "devops.exe"
    }

    & $devopsBinary onedeploy $DevOpsArgs
}
New-Alias -Name od -Value Invoke-DevOpsOneDeploy -Force

function Invoke-DevOpsOneDeployConfigMerge() {
    [CmdletBinding()]
    param()

    Invoke-DevOps onedeploy config-merge
}
New-Alias -Name odcm -Value Invoke-DevOpsOneDeployConfigMerge -Force

function Invoke-DevOpsOneDeployPlan() {
    [CmdletBinding()]
    param()

    Invoke-DevOps onedeploy plan --display
}
New-Alias -Name odp -Value Invoke-DevOpsOneDeployPlan -Force

function Invoke-DevOpsOneDeployPipelineUpdate() {
    [CmdletBinding()]
    param()

    Invoke-DevOps onedeploy pipeline-update
}
New-Alias -Name odpu -Value Invoke-DevOpsOneDeployPipelineUpdate -Force

function Invoke-DevOpsOneDeployCycle() {
    [CmdletBinding()]
    param(
        [Parameter()]
        [switch]
        $Plan
    )

    if ($Plan) {
        Invoke-DevOps onedeploy cycle --plan
    }
    else {
        Invoke-DevOps onedeploy cycle
    }
}
New-Alias -Name odc -Value Invoke-DevOpsOneDeployCycle -Force