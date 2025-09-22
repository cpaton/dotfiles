-- https://www.joshmedeski.com/posts/ai-in-neovim-neovimconf-2024/
return {
    {
        -- https://github.com/github/copilot.vim
        -- https://github.com/github/copilot.vim/blob/release/doc/copilot.txt
        "github/copilot.vim",
        enabled = false, -- using copilot.lua instead
    },
    {
        -- GitHub CoPilt Chat within Neovim
        -- https://copilotc-nvim.github.io/CopilotChat.nvim/#/
        -- awkward way of adding contexxt in chat and wouldn't run any tools to read from the file system
        "CopilotC-Nvim/CopilotChat.nvim",
        enabled = false,
        dependencies = {
            { "plenary" },
        },
        -- build = "make tiktoken",
        opts = {
            -- See Configuration section for options
        },
    },
    {
        -- https://github.com/copilotlsp-nvim/copilot-lsp
        -- integrate GitHub Copilot with Neovim's built-in LSP client
        -- displays Next Edit Suggestions (NES) inline and provides code completions via the LSP interface
        "copilotlsp-nvim/copilot-lsp",
        init = function()
            vim.g.copilot_nes_debounce = 500
            vim.lsp.enable("copilot_ls")
            vim.keymap.set("n", "<tab>", function()
                local bufnr = vim.api.nvim_get_current_buf()
                local state = vim.b[bufnr].nes_state
                if state then
                    -- Try to jump to the start of the suggestion edit.
                    -- If already at the start, then apply the pending suggestion and jump to the end of the edit.
                    local _ = require("copilot-lsp.nes").walk_cursor_start_edit()
                        or (
                            require("copilot-lsp.nes").apply_pending_nes()
                            and require("copilot-lsp.nes").walk_cursor_end_edit()
                        )
                    return nil
                else
                    -- Resolving the terminal's inability to distinguish between `TAB` and `<C-i>` in normal mode
                    return "<C-i>"
                end
            end, { desc = "Accept Copilot NES suggestion", expr = true })
            opts = {
                nes = {
                    move_count_threshold = 3, -- Clear after 3 cursor movements
                },
            }
        end,
    },
    {
        -- https://github.com/zbirenbaum/copilot.lua
        -- CoPilot extension written in Lua as a replacement for copilot.vim
        "zbirenbaum/copilot.lua",
        event = "InsertEnter", -- load when entering insert mode to speed up startup
        opts = {
            panel = {
                enabled = false,     -- disable the panel to prevent interference with nvim-cmp
                auto_refresh = true, -- refresh panel as you type
            },
            suggestion = {
                enabled = true,      -- disable inline suggestions to use copilot-lsp instead
                auto_trigger = true, -- start making suggestions as soon as entering insert mode
                keymap = {
                    accept = "<M-l>",
                    accept_word = false,
                    accept_line = false,
                    next = "<M-]>",
                    prev = "<M-[>",
                    dismiss = "<C-]>",
                }
            },
            nes = {
                enabled = true,
                auto_trigger = true,
            },
            filetypes = {
                -- ["markdown"] = false, -- disable in markdown files
                ["*"] = true, -- enable for all filetypes
            },
        }
    }
}
