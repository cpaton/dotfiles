-- f - fuzzy find files
local telescope_bi = require('telescope.builtin')

vim.keymap.set("n", "<leader>ff", telescope_bi.find_files, { desc = "Find Files" })
vim.keymap.set("n", "<leader>faf", function()
    telescope_bi.find_files({
        find_command = {
            "rg", "--files",
            "--hidden",
            "--no-ignore", "--no-ignore-parent",
            "--glob", "!.git/*",
        },
    })
end, { desc = "Find Files (hidden)" })
vim.keymap.set("n", "<leader>fp", telescope_bi.git_files, { desc = "Find Files in current project" })
vim.keymap.set("n", "<leader>fw", telescope_bi.grep_string, { desc = "Find using current word under cursor" })
vim.keymap.set("n", "<leader>fg", telescope_bi.live_grep, { desc = "Find with grep" })
vim.keymap.set("n", "<leader>fag", function()
    telescope_bi.live_grep({
        additional_args = function()
            return { "--hidden", "--no-ignore", "--no-ignore-parent", "--glob=!.git/" }
        end
    })
end, { desc = "Find with grep including hidden and ignored files" })
vim.keymap.set("n", "<leader>fh", telescope_bi.help_tags, { desc = "Find help tags" })
vim.keymap.set("n", "<leader>fb", telescope_bi.buffers, { desc = "List open buffers" })
vim.keymap.set("n", "<leader>fc", telescope_bi.commands, { desc = "Find vim commands" })
vim.keymap.set("n", "<leader>fs",
    function()
        telescope_bi.grep_string({ search = vim.fn.input("Grep > ") });
    end,
    { desc = "Find with grep and allow second filtering" }
)
