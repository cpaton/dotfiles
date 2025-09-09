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

require('mini.completion').setup({
    -- fallback_action = "<C-x><C-o>",
    mappings = {
        force_twostep = '', -- <C-Space>
        force_fallback = '' -- <A-Space>
    }
})
local gen_loader = require('mini.snippets').gen_loader
require('mini.snippets').setup({
  snippets = {
    -- Load custom file with global snippets first (adjust for Windows)
    -- gen_loader.from_file('~/.config/nvim/snippets/global.json'),

    -- Load snippets based on current language by reading files from
    -- "snippets/" subdirectories from 'runtimepath' directories.
    gen_loader.from_lang(),
  },
})
require('mini.icons').setup({})
MiniIcons.tweak_lsp_kind()