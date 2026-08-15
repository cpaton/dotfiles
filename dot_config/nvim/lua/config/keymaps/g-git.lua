-- g - git / source control
local M = {}

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

    -- Text object
    map({ 'o', 'x' }, '<leader>ghs', gitsigns.select_hunk)
end

return M
