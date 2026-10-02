-- l - language of file stuff
local telescope = require('telescope.builtin')

local function signature_help()
    local client = vim.lsp.get_clients({ bufnr = 0, method = "textDocument/signatureHelp" })[1]
    if not client then
        vim.notify("No signature-help-capable LSP client is attached", vim.log.levels.INFO)
        return
    end

    local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
    -- gopls only returns help in string literals for an explicitly invoked request.
    params.context = { triggerKind = 1 }
    client.request("textDocument/signatureHelp", params, vim.lsp.handlers.signature_help, 0)
end

vim.keymap.set("n", "<leader>ld", telescope.lsp_definitions,
    { noremap = true, silent = true, desc = "LSP go to definition" })
vim.keymap.set("n", "<leader>li", function()
    vim.diagnostic.open_float(nil, { focus = false })
end, { noremap = true, silent = true, desc = "Show diagnostics for current word" })
vim.keymap.set("n", "<leader>lh", vim.lsp.buf.hover, { noremap = true, silent = true, desc = "LSP help" })
vim.keymap.set("n", "<leader>ln", telescope.lsp_implementations,
    { noremap = true, silent = true, desc = "LSP go to implementers" })
vim.keymap.set("n", "<leader>lp", signature_help,
    { noremap = true, silent = true, desc = "LSP signature help" })
vim.keymap.set("i", "<C-s>", signature_help,
    { noremap = true, silent = true, desc = "LSP signature help" })

vim.api.nvim_create_autocmd("InsertCharPre", {
    callback = function()
        if vim.v.char == "(" or vim.v.char == "," then
            vim.defer_fn(signature_help, 50)
        end
    end,
    desc = "Show LSP signature help after call delimiters",
})
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
