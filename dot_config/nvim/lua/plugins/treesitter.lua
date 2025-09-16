-- https://github.com/nvim-treesitter/nvim-treesitte
-- syntax highlighting, code navigation, and more
-- treesitter is a component built into Neovim.  On its own its not very useful
-- nvim-treesitter hooks into this component and makes it easier to configure language support e.g. installing parsers
--
-- custom stuff required for windows support see https://github.com/nvim-treesitter/nvim-treesitter/wiki/Windows-support
-- c compiler is required - I went with scoop install mingw which gives you gcc on your path
return {
    {
        "nvim-treesitter/nvim-treesitter",
        name = "treesitter",
        enabled = true,
        config = function()
            local install = require("nvim-treesitter.install")
            -- docs suggest uing curl+tar but this doesn't work within the enterprise network - suspect due to certificates
            install.prefer_git = true

            local configs = require("nvim-treesitter.configs")
            configs.setup({
                ensure_installed                  = {
                    "bash",
                    "c_sharp",
                    "css",
                    "csv",
                    "dockerfile",
                    "editorconfig",
                    "git_config",
                    "git_rebase",
                    "gitattributes",
                    "gitcommit",
                    "gitignore",
                    "go",
                    "gomod",
                    "gosum",
                    "gotmpl",
                    "groovy",
                    "hcl",
                    "helm",
                    "html",
                    "javascript",
                    "json",
                    "lua",
                    "markdown",
                    "markdown_inline",
                    "powershell",
                    "python",
                    "regex",
                    "requirements",
                    "sql",
                    "ssh_config",
                    "terraform",
                    "tmux",
                    "typescript",
                    "vim",
                    "yaml"
                },
                sync_install                      = false,
                auto_install                      = true,
                highlight                         = { enable = true },
                indent                            = { enable = true },
                additional_vim_regex_highlighting = false,
                incremental_selection             = {
                    enable = true
                }
            })
        end,
        build = function()
            -- when the module is installed or updated ensure the language parsers are updated also
            vim.cmd("TSUpdate")
        end
    }
}
