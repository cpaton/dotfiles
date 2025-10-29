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

vim.lsp.enable('lua_ls')

-- go templates ending in teml should use their main filetype for their filetype
vim.filetype.add({
    pattern = {
        ['.*%.([%w_]+)%.tmpl'] = function(_, _, captures)
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
