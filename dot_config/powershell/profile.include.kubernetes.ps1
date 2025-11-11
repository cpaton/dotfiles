. __ProfileCachedInitialization "kubernetes" {
    $kubeCtl = Get-Command kubectl.exe -ErrorAction SilentlyContinue
    if ($null -ne $kubeCtl) {
        "New-Alias -Name k -Value $($kubeCtl.Definition) -Scope Global"
        $kubectlCompletion = kubectl completion powershell

        # Setup tab completion for the k alias in addition to kubectl
        $insideArgumentCompleter = $false
        $argumentCompleterForAlias = @()
        foreach ($line in $kubectlCompletion) {
            if ($insideArgumentCompleter) {
                $argumentCompleterForAlias += $line
                if ($line -match "^}") {
                    break
                }
            }
            if ($line -match "Register-ArgumentCompleter -CommandName 'kubectl'") {
                $insideArgumentCompleter = $true
                $argumentCompleterForAlias += $line -replace 'kubectl','k'
            }
        }

        @($kubectlCompletion) + $argumentCompleterForAlias | Out-String
    }

    if ($null -ne (Get-Command helm -ErrorAction SilentlyContinue)) {
        helm completion powershell | Out-String
    }
}

function eks()
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 1)]
        [ArgumentCompleter( {
            param ( $commandName,
                    $parameterName,
                    $wordToComplete,
                    $commandAst,
                    $fakeBoundParameters )
            $eksClusters = & ( Join-Path $PSScriptRoot "eks-clusters.ps1" )
            $eksClusters.Keys | Where-Object { $_ -like "*$($wordToComplete)*" }
        } )]
        [string]
        $Cluster,
        [Parameter(Position = 2)]
        [ValidateSet("DevOps", "AdministratorAccess", "ViewOnlyAccess")]
        [string]
        $Role = $("AdministratorAccess")
    )

    $ErrorActionPreference = "Stop"

    $eksClusters = & ( Join-Path $PSScriptRoot "eks-clusters.ps1" )
    $clusterDefinition = $eksClusters[$Cluster]

    $kubeCtlContextName = "$($Cluster)-$($Role)"

    $awsProfileName = "$($clusterDefinition.AwsAccount)-$($Role)"
    awssso -AwsAccount $clusterDefinition.AwsAccount -Role $Role -ProfileName $awsProfileName
    aws eks update-kubeconfig --region $clusterDefinition.AwsRegion --name $clusterDefinition.ClusterName --alias $kubeCtlContextName --user-alias $awsProfileName --profile $awsProfileName

    $titleToRestore = $Host.UI.RawUI.WindowTitle
    try
    {
        $Host.UI.RawUI.WindowTitle = "EKS: $($Cluster)"
        k9s --context $kubeCtlContextName
    }
    finally
    {
        $Host.UI.RawUI.WindowTitle = $titleToRestore
    }
}
