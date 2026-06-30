-- Create a group (clears existing autocommands in the group)
local groupFormatOnSave = vim.api.nvim_create_augroup("FormatOnSave", { clear = true })

-- Add autocommands to the group
vim.api.nvim_create_autocmd("BufWritePre", {
    group = groupFormatOnSave,
    pattern = {
        "*.lua",
        "*.ps1",
        "*.tf",
    },
    callback = function()
        vim.cmd("checktime")
        vim.lsp.buf.format({
            async = false,
            timeout_ms = 10000
        })
    end,
})
