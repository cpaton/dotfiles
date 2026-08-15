-- w - windows / panes
vim.keymap.set("n", "<leader>w-", ":split <CR>", { noremap = true, silent = true, desc = "Horizontal split" })
vim.keymap.set("n", "<leader>w|", ":vsplit <CR>", { noremap = true, silent = true, desc = "Vertical split" })
vim.keymap.set("n", "<leader>wc", ":close <CR>", { noremap = true, silent = true, desc = "Close Window" })
vim.keymap.set("n", "<leader>w<Up>", "<C-w><Up>", { noremap = false, desc = "Select window above" })
vim.keymap.set("n", "<leader>w<Down>", "<C-w><Down>", { noremap = false, desc = "Select window below" })
vim.keymap.set("n", "<leader>w<Left>", "<C-w><Left>", { noremap = false, desc = "Select window to the left" })
vim.keymap.set("n", "<leader>w<Right>", "<C-w><Right>", { noremap = false, desc = "Select window to the right" })
