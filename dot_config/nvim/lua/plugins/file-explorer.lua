return {
    {
        -- https://github.com/MunifTanjim/nui.nvim
        -- re-usable UI components
        "MunifTanjim/nui.nvim",
    },
    {
        -- https://github.com/nvim-tree/nvim-web-devicons
        -- file type icons
        "nvim-tree/nvim-web-devicons",
    },
    {
        -- https://github.com/nvim-neo-tree/neo-tree.nvim
        -- modern file explorer
        -- https://github.com/nvim-neo-tree/neo-tree.nvim/wiki
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "nvim-tree/nvim-web-devicons"
        },
        ---@type neotree.Config
        opts = {
            -- removed Terminal from this list to avoid unwanted splits
            open_files_do_not_replace_types = { "Trouble", "qf", "edgy" }, -- when opening files, do not use windows containing these filetypes or buftypes
            close_if_last_window = true,
            enable_diagnostics = true,
            window = {
                width = 35,
                mappings = {
                    ['aa'] = 'avante_add_files',
                }
            },
            filesystem = {
                filtered_items = {
                    hide_gitignored = false
                },
                hijack_netrw_behavior = "open_current",
                commands = {
                    avante_add_files = function(state)
                        local node = state.tree:get_node()
                        local filepath = node:get_id()
                        local relative_path = require('avante.utils').relative_path(filepath)

                        local sidebar = require('avante').get()

                        local open = sidebar:is_open()
                        -- ensure avante sidebar is open
                        if not open then
                            require('avante.api').ask()
                            sidebar = require('avante').get()
                        end

                        sidebar.file_selector:add_selected_file(relative_path)

                        -- remove neo tree buffer
                        if not open then
                            sidebar.file_selector:remove_selected_file('neo-tree filesystem [1]')
                            sidebar.file_selector:remove_selected_file('neo-tree filesystem [1000]')
                        end
                    end,
                }
            },
            sources = {
                "filesystem",
                "buffers",
                "git_status",
                "diagnostics"
            },
        }
    },
    {
        "antosha417/nvim-lsp-file-operations",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-neo-tree/neo-tree.nvim"
        },
        lazy = false
        -- config = function()
        --   require("lsp-file-operations").setup()
        -- end,
    },
    {
        -- https://github.com/mrbjarksen/neo-tree-diagnostics.nvim
        -- adds diagnostics source to neo-tree
        "mrbjarksen/neo-tree-diagnostics.nvim",
        dependencies = {
            "nvim-neo-tree/neo-tree.nvim"
        }
    }
}
