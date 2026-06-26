# dotfiles bootstrap linux

```powershell
# Install ASDF as a pre-requsite to installing chezmoi
./01-asdf.ps1
# Install and configure chezmoi
./02-chezmoi.ps1

# Above script will output the command to configure chezmoi e.g.
& '~/.asdf/installs/chezmoi/2.65.1/bin/chezmoi' apply --verbose

./03-shells.ps1

cd ~
asdf install
```

