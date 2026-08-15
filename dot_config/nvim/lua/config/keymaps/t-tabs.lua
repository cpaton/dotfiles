-- t - buffers (tabs)
vim.keymap.set("n", "<leader><right>", ":bnext <CR>", { noremap = true, silent = true, desc = "Next buffer" })
vim.keymap.set("n", "<leader><left>", ":bprev <CR>", { noremap = true, silent = true, desc = "Previous buffer" })
vim.keymap.set("n", "<leader>t<right>", ":bnext <CR>", { noremap = true, silent = true, desc = "Next buffer" })
vim.keymap.set("n", "<leader>tl", ":bnext <CR>", { noremap = true, silent = true, desc = "Next buffer" })
vim.keymap.set("n", "<leader>t<left>", ":bprev <CR>", { noremap = true, silent = true, desc = "Previous buffer" })
vim.keymap.set("n", "<leader>tj", ":bprev <CR>", { noremap = true, silent = true, desc = "Previous buffer" })
vim.keymap.set("n", "<leader>tc", function()
    require("bufdelete").bufdelete(0, false)
end, { noremap = true, silent = true, desc = "Close tab (buffer)" })
vim.keymap.set("n", "<leader>to", ":Bonly <CR>",
    { noremap = true, silent = true, desc = "Close all other tabs (buffers)" })

vim.api.nvim_create_user_command("Bonly", function()
    local current_buf = vim.api.nvim_get_current_buf()
    local listed_bufs = vim.api.nvim_list_bufs()

    for _, buf in ipairs(listed_bufs) do
        if buf ~= current_buf and vim.api.nvim_buf_is_loaded(buf) then
            local buftype = vim.bo[buf].buftype
            local filetype = vim.bo[buf].filetype
            if buftype == "" and not vim.tbl_contains({ "neo-tree", "lazy", "mason", "help" }, filetype) then
                require("bufdelete").bufdelete(buf, false)
            end
        end
    end
end, {})
