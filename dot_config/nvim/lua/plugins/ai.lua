return {
    {
        -- https://github.com/github/copilot.vim
        -- https://github.com/github/copilot.vim/blob/release/doc/copilot.txt
        "github/copilot.vim"
    },
    {
        -- GitHub CoPilt Chat within Neovim
        -- https://copilotc-nvim.github.io/CopilotChat.nvim/#/
        "CopilotC-Nvim/CopilotChat.nvim",
        dependencies = {
            { "plenary" },
        },
        -- build = "make tiktoken",
        opts = {
            -- See Configuration section for options
        },
    },
}
