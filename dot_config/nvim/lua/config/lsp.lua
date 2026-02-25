-- Neovim comes with an LSP client built in.  It then needs servers to connect to.
-- Servers are managed using Mason which can install and update them.
--
-- https://dev.to/vonheikemen/getting-started-with-neovims-native-lsp-client-in-the-year-of-2022-the-easy-way-bp3
-- https://vonheikemen.github.io/learn-nvim/feature/lsp-setup.html
-- Mainly using pre-canned lSP configurations from neovim/nvim-lspconfig
-- when enabling using a name we don't define here that is what's happening
-- also have the option to use an lsp folder (any folder called lsp in the runtimepath) with files matching the names
--
-- keybindings
-- ctrl-]          -> go to definition
-- gq              -> format selected text or text object
-- K               -> display documentation of the symbol under the cursor
-- ctrl-x + ctrl-o -> in insert mode, trigger code completion
--
-- grn        -> renames all references of the symbol under the cursor
-- gra        -> list code actions available in the line under the cursor
-- grr        -> lists all the references of the symbol under the cursor
-- gri        -> lists all the implementations for the symbol under the cursor
-- gO         -> lists all symbols in the current buffer
-- ctrl-s     -> in insert mode, display function signature under the cursor
-- [d         -> jump to previous diagnostic in the current buffer
-- ]d         -> jump to next diagnostic in the current buffer
-- ctrl-w + d -> show error/warning message in the line under the cursor

--[[
-- These keymaps are the defaults in Neovim v0.10
vim.keymap.set('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<cr>')
vim.keymap.set('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<cr>')
vim.keymap.set('n', '<C-w>d', '<cmd>lua vim.diagnostic.open_float()<cr>')
vim.keymap.set('n', '<C-w><C-d>', '<cmd>lua vim.diagnostic.open_float()<cr>')

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(event)
    local bufmap = function(mode, rhs, lhs)
      vim.keymap.set(mode, rhs, lhs, {buffer = event.buf})
    end

    -- These keymaps are the defaults in Neovim v0.11
    bufmap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>')
    bufmap('n', 'grr', '<cmd>lua vim.lsp.buf.references()<cr>')
    bufmap('n', 'gri', '<cmd>lua vim.lsp.buf.implementation()<cr>')
    bufmap('n', 'grn', '<cmd>lua vim.lsp.buf.rename()<cr>')
    bufmap('n', 'gra', '<cmd>lua vim.lsp.buf.code_action()<cr>')
    bufmap('n', 'gO', '<cmd>lua vim.lsp.buf.document_symbol()<cr>')
    bufmap({'i', 's'}, '<C-s>', '<cmd>lua vim.lsp.buf.signature_help()<cr>')
  end,
})
]]

-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#lua_ls`
local lua_ls_config = vim.lsp.config("lua_ls", {
    cmd = { "lua-language-server" },
    settings = {
        Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = { globals = { "vim" } },
            format = {
                enable = true,
                defaultConfig = {
                    indent_style = "space",
                    indent_size = "2",
                    quote_style = "double",
                    max_line_length = "220",
                },
            },
        },
    },
})
vim.lsp.enable("lua_ls")

local powershell_global_script_analyzer_settings = vim.fn.expand("~/.config/powershell/PSScriptAnalyzerSettings.psd1")
local function resolve_pssa_settings_path(root_dir)
    -- prefer repo-local file (exact name PSES looks for)
    local found = vim.fs.find("PSScriptAnalyzerSettings.psd1", { path = root_dir, upward = false })[1]
    if found then
        -- many clients use a path relative to the workspace root here
        return "PSScriptAnalyzerSettings.psd1"
    end
    return powershell_global_script_analyzer_settings
end


vim.lsp.config("powershell_es", {
    settings = {
        powershell = {
            enableProfileLoading = false,
            -- https://github.com/PowerShell/PowerShellEditorServices/blob/main/src/PowerShellEditorServices/Services/Workspace/LanguageServerSettings.cs
            codeFormatting = {
                addWhitespaceAroundPipe = true,
                autoCorrectAliases = false,
                avoidSemicolonsAsLineTerminators = true,
                useConstantStrings = true,
                preset = "Custom", -- Custom, Allman, OTBS, Stroustrup
                openBraceOnSameLine = true,
                newLineAfterOpenBrace = true,
                newLineAfterCloseBrace = true,
                pipelineIndentationStyle = "IncreaseIndentationForFirstPipeline", -- IncreaseIndentationForFirstPipeline, IncreaseIndentationAfterEveryPipeline, , NoIndentation, None
                trimWhitespaceAroundPipe = true,
                whitespaceBeforeOpenBrace = true,
                whitespaceBeforeOpenParen = true,
                whitespaceAroundOperator = true,
                whitespaceAfterSeparator = true,
                WhitespaceBetweenParameters = true,
                whitespaceInsideBrace = true,
                ignoreOneLineBlock = false,
                alignPropertyValuePairs = true,
                useCorrectCasing = true
            },
            codeFolding = {
                enable = true,
                showLastLine = true,
            },
            -- separate knob (analysis/settings file path):
            scriptAnalysis = {
                settingsPath = "PSScriptAnalyzerSettings.psd1",
            },
            enableReferencesCodeLens = true,
            analyzeOpenDocumentsOnly = false,
        },
    },
    on_init = function(client)
        local root = client.config.root_dir
        local settings_path = resolve_pssa_settings_path(root)
        client.config.settings = client.config.settings or {}
        client.config.settings.powershell = client.config.settings.powershell or {}
        client.config.settings.powershell.scriptAnalysis = client.config.settings.powershell.scriptAnalysis or {}
        client.config.settings.powershell.scriptAnalysis.settingsPath = settings_path

        -- optional but commonly needed to force-apply immediately:
        client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
    end,
})

-- go templates ending in tmpl should use their main filetype for their filetype
vim.filetype.add({
    pattern = {
        [".*%.([%w_]+)%.tmpl"] = function(_, _, captures)
            -- depending on nvim version captures is either a string or a table - handle both scenarios
            local ft
            if type(captures) == "table" then
                ft = captures[1]
            elseif type(captures) == "string" then
                ft = captures
            end
            -- print("Detected filetype:", ft)
            return ft
        end,
    },
})
