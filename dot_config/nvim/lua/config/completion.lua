-- https://neovim.io/doc/user/insert.html#ins-completion
--[[
Completion can be done for:
1. Whole lines						            i_CTRL-X_CTRL-L
2. keywords in the current file				    i_CTRL-X_CTRL-N
3. keywords in 'dictionary'				        i_CTRL-X_CTRL-K
4. keywords in 'thesaurus', thesaurus-style		i_CTRL-X_CTRL-T
5. keywords in the current and included files	i_CTRL-X_CTRL-I
6. tags							                i_CTRL-X_CTRL-]
7. file names						            i_CTRL-X_CTRL-F
8. definitions or macros				        i_CTRL-X_CTRL-D
9. Vim command-line					            i_CTRL-X_CTRL-V
10. User defined completion				        i_CTRL-X_CTRL-U
11. omni completion					            i_CTRL-X_CTRL-O
12. Spelling suggestions				        i_CTRL-X_s
13. completions from 'complete'				    i_CTRL-N i_CTRL-P
14. contents from registers				        i_CTRL-X_CTRL-R
]]

-- require('mini.completion').setup({
--     -- fallback_action = "<C-x><C-o>",
--     mappings = {
--         force_twostep = '', -- <C-Space>
--         force_fallback = '' -- <A-Space>
--     }
-- })
-- local gen_loader = require('mini.snippets').gen_loader
-- require('mini.snippets').setup({
--   snippets = {
--     -- Load custom file with global snippets first (adjust for Windows)
--     -- gen_loader.from_file('~/.config/nvim/snippets/global.json'),

--     -- Load snippets based on current language by reading files from
--     -- "snippets/" subdirectories from 'runtimepath' directories.
--     gen_loader.from_lang(),
--   },
-- })
-- require('mini.icons').setup({})
-- MiniIcons.tweak_lsp_kind()

local cmp = require('cmp')
cmp.setup({
    --completion = {
    --    autocomplete = false -- prevent automatic popup of completion menu
    --},

    snippet = {
        -- REQUIRED - you must specify a snippet engine
        expand = function(args)
            -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
            require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
            -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
            -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
            -- vim.snippet.expand(args.body) -- For native neovim snippets (Neovim v0.10+)

            -- For `mini.snippets` users:
            -- local insert = MiniSnippets.config.expand.insert or MiniSnippets.default_insert
            -- insert({ body = args.body }) -- Insert at cursor
            -- cmp.resubscribe({ "TextChangedI", "TextChangedP" })
            -- require("cmp.config").set_onetime({ sources = {} })
        end,
    },
    window = {
        completion = cmp.config.window.bordered({
            scrollbar = true,
            max_width = 140
        }),
        documentation = cmp.config.window.bordered({
            scrollbar = true,
            max_width = 140
        }),
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(), -- doesn't generally work in my setup
        ['<C-l>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping(function(fallback)
            -- Having enter accept the intellisense suggestion was too agressive when enabled everywhere
            -- But it was the natural key to use when explicitly selecting an item from the popup
            -- This function attempts to use the best of both worlds and have enter only work when an item has been selecteed in the popup
            if cmp.visible() and cmp.get_selected_entry() then
                cmp.confirm({ select = false })
            else
                fallback() -- behave like normal <CR>
            end
        end, { "i", "s" }),
        ["<Tab>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
        ["<S-Tab>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
        ['<C-y>'] = cmp.mapping.confirm({ select = true }),
        --['<Right>'] = cmp.mapping.confirm({ select = true }),
        ['<M-Right>'] = cmp.mapping.confirm({ select = true }),
    }),
    sources = cmp.config.sources(
    -- each array acts as its own group
    -- if a group doesn't return anything it falls back to the next group
        {
            { name = 'nvim_lsp_signature_help' }
        },
        {
            { name = 'copilot' },
            { name = 'nvim_lsp' },
            { name = 'luasnip' },
            { name = 'path' },
            { name = 'buffer' },
        }
    ),
    experimental = {
        ghost_text = true
    }
})
-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = 'buffer' }
    }
})
-- Hide copilot suggestions when the completion menu is open
cmp.event:on("menu_opened", function()
    vim.b.copilot_suggestion_hidden = true
end)
cmp.event:on("menu_closed", function()
    vim.b.copilot_suggestion_hidden = false
end)

-- add a delay to how quickly the auto complete menu shows up
local debounce_timer = nil
local debounce_ms = 500

cmp.event:on("TextChangedI", function()
    if debounce_timer then
        debounce_timer:stop()
        debounce_timer:close()
    end

    debounce_timer = vim.defer_fn(function()
        if cmp.visible() then
            cmp.complete()
        else
            cmp.complete()
        end
    end, debounce_ms)
end)
