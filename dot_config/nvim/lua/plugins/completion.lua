return {
    -- { "rafamadriz/friendly-snippets" }
    {
        "hrsh7th/nvim-cmp",
        enabled = true
    },
    {
        -- code completion source for filesystem paths
        "hrsh7th/cmp-path"
    },
    {
        -- current buffer words
        "hrsh7th/cmp-buffer"
    },
    {
        -- code completion source for lsp
        "hrsh7th/cmp-nvim-lsp"
    },
    {
        -- snippets
        "L3MON4D3/LuaSnip",
        version = "v2.*",
        dependencies = {
            "rafamadriz/friendly-snippets"
        }
    },
    {
        -- luasnip completion source for nvim-cmp
        "saadparwaiz1/cmp_luasnip"
    },
    {
        -- additional code snippets for many languages
        "rafamadriz/friendly-snippets"
    },
    {
        -- https://github.com/zbirenbaum/copilot-cmp
        -- turn copilot suggestions into nvim-cmp suggestions
        "zbirenbaum/copilot-cmp",
        dependencies = {
            "zbirenbaum/copilot.lua"
        },
        opts = {}
    },
    {
        -- https://github.com/folke/lazydev.nvim
        -- Enhances Lua development in Neovim by providing additional type information for popular libraries.
        -- Provides IntelliSense when configuring plugins
        "folke/lazydev.nvim",
        ft = "lua", -- only load on lua files
        opts = {
            library = {
                -- See the configuration section for more details
                -- Load luvit types when the `vim.uv` word is found
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            },
        },
    }
}
