# NeoVim
if (Test-Path C:\_cp\apps\nvim\bin\nvim.exe) {
    New-Alias -Name v -Value C:\_cp\apps\nvim\bin\nvim.exe
    New-Alias -Name vi -Value C:\_cp\apps\nvim\bin\nvim.exe
    New-Alias -Name vim -Value C:\_cp\apps\nvim\bin\nvim.exe
    New-Alias -Name nvim -Value C:\_cp\apps\nvim\bin\nvim.exe
}

if (Test-Path "C:\_cp\apps\npp.8.3.3.portable.x64\notepad++.exe") {
    New-Alias -Name npp -Value "C:\_cp\apps\npp.8.3.3.portable.x64\notepad++.exe"
}
