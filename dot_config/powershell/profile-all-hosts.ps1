$machineConifg = . ( Join-Path $PSScriptRoot "machine-config.ps1" )

if (-not [string]::IsNullOrWhiteSpace($machineConifg.LocalModulePath)) {
    $env:PSModulePath = "$($machineConifg.LocalModulePath);$($env:PSModulePath)"
}



$script:AsyncRunspace = [runspacefactory]::CreateRunspace()
$script:AsyncRunspace.Open()

$ps = [powershell]::Create()
$ps.Runspace = $script:AsyncRunspace
$ps.AddScript({
    Add-Content -Path "/mnt/c/_cp/Git/dotfiles/dot_config/powershell/log.txt" -Value "Starting - $PSScriptRoot"
    try {
    $files = Get-ChildItem -Path $PSScriptRoot -Filter "profile.*.ps1" -File |
        Sort-Object Name

    foreach ($file in $files) {
        Add-Content -Path "/mnt/c/_cp/Git/dotfiles/dot_config/powershell/log.txt" -Value "Sourcing: $($file.FullName)"
        try { . $file.FullName } catch {
                    Add-Content -Path "/mnt/c/_cp/Git/dotfiles/dot_config/powershell/log.txt" -Value "Error profile: $file.FullName"
        }
        Add-Content -Path "/mnt/c/_cp/Git/dotfiles/dot_config/powershell/log.txt" -Value "Done: $($file.FullName)"
    }}
    catch {
        Add-Content -Path "/mnt/c/_cp/Git/dotfiles/dot_config/powershell/log.txt" -Value "General error: $($_.Exception.Message)"
    }
}) | Out-Null
$ps.BeginInvoke() | Out-Null

# $profileFiles = Get-ChildItem -Path $PSScriptRoot -Filter "profile.*.ps1" -file | 
#     Sort-Object -Property Name
#
# foreach ($profileFile in $profileFiles) {
#     Write-Host "Prepping to source profile: $($profileFile.FullName)"
#     # . $profileFile.FullName
#     $ps = [powershell]::Create()
#     $ps.AddScript({ 
#         param($path) 
#
#         Add-Content -Path "/mnt/c/_cp/Git/dotfiles/dot_config/powershell/log.txt" -Value "Sourcing profile: $path"
#         try {
#             . $path 
#         }
#         catch {
#             Add-Content -Path "/mnt/c/_cp/Git/dotfiles/dot_config/powershell/log.txt" -Value "Error profile: $path"
#         }
#
#         Add-Content -Path "/mnt/c/_cp/Git/dotfiles/dot_config/powershell/log.txt" -Value "Done profile: $path"
#     }) | Out-Null
#     $ps.AddArgument($profileFile.FullName) | Out-Null
#
#     $ps.Runspace = $script:AsyncRunspace
#     $ps.BeginInvoke() | Out-Null
# }
#
