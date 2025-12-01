. __ProfileCachedInitialization "zoxide" {
    if ($null -ne (Get-Command zoxide -ErrorAction SilentlyContinue)) {
        zoxide init powershell --no-cmd | Out-String
        # zoxide init powershell --no-cmd | Out-String
    }
}

# function __fuzzy_zoxide_z{
#     [CmdletBinding()]
#     param(
#         [Parameter(Position = 0)]
#         [ArgumentCompleter( {
#             param ( $commandName,
#                 $parameterName,
#                 $wordToComplete,
#                 $commandAst,
#                 $fakeBoundParameters )
#             zoxide query --list | Where-Object { $_ -like "*$($wordToComplete)*" }
#         } )]
#         [string]
#         $Directory
#     )
#
#     z $Directory
# }
