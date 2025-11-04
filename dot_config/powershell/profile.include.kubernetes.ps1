$kubeCtl = Get-Command kubectl.exe -ErrorAction SilentlyContinue
if ($null -ne $kubeCtl) {
    New-Alias -Name k -Value $kubeCtl.Definition
}

helm completion powershell | Out-String | Invoke-Expression
kubectl completion powershell | Out-String | Invoke-Expression

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