-- e - explorer / browser
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
    { noremap = true, silent = true, desc = "File browser buffers" })
vim.keymap.set("n", "<leader>ed", ":Neotree action=focus source=diagnostics position=bottom toggle=true <CR>",
    { noremap = true, silent = true, desc = "File browser diagnostics" })
vim.keymap.set("n", "<leader>ec", ":Neotree action=close <CR>",
    { noremap = true, silent = true, desc = "File browser close" })
vim.keymap.set("n", "<leader>ex", ":Neotree action=close <CR>",
    { noremap = true, silent = true, desc = "File browser close" })
