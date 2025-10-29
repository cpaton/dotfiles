vim.opt.number = true         -- Print the line number in front of each line
vim.opt.relativenumber = true -- Use relative line numbers
vim.opt.list = true           -- Show <tab> and trailing spaces
vim.opt.cursorline = true     -- Highlight the line where the cursor is on
vim.opt.scrolloff = 10        -- Minimal number of screen lines to keep above and below the cursor.
vim.opt.wrap = false          -- Do not wrap long lines
vim.opt.signcolumn = "yes"    -- always show sign information e.g. lines which have changed
vim.opt.colorcolumn = "220"   -- line length marker at 200 characters

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true  -- Highlight search results
vim.opt.incsearch = true -- Show search matches as you type

-- use spaces for tabs, indenting by 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true -- attempt to guess indenting for new lines

-- store undo history to a file on disk, but don't keep backups
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = vim.fn.stdpath("data") .. "/undodir"
vim.opt.undofile = true

vim.opt.mouse = "a" -- Enable mouse support in all modes

vim.opt.spell = true
vim.opt.spelllang = { "en_gb" }
