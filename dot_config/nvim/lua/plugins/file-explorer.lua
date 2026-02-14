local function flash_neotree_row(state, opts)
    opts = opts or {}
    local hl = opts.hl or "Visual"
    local timeout = opts.timeout or 200
    local bufnr = state.bufnr
    local ns = vim.api.nvim_create_namespace("NeoTreeCopyFlash")
    local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1
    local id = vim.api.nvim_buf_set_extmark(bufnr, ns, lnum, 0, {
        hl_group = hl,
        end_line = lnum + 1,
        end_col = 0,
        hl_eol = true, -- highlight to end-of-line
    })
    vim.defer_fn(function()
        if vim.api.nvim_buf_is_valid(bufnr) then
            pcall(vim.api.nvim_buf_del_extmark, bufnr, ns, id)
        end
    end, timeout)
end

return {
    {
        -- https://github.com/MunifTanjim/nui.nvim
        -- re-usable UI components
        "MunifTanjim/nui.nvim",
    },
    {
        -- https://github.com/nvim-tree/nvim-web-devicons
        -- file type icons
        "nvim-tree/nvim-web-devicons",
    },
    {
        -- https://github.com/nvim-neo-tree/neo-tree.nvim
        -- modern file explorer
        -- https://github.com/nvim-neo-tree/neo-tree.nvim/wiki
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "nvim-tree/nvim-web-devicons"
        },
        ---@type neotree.Config
        opts = {
            -- removed Terminal from this list to avoid unwanted splits
            open_files_do_not_replace_types = { "Trouble", "qf", "edgy" }, -- when opening files, do not use windows containing these filetypes or buftypes
            close_if_last_window = true,
            enable_diagnostics = true,
            window = {
                width = 35,
                mappings = {
                    ['aa']         = 'avante_add_files',
                    ['<leader>cp'] = 'copy_full_path',
                    ['<leader>cf'] = 'copy_filename',
                    ['<leader>cb'] = 'copy_filename_without_extension',
                    ['<leader>cr'] = 'copy_relative_path',
                    ["<Left>"]     = "close_node", -- collapse (or go to parent if already collapsed)
                    ["<Right>"]    = "open",       -- expand dir / open file
                }
            },
            filesystem = {
                filtered_items = {
                    hide_gitignored = false
                },
                hijack_netrw_behavior = "open_current",
                commands = {
                    avante_add_files = function(state)
                        local node = state.tree:get_node()
                        local filepath = node:get_id()
                        local relative_path = require('avante.utils').relative_path(filepath)

                        local sidebar = require('avante').get()

                        local open = sidebar:is_open()
                        -- ensure avante sidebar is open
                        if not open then
                            require('avante.api').ask()
                            sidebar = require('avante').get()
                        end

                        sidebar.file_selector:add_selected_file(relative_path)

                        -- remove neo tree buffer
                        if not open then
                            sidebar.file_selector:remove_selected_file('neo-tree filesystem [1]')
                            sidebar.file_selector:remove_selected_file('neo-tree filesystem [1000]')
                        end
                    end,
                    copy_full_path = function(state)
                        local node = state.tree:get_node()
                        local path = node:get_id() -- full path
                        vim.fn.setreg("+", path)   -- system clipboard
                        vim.fn.setreg('"', path)   -- unnamed register (optional)
                        -- vim.notify(path)
                        flash_neotree_row(state, { hl = "IncSearch", timeout = 300 })
                    end,
                    copy_filename = function(state)
                        local node = state.tree:get_node()
                        local filename = node.name or vim.fn.fnamemodify(node:get_id(), ":t")
                        vim.fn.setreg("+", filename) -- system clipboard
                        -- vim.notify(filename)
                        flash_neotree_row(state, { hl = "IncSearch", timeout = 300 })
                    end,
                    copy_filename_without_extension = function(state)
                        local node = state.tree:get_node()
                        local filename = node.name or vim.fn.fnamemodify(node:get_id(), ":t")
                        local filename_without_ext = vim.fn.fnamemodify(filename, ":r")
                        vim.fn.setreg("+", filename_without_ext) -- system clipboard
                        -- vim.notify(filename_without_ext)
                        flash_neotree_row(state, { hl = "IncSearch", timeout = 300 })
                    end,
                    copy_relative_path = function(state)
                        local node = state.tree:get_node()
                        local abs = node:get_id()
                        local root = state.path                                 -- neo-tree filesystem root
                        local rel = vim.fs.relpath(root, abs)                   -- nvim 0.9+
                        if not rel then rel = vim.fn.fnamemodify(abs, ":.") end -- fallback
                        vim.fn.setreg("+", rel)
                        -- vim.notify(rel)
                        flash_neotree_row(state, { hl = "IncSearch", timeout = 300 })
                    end,
                }
            },
            sources = {
                "filesystem",
                "buffers",
                "git_status",
                "diagnostics"
            },
        }
    },
    {
        "antosha417/nvim-lsp-file-operations",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-neo-tree/neo-tree.nvim"
        },
        lazy = false
        -- config = function()
        --   require("lsp-file-operations").setup()
        -- end,
    },
    {
        -- https://github.com/mrbjarksen/neo-tree-diagnostics.nvim
        -- adds diagnostics source to neo-tree
        "mrbjarksen/neo-tree-diagnostics.nvim",
        dependencies = {
            "nvim-neo-tree/neo-tree.nvim"
        }
    }
}
