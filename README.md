# Chezmoi

* [Main Site](https://www.chezmoi.io)
* [GitHub Project](https://github.com/twpayne/chezmoi)
* [User Documentation](https://www.chezmoi.io/user-guide/command-overview/)
* [Reference Documentation](https://www.chezmoi.io/reference)

## Configuration

By default looks for configuration file in ~/.config/chezmoi/chezmoi.yaml (following XDG_CONFIG_HOME conventions)

```yaml
sourceDir: c:\_cp\Git\dotfiles
mode: symlink
cd:
  command: pwsh
  args:
    - -NoProfile 
    - -NoLogo

data:
  full_name: Craig Paton
  email: << fill in >>
  paths:
    local_data_root: c:\_cp
    local_app_data_root: C:\Users\craig\AppData\Local
    roaming_app_data_root: C:\Users\craig\OneDrive\Roaming\T480S
    shell_initial_directory: c:\_cp
  neovim:
    avante_provider: copilot
  feature_flags:
    github_copilot: true
```
