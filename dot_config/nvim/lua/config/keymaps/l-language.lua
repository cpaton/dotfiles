-- l - language of file stuff
local telescope = require('telescope.builtin')

vim.keymap.set("n", "<leader>ld", telescope.lsp_definitions,
    { noremap = true, silent = true, desc = "LSP go to definition" })
vim.keymap.set("n", "<leader>li", function()
    vim.diagnostic.open_float(nil, { focus = false })
end, { noremap = true, silent = true, desc = "Show diagnostics for current word" })
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
vim.keymap.set("n", "<leader>lf",
    function()
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        if #clients > 0 then
            vim.lsp.buf.format({
                async = true,
                timeout_ms = 10000,
            })
        else
            vim.cmd("normal! gg=G")
        end
    end,
    { desc = "Format file" }
)
vim.keymap.set("n", "<M-F>", --shift+alt+f
    function()
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        if #clients > 0 then
            vim.lsp.buf.format({ async = true })
        else
            vim.cmd("normal! gg=G")
        end
    end,
    { desc = "Format file" }
)
vim.keymap.set("v", "<M-F>", --shift+alt+f
    function()
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        if #clients > 0 then
            vim.lsp.buf.format({ async = true })
        else
            vim.cmd("normal! =")
        end
    end,
    { desc = "Format selected text" }
)
