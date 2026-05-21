return {
    {
        -- https://github.com/akinsho/toggleterm.nvim
        -- Persistent terminals that can be toggled in different window layouts.
        "akinsho/toggleterm.nvim",
        version = "*",
        cmd = {
            "ToggleTerm",
            "ToggleTermToggleAll",
            "TermExec",
            "TermNew",
            "TermSelect",
        },
        opts = function()
            return {
                direction = "float",
                shell = vim.o.shell,
                start_in_insert = true,
                insert_mappings = false,
                terminal_mappings = false,
                persist_mode = true,
                persist_size = true,
                close_on_exit = true,
                auto_scroll = true,
                float_opts = {
                    border = "curved",
                    width = function()
                        return math.floor(vim.o.columns * 0.85)
                    end,
                    height = function()
                        return math.floor(vim.o.lines * 0.80)
                    end,
                    title_pos = "center",
                },
            }
        end,
    },
}
