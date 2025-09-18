vim.opt.cmdheight = 2        -- disable cmdline at the bottom of the screen as noice shows in a popup
vim.opt.showtabline = 2      -- always show tabline
vim.opt.termguicolors = true -- reguired by nvim-notify

require("catppuccin").setup {
    flavour = "frappe", -- latte, frappe, macchiato, mocha
    integrations = { bufferline = true },
}
