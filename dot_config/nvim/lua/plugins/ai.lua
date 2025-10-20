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
            { "nvim-lua/plenary.nvim" },
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
        enabled = false,
        init = function()
            vim.g.copilot_nes_debounce = 3000
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
        enabled = true,
        event = "InsertEnter", -- load when entering insert mode to speed up startup
        opts = {
            panel = {
                enabled = false,     -- disable the panel to prevent interference with nvim-cmp
                auto_refresh = true, -- refresh panel as you type
            },
            suggestion = {
                enabled = true,           -- disable inline suggestions to use copilot-lsp instead
                auto_trigger = false,     -- start making suggestions as soon as entering insert mode
                hide_during_completions = true,
                trigger_on_accept = true, -- copilot.lua should handle the accept keymap
                debounce = 2000,
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
                enabled = false,
                auto_trigger = true,
            },
            filetypes = {
                -- ["markdown"] = false, -- disable in markdown files
                ["*"] = true, -- enable for all filetypes
            },
        }
    },
    {
        "yetone/avante.nvim",
        -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
        -- ⚠️ must add this setting! ! !
        build = vim.fn.has("win32") ~= 0
            and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
            or "make",
        event = "VeryLazy",
        version = false, -- Never set this value to "*"! Never!
        -- https://github.com/yetone/avante.nvim/blob/main/lua/avante/config.lua
        ---@module 'avante'
        ---@type avante.Config
        opts = {
            -- add any opts here
            -- this file can contain specific instructions for your project
            instructions_file = "avante.md",
            -- for example
            provider = "copilot",
            mode = "agentic",
            -- auto_suggestion_provider = "copilot", -- disabled for now as Copilot has issues https://github.com/yetone/avante.nvim/issues/1048
            behaviour = {
                auto_suggestions = false,
                auto_approve_tool_permissions = false, -- Default: show permission prompts for all tools
                -- Examples:
                -- auto_approve_tool_permissions = true,                -- Auto-approve all tools (no prompts)
                -- auto_approve_tool_permissions = {"bash", "replace_in_file"}, -- Auto-approve specific tools only
            },
            suggestion = {
                debounce = 1000,
                throttle = 1000,
            },
            rules = {
                project_dir = nil, ---@type string | nil (could be relative dirpath)
                global_dir = nil, ---@type string | nil (absolute dirpath)
            },
            providers = {
                ---@type AvanteSupportedProvider
                copilot = {
                    endpoint = "https://api.githubcopilot.com",
                    model = "claude-sonnet-4",
                    proxy = nil,            -- [protocol://]host[:port] Use this proxy
                    allow_insecure = false, -- Allow insecure server connections
                    timeout = 30000,        -- Timeout in milliseconds
                    context_window = 64000, -- Number of tokens to send to the model for context
                    extra_request_body = {
                        temperature = 0.75,
                        max_tokens = 20480,
                    },
                },
                ---@type AvanteSupportedProvider
                bedrock = {
                    model = "us.anthropic.claude-3-7-sonnet-20250219-v1:0",
                    model_names = {
                        "anthropic.claude-3-5-sonnet-20241022-v2:0",
                        "us.anthropic.claude-3-7-sonnet-20250219-v1:0",
                        "us.anthropic.claude-opus-4-20250514-v1:0",
                        "us.anthropic.claude-opus-4-1-20250805-v1:0",
                        "us.anthropic.claude-sonnet-4-20250514-v1:0",
                    },
                    timeout = 30000, -- Timeout in milliseconds
                    extra_request_body = {
                        temperature = 0.75,
                        max_tokens = 20480,
                    },
                    aws_region = "eu-west-1", -- AWS region to use for authentication and bedrock API
                    aws_profile = "",         -- AWS profile to use for authentication, if unspecified uses default credentials chain
                },
            },
            selectors = {
                provider = "telescope"
            },
        },
        dependencies = {
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            --- The below dependencies are optional,
            --"echasnovski/mini.pick",         -- for file_selector provider mini.pick
            "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
            "hrsh7th/nvim-cmp",              -- autocompletion for avante commands and mentions
            --"ibhagwan/fzf-lua",              -- for file_selector provider fzf
            --"stevearc/dressing.nvim",        -- for input provider dressing
            --"folke/snacks.nvim",             -- for input provider snacks
            "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
            "zbirenbaum/copilot.lua",      -- for providers='copilot'
            --[[
            {
                -- support for image pasting
                "HakonHarnes/img-clip.nvim",
                event = "VeryLazy",
                opts = {
                    -- recommended settings
                    default = {
                        embed_image_as_base64 = false,
                        prompt_for_file_name = false,
                        drag_and_drop = {
                            insert_mode = true,
                        },
                        -- required for Windows users
                        use_absolute_path = true,
                    },
                },
            },
            ]]
        }
    }
}
