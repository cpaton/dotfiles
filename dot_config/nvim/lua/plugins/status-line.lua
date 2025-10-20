return {
    {
        'nvim-lualine/lualine.nvim',
        dependencies = {
            'nvim-tree/nvim-web-devicons',
            'AndreM222/copilot-lualine'
        },
        enabled = true,
        opts = {
            options = {
                globalstatus = true,
            },
            -- status line across bottom of screen
            sections = {
                lualine_a = { 'mode' },
                lualine_b = { 'branch', 'diff', 'diagnostics' },
                lualine_c = {
                    -- https://github.com/nvim-lualine/lualine.nvim?tab=readme-ov-file#filename-component-options
                    {
                        'filename',
                        path = 1, -- relative path
                    }
                },
                lualine_x = { 'searchcount', 'selectioncount' },
                lualine_y = {
                    'copilot',
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
    },
    {
        -- displays copilot status in lualine
        'AndreM222/copilot-lualine'
    },
    {
        -- tab bars across the top of the screen
        'akinsho/bufferline.nvim',
        branch = "main",
        dependencies = {
            'nvim-tree/nvim-web-devicons',
            'catppuccin/nvim'
        },
        opts = function()
            --vim.cmd.colorscheme "catppuccin"
            local bufferline = require('bufferline')
            -- local catppuccin = require('catppuccin')
            return {
                options = {
                    mode = "buffers",
                    style_preset = bufferline.style_preset.default,
                    numbers = "none",
                    -- highlights = catppuccin.groups.integrations.bufferline.get(),
                    indicator = {
                        style = 'underline',
                    },
                    diagnostics = "nvim_lsp",
                    tab_size = 15,
                    max_name_length = 18,
                    show_tab_indicators = true,
                    show_close_icon = true,
                    show_buffer_icons = false,
                    show_buffer_close_icons = false,
                    separator_style = "slant",
                    always_show_bufferline = true,
                    offsets = {
                        {
                            filetype = "neo-tree",
                            text = "File Explorer",
                            highlight = "Directory",
                            text_align = "center"
                        }
                    },
                    hover = {
                        enabled = true,
                        delay = 200,
                        reveal = { 'close' }
                    }
                }
            }
        end
    }
}
