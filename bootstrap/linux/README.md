# dotfiles bootstrap linux

```powershell
# Install mise
./01-mise.ps1

# Install chezmoi via mise and configure it
./02-chezmoi.ps1

# Above script will output the command to apply chezmoi e.g.
& chezmoi apply --verbose

# Configure shells
./03-shells.ps1

# Install all tools defined in ~/.config/mise/config.toml
mise install
```
