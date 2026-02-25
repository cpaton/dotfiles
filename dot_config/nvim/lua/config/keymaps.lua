-- see what Keys Neovim gets
-- in insert mode press Ctrl+Q to enter a literal and then press the key combination
-- see if something is mapped
-- :verbose imap <key sequence>

-- This file is a module in addition to setting up keymaps as its inlcuded.
-- This allows functions here to be called from other files in callbacks where keymaps are setup e.g. plugin
--
local M = {}

-- <Ctrl+/> in Visual mode to toggle comment
vim.keymap.set("x", "<C-_>", "<Plug>(comment_toggle_linewise_visual)", { desc = "Toggle comment selection" })

--
-- Leaders
-- a - ai
-- e - explorer / browser
-- f - fuzzy find files
-- g - git / source control
-- h - harpoon
-- l - language of file stuff
-- r - refactoring
-- t - buffers - but more thought of as tabs from other tools
-- w - windows / panes

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
vim.keymap.set("n", "<leader>faf", function()
    telescope_bi.find_files({
        find_command = {
            "rg", "--files",
            "--hidden",
            "--no-ignore", "--no-ignore-parent",
            "--glob", "!.git/*",
        },
    })
    -- telescope_bi.find_files({
    --     hidden = true,
    --     no_ignore = true,
    --     no_ignore_parent = true
    -- })
end, { desc = "Find Files (hidden)" })
vim.keymap.set("n", "<leader>fp", telescope_bi.git_files, { desc = "Find Files in current project" })
vim.keymap.set("n", "<leader>fw", telescope_bi.grep_string, { desc = "Find using current word under cursor" })
vim.keymap.set("n", "<leader>fg", telescope_bi.live_grep, { desc = "Find with grep" })
vim.keymap.set("n", "<leader>fag", function()
    telescope_bi.live_grep({
        additional_args = function()
            return { "--hidden", "--no-ignore", "--no-ignore-parent", "--glob=!.git/" }
        end
    })
end, { desc = "Find with grep including hidden and ignored files" })
vim.keymap.set("n", "<leader>fh", telescope_bi.help_tags, { desc = "Find help tags" })
vim.keymap.set("n", "<leader>fb", telescope_bi.buffers, { desc = "List open buffers" })
vim.keymap.set("n", "<leader>fc", telescope_bi.commands, { desc = "Find vim commands" })
vim.keymap.set("n", "<leader>fs",
    function()
        telescope_bi.grep_string({ search = vim.fn.input("Grep > ") });
    end,
    { desc = "Find with grep and allow second filtering" }
)

--
-- G - git / source related operations
--

vim.keymap.set("n", "<leader>gg", ":LazyGit <CR>", { noremap = true, silent = true, desc = "Open LazyGit" })
-- function to setup gitsigns keymaps, called from gitsigns config when it attaches to a buffer
function M.gitsigns(bufnr)
    local gitsigns = require('gitsigns')

    local function map(mode, l, r, opts)
        opts = opts or {}
        opts.buffer = bufnr
        vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    ---@type Gitsigns.NavOpts
    local navigation_options = {
        wrap = true,
        foldopen = true,
        navigation_message = false,
        count = 1,
        greedy = true,
        target = 'all'
    }

    -- map('n', ']c', function()
    --     if vim.wo.diff then
    --         vim.cmd.normal({ ']c', bang = true })
    --     else
    --         gitsigns.nav_hunk('next', navigation_options)
    --     end
    -- end)
    --
    -- map('n', '[c', function()
    --     if vim.wo.diff then
    --         vim.cmd.normal({ '[c', bang = true })
    --     else
    --         gitsigns.nav_hunk('prev', navigation_options)
    --     end
    -- end)
    map('n', '<leader>gn',
        function()
            gitsigns.nav_hunk('next', navigation_options)
        end,
        { desc = "Navigate to next hunk / change" }
    )
    map('n', '<leader>gp',
        function()
            gitsigns.nav_hunk('prev', navigation_options)
        end,
        { desc = "Navigate to previous hunk /  change" }
    )

    -- Add / Reset
    map('n', '<leader>gha', gitsigns.stage_hunk, { desc = "Add(Stage) hunk (toggle)" })
    map('n', '<leader>ghr', gitsigns.reset_hunk, { desc = "Reset(Undo) hunk / change" })
    map('v', '<leader>gha', function()
        gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
    end, { desc = "Add(Stage) hunk (toggle)" })
    map('v', '<leader>ghr', function()
        gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
    end, { desc = "Reset(Undo) hunk / change" })
    map('n', '<leader>ga', gitsigns.stage_buffer, { desc = "Add(Stage) file (toggle)" })
    -- map('n', '<leader>gr', gitsigns.reset_buffer)

    -- Diff
    map('n', '<leader>ghp', gitsigns.preview_hunk, { desc = "Diff change / hunk in a popup preview window" })
    map('n', '<leader>ghd', gitsigns.preview_hunk, { desc = "Diff change / hunk in a popup preview window" })
    map('n', '<leader>ghi', gitsigns.preview_hunk_inline, { desc = "Diff change / hunk inline" })
    map('n', '<leader>gd', gitsigns.diffthis, { desc = "Diff this file with index" })
    map('n', '<leader>gD', function()
        gitsigns.diffthis('~')
    end, { desc = "Diff this file with last commit" })

    map('n', '<leader>gbl', function()
        gitsigns.blame_line({ full = true })
    end)

    map('n', '<leader>gQ', function() gitsigns.setqflist('all') end)
    map('n', '<leader>gq', gitsigns.setqflist)

    -- Toggles
    map('n', '<leader>gbt', gitsigns.toggle_current_line_blame)
    -- map('n', '<leader>tw', gitsigns.toggle_word_diff)

    -- Text object
    map({ 'o', 'x' }, '<leader>ghs', gitsigns.select_hunk)
