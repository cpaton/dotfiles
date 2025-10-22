return {
    {
        -- https://github.com/folke/which-key.nvim
        -- displays help text for key bindings
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            preset = "modern",
            delay = 1000
        },
        keys = {
            {
                "<leader>?",
                function()
                    require("which-key").show({ global = false })
                end,
                desc = "Buffer Local Keymaps (which-key)",
            },
        }
    },
    {
        -- https://github.com/nvim-lua/plenary.nvim
        -- bunch of lua functions author wants to share between many of their modules
        "nvim-lua/plenary.nvim",
    },
    {
        'nvim-mini/mini.nvim',
        version = '*',
        enabled = false,
    },
    {
        's1n7ax/nvim-window-picker',
        event = 'VeryLazy',
        version = '2.*'
    },
    -- https://github.com/rcarriga/nvim-notify
    -- general functions for showing notification popups
    {
        "rcarriga/nvim-notify",
    },
    {
        'MeanderingProgrammer/render-markdown.nvim',
        dependencies = {
            'nvim-treesitter/nvim-treesitter',
            'nvim-tree/nvim-web-devicons'
        }, -- if you use the mini.nvim suite
        -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.icons' }, -- if you use standalone mini plugins
        -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
        ---@module 'render-markdown'
        ---@type render.md.UserConfig
        opts = {
            file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
    },
    -- https://github.com/famiu/bufdelete.nvim
    -- Delete buffers without messing up window layout
    {
        "famiu/bufdelete.nvim",
    },
}
