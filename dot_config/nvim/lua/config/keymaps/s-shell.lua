-- s - shell / terminal
local shell_buffer_var = "config_shell_buffer"

local function open_shell_buffer()
    local target_win = vim.api.nvim_get_current_win()

    -- Do not replace sidebars such as Neo-tree when they have focus.
    if vim.bo[vim.api.nvim_win_get_buf(target_win)].buftype ~= "" then
        target_win = nil
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            if vim.bo[vim.api.nvim_win_get_buf(win)].buftype == "" then
                target_win = win
                break
            end
        end
    end

    if not target_win then
        vim.notify("No regular buffer window is open for the shell", vim.log.levels.WARN)
        return
    end

    vim.api.nvim_set_current_win(target_win)
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(buf) and vim.b[buf][shell_buffer_var] then
            vim.cmd.buffer(buf)
            vim.cmd.startinsert()
            return
        end
    end

    vim.cmd.enew()
    vim.cmd.terminal()
    vim.b[shell_buffer_var] = true
    vim.bo.buflisted = true
end

vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]],
    { noremap = true, silent = true, desc = "Exit terminal mode" })
vim.keymap.set("n", "<leader>ss", "<cmd>ToggleTerm direction=float<CR>",
    { noremap = true, silent = true, desc = "Toggle shell float" })
vim.keymap.set("n", "<leader>sb", open_shell_buffer,
    { noremap = true, silent = true, desc = "Open shell buffer" })
vim.keymap.set("n", "<leader>sh", "<cmd>ToggleTerm direction=horizontal<CR>",
    { noremap = true, silent = true, desc = "Toggle shell horizontal" })
vim.keymap.set("n", "<leader>sv", "<cmd>ToggleTerm direction=vertical<CR>",
    { noremap = true, silent = true, desc = "Toggle shell vertical" })
vim.keymap.set("n", "<leader>st", "<cmd>ToggleTerm direction=tab<CR>",
    { noremap = true, silent = true, desc = "Toggle shell tab" })
