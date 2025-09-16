return {
    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'web-devicons' },
        opts = {
            globalstatus = true,
            sections = {
                lualine_a = { 'mode' },
                lualine_b = { 'branch', 'diff', 'diagnostics' },
                lualine_c = { 'filename' },
                lualine_x = { 'searchcount', 'selectioncount' },
                lualine_y = {
                    'encoding',
                    'fileformat',
                    'location'
                    -- 'filetype'
                    --'lsp_status'
                },
                lualine_z = {}
            }
        }
    }
}
