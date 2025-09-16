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
        'nvim-mini/mini.nvim',
        version = '*',
        enabled = false,
    },
    {
        's1n7ax/nvim-window-picker',
        name = 'window-picker',
        event = 'VeryLazy',
        version = '2.*'
    },
    -- https://github.com/rcarriga/nvim-notify
    -- general functions for showing notification popups
    {
        "rcarriga/nvim-notify",
        name = "nvim-notify"
    },

}

