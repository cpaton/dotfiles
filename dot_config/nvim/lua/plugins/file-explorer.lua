return {
    {
        -- https://github.com/MunifTanjim/nui.nvim
        -- re-usable UI components
        "MunifTanjim/nui.nvim",
        name = "nui",
    },
    {
        -- https://github.com/nvim-tree/nvim-web-devicons
        -- file type icons
        "nvim-tree/nvim-web-devicons",
        name = "web-devicons"
    },
    {
        -- https://github.com/nvim-neo-tree/neo-tree.nvim
        -- modern file explorer
        -- https://github.com/nvim-neo-tree/neo-tree.nvim/wiki
        "nvim-neo-tree/neo-tree.nvim",
        name = "neo-tree",
        branch = "v3.x",
        dependencies = {
            "plenary",
            "nui",
            "web-devicons"
        },
        opts = {
            close_if_last_window = true,
            enable_diagnostics = true,
            window = {
                width = 35
            },
            filesystem = {
                filtered_items = {
                    hide_gitignored = false
                },
                hijack_netrw_behavior = "open_default",
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
            "plenary",
            "neo-tree",
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
        name = "neo-tree-diagnostics",
        dependencies = {
            "neo-tree"
        }
    }
}
