---@module "gitsigns"

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
        cmd = {
            "LazyGit",
            "LazyGitConfig",
            "LazyGitCurrentFile",
            "LazyGitFilter",
            "LazyGitFilterCurrentFile",
        },
        opts = {}
    },
    {
        -- https://github.com/lewis6991/gitsigns.nvim
        -- Integration of Git information into buffers - e.g. line changed, inline blame etc
        "lewis6991/gitsigns.nvim",
        ---@type Gitsigns.Config
        opts = {
            signs_staged_enable = true,
            signcolumn = true,
            word_diff = true,
            auto_attach = true,
            attach_to_untracked = false,
            current_line_blame = true, -- Toggle with `:Gitsigns toggle_current_line_blame`
            current_line_blame_opts = {
                virt_text = true,
                virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
                delay = 2000,
                ignore_whitespace = false,
                virt_text_priority = 100,
                use_focus = true,
            },
            current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
            max_file_length = 40000, -- Disable if file is longer than this (in lines)
            on_attach = function(bufnr)
                require("config.keymaps").gitsigns(bufnr)
            end
        }
    }
}
