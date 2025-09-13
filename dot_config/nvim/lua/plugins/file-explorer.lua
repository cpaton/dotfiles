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
        "nvim-neo-tree/neo-tree.nvim",
        name = "neo-tree",
        branch = "v3.x",
        dependencies = {
            "plenary",
            "nui",
            "web-devicons"
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
      }
}