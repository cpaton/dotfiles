-- see what Keys Neovim gets
-- in insert mode press Ctrl+Q to enter a literal and then press the key combination
-- see if something is mapped
-- :verbose imap <key sequence>

-- Leaders
-- e - explorer / browser
-- f - fuzzy find files
-- k - language of file stuff

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
