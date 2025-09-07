# Plugins

Lazy plugin manager is confiugred to load all files with lua extension in this folder

[Plugin Spec](https://lazy.folke.io/spec)

## Issues

### hererocks Error: couldn't set up MSVC toolchain

Issue seen when installing telescope which brings in other modules plenary -> hererocks

Running C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
build: Error: couldn't set up MSVC toolchain

- Neovim modules are generally written in Lua
- Luaocks is the lua package manager
- Older Neovim modules may require luarocks
- Hererocks is a way to setup an isolated lua package environment which doesn't interact with system wide environment

Edit Visual Studion Installer to include MSVC build tools for C++

Disabled luarocks, and switched to use hererocks via lazyvim plugin options

```
rocks = {
    enabled = false,
    hererocks = true
}
```