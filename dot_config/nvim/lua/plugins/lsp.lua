-- Mason is the NeoVIM package manager for LSP servers, DAP servers, linters, and formatters
-- https://github.com/mason-org/mason.nvim
-- https://deepwiki.com/williamboman/mason.nvim

return {
    {
        "mason-org/mason.nvim",
        opts = {}
    },
    {
        -- set of configurations to neovims built in LSP client
        "neovim/nvim-lspconfig",
    },
    {
        -- Utility functions to connect mason and lspconfig.
        -- Since Neovim 0.11 this has less use, but does provide a couple of features
        -- LspInstall command, and auto-enabling lsp servers installed via mason, including translating the mason name to that known by nvim-lspconfig
        "mason-org/mason-lspconfig.nvim",
        opts = {
            ensure_installed = {
                "copilot",
                "dockerls",
                "lua_ls",
                "powershell_es"
            },
        },
        dependencies = {
            { "mason-org/mason.nvim", opts = {} },
            "neovim/nvim-lspconfig",
        }
    }
}
