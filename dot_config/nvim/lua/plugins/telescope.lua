-- https://github.com/nvim-telescope/telescope.nvim
-- highly extendable fuzzy finder over lists
-- non vim dependencies:
--   rigrep - https://github.com/BurntSushi/ripgrep
--   fd - https://github.com/sharkdp/fd
return {
    {
        -- https://github.com/nvim-lua/plenary.nvim
        -- depenendcy of telescope - bunch of lua functions author wants to share between many of their modules
        "nvim-lua/plenary.nvim",
        name = "plenary"
    },
    {
        -- provides more performant list sorting in telescope
        "nvim-telescope/telescope-fzy-native.nvim",
        name = "fzy-native"
    },
    {
        "nvim-telescope/telescope.nvim",
        branch = '0.1.x', -- recommend not using master branch for stability
        dependencies = {
            "plenary",
            "fzy-native"
        },
        config = function()
            local tele = require("telescope")
            tele.setup({
                extensions = {
                    fzy_native = {
                        override_generic_sorter = false,
                        override_file_sorter = true,
                    }
                }
            })
            tele.load_extension("fzy_native")
        end
    }
}
