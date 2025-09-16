return {
    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'web-devicons' },
        opts = {
            options = {
                globalstatus = true,
            },
            -- status line across bottom of screen
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
            },
            extensions = {
                'fugitive',
                'lazy',
                'mason',
                'neo-tree'
            },
            -- tab bar shown at top of screen
            tabline = {
                -- lualine_a = {},
                -- lualine_b = { 'buffers' },
                -- lualine_c = {},
                -- lualine_x = {},
                -- lualine_y = {},
                -- lualine_z = {}
            },
            -- tab bar shown on top of a single pane
            winbar = {
                -- lualine_a = { 'filename' },
                -- lualine_b = {},
                -- lualine_c = {},
                -- lualine_x = {},
                -- lualine_y = {},
                -- lualine_z = {}
            },
            inactive_winbar = {
                -- lualine_a = { 'filename' }
            }
        }
    }
}
