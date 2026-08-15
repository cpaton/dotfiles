-- s - shell / terminal
vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]],
    { noremap = true, silent = true, desc = "Exit terminal mode" })
vim.keymap.set("n", "<leader>ss", "<cmd>ToggleTerm direction=float<CR>",
    { noremap = true, silent = true, desc = "Toggle shell float" })
vim.keymap.set("n", "<leader>sh", "<cmd>ToggleTerm direction=horizontal<CR>",
    { noremap = true, silent = true, desc = "Toggle shell horizontal" })
vim.keymap.set("n", "<leader>sv", "<cmd>ToggleTerm direction=vertical<CR>",
    { noremap = true, silent = true, desc = "Toggle shell vertical" })
vim.keymap.set("n", "<leader>st", "<cmd>ToggleTerm direction=tab<CR>",
    { noremap = true, silent = true, desc = "Toggle shell tab" })
