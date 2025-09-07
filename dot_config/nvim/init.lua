vim.g.mapleader = " " -- Make sure to set `mapleader` before lazy so your mappings are correct
vim.g.maplocalleader = "\\"

require('config.lazy')  -- Load the lazy plugin manager and plugins
require('config.clipboard')
require('config.editor')
require('config.keymaps')

vim.cmd.colorscheme "solarized"