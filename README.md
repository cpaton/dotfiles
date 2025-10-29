# Chezmoi

* [Main Site](https://www.chezmoi.io)
* [GitHub Project](https://github.com/twpayne/chezmoi)
* [User Documentation](https://www.chezmoi.io/user-guide/command-overview/)
* [Reference Documentation](https://www.chezmoi.io/reference)

## Configuration

By default looks for configuration file in ~/.config/chezmoi/chezmoi.config (following XDG_CONFIG_HOME conventions)

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
  neovim:
    avante_provider: copilot
  feature_flags:
    github_copilot: true
```
