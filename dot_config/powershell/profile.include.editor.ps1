if (Test-Path 'C:\_cp\apps\npp.8.3.3.portable.x64\notepad++.exe') {
    New-Alias -Name npp -Value 'C:\_cp\apps\npp.8.3.3.portable.x64\notepad++.exe'
}

# NeoVim
$neoVimCommand = Get-Command nvim -ErrorAction SilentlyContinue
if ($null -ne $neoVimCommand) {
    $env:VISUAL = 'nvim'
    $env:EDITOR = 'nvim'
    New-Alias -Name v -Value $neoVimCommand.Source
    New-Alias -Name vi -Value $neoVimCommand.Source
    New-Alias -Name vim -Value $neoVimCommand.Source
    New-Alias -Name nvim -Value $neoVimCommand.Source
}
elseif (Test-Path C:\_cp\apps\nvim\bin\nvim.exe) {
    New-Alias -Name v -Value C:\_cp\apps\nvim\bin\nvim.exe
    New-Alias -Name vi -Value C:\_cp\apps\nvim\bin\nvim.exe
    New-Alias -Name vim -Value C:\_cp\apps\nvim\bin\nvim.exe
    New-Alias -Name nvim -Value C:\_cp\apps\nvim\bin\nvim.exe
}