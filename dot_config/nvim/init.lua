vim.g.mapleader = " " -- Make sure to set `mapleader` before lazy so your mappings are correct
vim.g.maplocalleader = "\\"

require('config.lazy') -- Load the lazy plugin manager and plugins
require('config.clipboard')
require('config.editor')
require('config.lsp')
require('config.completion')
require('config.keymaps')
require('config.formatting')
require('config.statusline')

-- vim.cmd.colorscheme "solarized"
-- vim.cmd.colorscheme "rose-pine"
vim.cmd.colorscheme "catppuccin"
