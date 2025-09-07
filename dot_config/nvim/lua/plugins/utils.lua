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
	}
}