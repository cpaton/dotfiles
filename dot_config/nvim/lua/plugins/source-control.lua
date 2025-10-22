return {
    {
        -- https://github.com/tpope/vim-fugitive
        -- Git plugin
        "tpope/vim-fugitive"
    },
    {
        -- https://github.com/kdheepak/lazygit.nvim
        -- LazyGit within Neovim
        "kdheepak/lazygit.nvim",
        lazy = true,
        cmd = { "LazyGit" },
        opts = {}
    }
}
