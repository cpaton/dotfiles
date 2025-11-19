# TMUX

Install tpm

```
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

Load tmux

```
tmux
```

Trigger install of plugins

```
<Ctrl+B> + I
```

# tmux ressurect save directory bug

pane titles can be empty, when saving the state the save.sh function will remove consecutive tabs and in effect remove the pane title entry.  Fix is to update save.sh.pane_format() to have a : prefix for the pane title.  Then update the restore.sh.restore_pane() function to remove the : prefix when restoring the pane title.
