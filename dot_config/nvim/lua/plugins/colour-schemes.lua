return {
    {
		-- color scheme
		"rose-pine/neovim",
		name = "rose-pine",
		enabled = true,
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
        enabled = true,
        priority = 1000,
        opts = {
            flavour = "frappe", -- latte, frappe, macchiato, mocha
        },
    }
}