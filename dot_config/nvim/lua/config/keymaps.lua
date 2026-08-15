-- see what Keys Neovim gets
-- in insert mode press Ctrl+Q to enter a literal and then press the key combination
-- see if something is mapped
-- :verbose imap <key sequence>

-- This file is a module in addition to setting up keymaps as its included.
-- This allows functions here to be called from other files in callbacks where keymaps are setup e.g. plugin
--
local M = {}

-- <Ctrl+/> in Visual mode to toggle comment
vim.keymap.set("x", "<C-_>", "<Plug>(comment_toggle_linewise_visual)", { desc = "Toggle comment selection" })

--
-- Leaders
-- a - ai
-- d - debugging
-- e - explorer / browser
-- f - fuzzy find files
-- g - git / source control
-- h - harpoon
-- l - language of file stuff
-- r - refactoring
-- s - shell / terminal
-- t - buffers - but more thought of as tabs from other tools
-- w - windows / panes

-- Load prefix-based keymap files
require("config.keymaps.e-explorer")
require("config.keymaps.f-fuzzy")
require("config.keymaps.l-language")
require("config.keymaps.r-refactoring")
require("config.keymaps.s-shell")
require("config.keymaps.t-tabs")
require("config.keymaps.w-windows")

-- git keymaps export the gitsigns function so need to be merged into M
local git_keymaps = require("config.keymaps.g-git")
M.gitsigns = git_keymaps.gitsigns

-- dap keymaps are loaded after plugins are ready (lazy.nvim ensures deps are met)
require("config.keymaps.d-debugging")

-- Miscellaneous keymaps that don't fit a prefix

-- Press Escape in normal mode to clear temporary things like search highlights and copilot suggestions
vim.keymap.set("n", "<Esc>", function()
    local ok, copilot = pcall(require, "copilot-lsp.nes")
    if ok and copilot.clear then
        copilot.clear()
    end

    vim.cmd("nohlsearch")

    vim.api.nvim_feedkeys(
        vim.api.nvim_replace_termcodes("<Esc>", true, false, true),
        "n",
        true
    )
end, { noremap = true, silent = true, desc = "Clear Copilot + search highlight + Esc" })

-- vim.keymap.set("n", "<M-I>", ":CopilotChatToggle <CR>", { noremap = true, silent = true, desc = "Toggle Copilot Chat" })

return M
