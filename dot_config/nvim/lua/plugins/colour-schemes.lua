return {
    {
        -- color scheme
        "rose-pine/neovim",
        name = "rose-pine",
        enabled = false,
        -- config = function()
        -- 	vim.cmd('colorscheme rose-pine')
        -- end
    },
    {
        -- https://github.com/maxmx03/solarized.nvim
        "maxmx03/solarized.nvim",
        lazy = false,
        enabled = true,
        priority = 1000,
        config = function()
            vim.o.background = 'dark'
            -- vim.cmd('colorscheme solarized')
        end
    },
    {
        -- https://github.com/catppuccin/nvim
        "catppuccin/nvim",
        name = "catppuccin",
        dependencies = { "akinsho/bufferline.nvim" },
        enabled = true,
        priority = 1000,
        config = function()
            require("catppuccin").setup({
                flavour = "frappe", -- latte, frappe, macchiato, mocha
                integrations = {
                    bufferline = true,
                    notify = true
                }
            })
            vim.cmd.colorscheme "catppuccin"
        end
    }
}
