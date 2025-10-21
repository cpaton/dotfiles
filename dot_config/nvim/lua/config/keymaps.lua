-- see what Keys Neovim gets
-- in insert mode press Ctrl+Q to enter a literal and then press the key combination
-- see if something is mapped
-- :verbose imap <key sequence>

-- Leaders
-- a - ai
-- e - explorer / browser
-- f - fuzzy find files
-- k - language of file stuff
-- t - buffers - but more thought of as tabs from other tools

-- Avante key mappings - https://github.com/yetone/avante.nvim?tab=readme-ov-file#key-bindings
-- leader a c - add current
-- leader a t - toggle
-- vim.keymap.set("n", "<leader>ac", ":AvanteAsk position=right <CR>",
--    { noremap = true, silent = true, desc = "Avante Chat" })
-- vim.keymap.set("n", "<leader>af", ":AvanteToggle<CR>",
--    { noremap = true, silent = true, desc = "Avante toggle" })
-- vim.keymap.set("n", "<leader>ax", ":AvanteToggle<CR>",
--    { noremap = true, silent = false, desc = "Avante add/remove current file from context" })

-- vim.keymap.set("n", "<leader>b", vim.cmd.Explore, { desc = "File browser" }) -- file browser
-- https://github.com/nvim-neo-tree/neo-tree.nvim?tab=readme-ov-file#arguments
vim.keymap.set("n", "<leader>b", ":Neotree source=filesystem reveal=true position=left toggle=true <CR>",
    { noremap = true, silent = true, desc = "File browser" })
vim.keymap.set("n", "<leader>el", ":Neotree action=focus source=filesystem reveal=true position=left <CR>",
    { noremap = true, silent = true, desc = "File browser left" })
vim.keymap.set("n", "<leader>ep", ":Neotree action=focus source=filesystem reveal=true position=float <CR>",
    { noremap = true, silent = true, desc = "File browser popup" })
vim.keymap.set("n", "<leader>ef", ":Neotree action=focus reveal=true <CR>",
    { noremap = true, silent = true, desc = "File browser focus" })
vim.keymap.set("n", "<leader>eg", ":Neotree action=focus source=git_status position=float <CR>",
    { noremap = true, silent = true, desc = "File browser git status" })
vim.keymap.set("n", "<leader>eb", ":Neotree action=focus source=buffers position=float <CR>",
    { noremap = true, silent = true, desc = "File browser git status" })
vim.keymap.set("n", "<leader>ed", ":Neotree action=focus source=diagnostics position=bottom toggle=true <CR>",
    { noremap = true, silent = true, desc = "File browser git status" })
vim.keymap.set("n", "<leader>ec", ":Neotree action=close <CR>",
    { noremap = true, silent = true, desc = "File browser close" })
vim.keymap.set("n", "<leader>ex", ":Neotree action=close <CR>",
    { noremap = true, silent = true, desc = "File browser close" })

-- file finding operations
local telescope_bi = require('telescope.builtin')
vim.keymap.set("n", "<leader>ff", telescope_bi.find_files, { desc = "Find Files" })
vim.keymap.set("n", "<leader>fp", telescope_bi.git_files, { desc = "Find Files in current project" })
vim.keymap.set("n", "<leader>fw", telescope_bi.grep_string, { desc = "Find using current word under cursor" })
vim.keymap.set("n", "<leader>fg", telescope_bi.live_grep, { desc = "Find with grep" })
vim.keymap.set("n", "<leader>fh", telescope_bi.help_tags, { desc = "Find help tags" })
vim.keymap.set("n", "<leader>fb", telescope_bi.buffers, { desc = "List open buffers" })
vim.keymap.set("n", "<leader>fc", telescope_bi.commands, { desc = "Find vim commands" })
vim.keymap.set("n", "<leader>fs",
    function()
        telescope_bi.grep_string({ search = vim.fn.input("Grep > ") });
    end,
    { desc = "Find with grep and allow second filtering" }
)

-- code completion
-- vim.keymap.set('i', '<C-l>', '<C-x><C-o>', { noremap = true, desc = "Trigger completion" })
-- attempts to use spacebar are failing
-- vim.keymap.set('i', '<C-Space>', '<C-x><C-o>', { noremap = true, silent = true, desc = "Trigger completion" })
-- vim.keymap.set('i', '<Esc><Space>', '<C-x><C-o>', { noremap = true, silent = true, desc = "Trigger completion" })

-- formatting
-- format entire file
vim.keymap.set("n", "<leader>kf",
    function()
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        if #clients > 0 then
            -- LSP formatting
            vim.lsp.buf.format({ async = true })
        else
            -- Built-in reindent whole file
            vim.cmd("normal! gg=G")
        end
    end,
    { desc = "Format file" }
)
vim.keymap.set("n", "<M-F>", --shift+alt+f
    function()
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        if #clients > 0 then
            -- LSP formatting
            vim.lsp.buf.format({ async = true })
        else
            -- Built-in reindent whole file
            vim.cmd("normal! gg=G")
        end
    end,
    { desc = "Format file" }
)
vim.keymap.set("v", "<M-F>", --shift+alt+f
    function()
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        if #clients > 0 then
            -- LSP formatting
            vim.lsp.buf.format({ async = true })
        else
            -- Built-in reindent whole file
            vim.cmd("normal! =")
        end
    end,
    { desc = "Format selected text" }
)

-- Press Escape in normal mode to clear temporary things like search highlights and copilot suggestions
vim.keymap.set("n", "<Esc>", function()
    -- clear any next edit suggestions from copilot
    local ok, copilot = pcall(require, "copilot-lsp.nes")
    if ok and copilot.clear then
        copilot.clear()
    end

    -- Clear search highlight
    vim.cmd("nohlsearch")

    -- Feed real <Esc> so it behaves normally
    vim.api.nvim_feedkeys(
        vim.api.nvim_replace_termcodes("<Esc>", true, false, true),
        "n",
        true
    )
end, { noremap = true, silent = true, desc = "Clear Copilot + search highlight + Esc" })

vim.keymap.set("n", "<M-I>", ":CopilotChatToggle <CR>", { noremap = true, silent = true, desc = "Toggle Copilot Chat" })

-- buffer navigation, with bufferline line these look like tabs along the top of the window
vim.keymap.set("n", "<leader><right>", ":bnext <CR>", { noremap = true, silent = true, desc = "Next buffer" })
vim.keymap.set("n", "<leader><left>", ":bprev <CR>", { noremap = true, silent = true, desc = "Previous buffer" })
vim.keymap.set("n", "<leader>t<right>", ":bnext <CR>", { noremap = true, silent = true, desc = "Next buffer" })
vim.keymap.set("n", "<leader>tl", ":bnext <CR>", { noremap = true, silent = true, desc = "Next buffer" })
vim.keymap.set("n", "<leader>t<left>", ":bprev <CR>", { noremap = true, silent = true, desc = "Previous buffer" })
vim.keymap.set("n", "<leader>tj", ":bprev <CR>", { noremap = true, silent = true, desc = "Previous buffer" })
vim.keymap.set("n", "<leader>tc", function()
    -- close current buffer using bufdelete plugin to avoid messing up window layout
    -- 0 - current buffer
    -- false - do not force close
    require("bufdelete").bufdelete(0, false)
end, { noremap = true, silent = true, desc = "Close tab (buffer)" })
vim.keymap.set("n", "<leader>to", ":Bonly <CR>",
    { noremap = true, silent = true, desc = "Close all other tabs (buffers)" })

vim.api.nvim_create_user_command("Bonly", function()
    vim.cmd("%bd|e#|bd#")
end, {})
