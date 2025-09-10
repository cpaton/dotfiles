return {
    -- { "rafamadriz/friendly-snippets" }
    {
        "hrsh7th/nvim-cmp",
        enabled = tru
    },
    {
		-- code completion source for filesystem paths
		"hrsh7th/cmp-path"
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
	}
}