end

-- code completion
-- vim.keymap.set('i', '<C-l>', '<C-x><C-o>', { noremap = true, desc = "Trigger completion" })
-- attempts to use spacebar are failing
-- vim.keymap.set('i', '<C-Space>', '<C-x><C-o>', { noremap = true, silent = true, desc = "Trigger completion" })
-- vim.keymap.set('i', '<Esc><Space>', '<C-x><C-o>', { noremap = true, silent = true, desc = "Trigger completion" })

-- Language <leader>l
local telescope = require('telescope.builtin')
vim.keymap.set("n", "<leader>ld", telescope.lsp_definitions,
    { noremap = true, silent = true, desc = "LSP go to definition" })
vim.keymap.set("n", "<leader>li", function()
    vim.diagnostic.open_float(nil, { focus = false })
end, { noremap = true, silent = true, desc = "Show diagnostics for currnet word" })
vim.keymap.set("n", "<leader>lh", vim.lsp.buf.hover, { noremap = true, silent = true, desc = "LSP help" })
vim.keymap.set("n", "<leader>ln", telescope.lsp_implementations,
    { noremap = true, silent = true, desc = "LSP go to implementers" })
vim.keymap.set("n", "<leader>lp", vim.lsp.buf.signature_help,
    { noremap = true, silent = true, desc = "LSP signature help" })
vim.keymap.set("n", "<leader>lr", telescope.lsp_references,
    { noremap = true, silent = true, desc = "LSP list references" })
vim.keymap.set("n", "<leader>ls", telescope.lsp_document_symbols,
    { noremap = true, silent = true, desc = "LSP file symbols" })
vim.keymap.set("n", "<leader>lt", telescope.lsp_workspace_symbols, { noremap = true, silent = true, desc = "LSP types" })
vim.keymap.set("n", "<leader>lu", telescope.lsp_type_definitions,
    { noremap = true, silent = true, desc = "LSP type definition" })
-- formatting
-- format entire file
vim.keymap.set("n", "<leader>lf",
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

-- refactoring
vim.keymap.set("x", "<leader>re", ":Refactor extract ")
vim.keymap.set("x", "<leader>rf", ":Refactor extract_to_file ")
vim.keymap.set("x", "<leader>rv", ":Refactor extract_var ")
vim.keymap.set({ "n", "x" }, "<leader>ri", ":Refactor inline_var")
vim.keymap.set("n", "<leader>rI", ":Refactor inline_func")
vim.keymap.set("n", "<leader>rb", ":Refactor extract_block")
vim.keymap.set("n", "<leader>rbf", ":Refactor extract_block_to_file")


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

-- vim.api.nvim_create_user_command("Bonly", function()
--     vim.cmd("%bd|e#|bd#")
-- end, {})

vim.api.nvim_create_user_command("Bonly", function()
    local current_buf = vim.api.nvim_get_current_buf()
    local listed_bufs = vim.api.nvim_list_bufs()

    for _, buf in ipairs(listed_bufs) do
        -- Skip:
        --  1. Current buffer
        --  2. Unloaded buffers
        --  3. Neo-tree or any special buftypes (e.g. terminal, nofile, prompt)
        if buf ~= current_buf and vim.api.nvim_buf_is_loaded(buf) then
            local buftype = vim.bo[buf].buftype
            local filetype = vim.bo[buf].filetype
            if buftype == "" and not vim.tbl_contains({ "neo-tree", "lazy", "mason", "help" }, filetype) then
                require("bufdelete").bufdelete(buf, false)
            end
        end
    end
end, {})

-- window navigation and manipulation
vim.keymap.set("n", "<leader>w-", ":split <CR>", { noremap = true, silent = true, desc = "Horizontal split" })
vim.keymap.set("n", "<leader>w|", ":vsplit <CR>", { noremap = true, silent = true, desc = "Vertical split" })
vim.keymap.set("n", "<leader>wc", ":close <CR>", { noremap = true, silent = true, desc = "Close Window" })
vim.keymap.set("n", "<leader>w<Up>", "<C-w><Up>", { noremap = false, desc = "Select window above" })
vim.keymap.set("n", "<leader>w<Down>", "<C-w><Down>", { noremap = false, desc = "Select window below" })
vim.keymap.set("n", "<leader>w<Left>", "<C-w><Left>", { noremap = false, desc = "Select window to the left" })
vim.keymap.set("n", "<leader>w<Right>", "<C-w><Right>", { noremap = false, desc = "Select window to the right" })

return M
