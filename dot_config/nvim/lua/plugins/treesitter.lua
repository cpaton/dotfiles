-- https://github.com/nvim-treesitter/nvim-treesitter
-- syntax highlighting, code navigation, and more
-- treesitter is a component built into Neovim. On its own its not very useful
-- nvim-treesitter provides parser management and queries for tree-sitter features
--
-- Requirements (main branch):
--   neovim 0.12+
--   tree-sitter-cli 0.26.1+ (installed via mise)
--   a C compiler (gcc/clang)
return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        build = ":TSUpdate",
        config = function()
            -- Install parsers (no-op if already installed)
            require('nvim-treesitter').install {
                'bash',
                'c_sharp',
                'css',
                'csv',
                'dockerfile',
                'editorconfig',
                'git_config',
                'git_rebase',
                'gitattributes',
                'gitcommit',
                'gitignore',
                'go',
                'gomod',
                'gosum',
                'gotmpl',
                'groovy',
                'hcl',
                'helm',
                'html',
                'javascript',
                'json',
                'lua',
                'markdown',
                'markdown_inline',
                'powershell',
                'python',
                'regex',
                'requirements',
                'sql',
                'ssh_config',
                'terraform',
                'typescript',
                'vim',
                'yaml',
            }

            -- Enable highlighting and indentation for all filetypes with a parser
            vim.api.nvim_create_autocmd('FileType', {
                callback = function(args)
                    if pcall(vim.treesitter.start, args.buf) then
                        vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                    end
                end,
            })
        end
    }
}
