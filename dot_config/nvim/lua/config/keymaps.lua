-- see what Keys Neovim gets
-- in insert mode press Ctrl+Q to enter a literal and then press the key combination
-- see if something is mapped
-- :verbose imap <key sequence>

vim.keymap.set("n", "<leader>b", vim.cmd.Explore, { desc = "File browser" } ) -- file browser

-- Leaders
-- f - fuzzy find files
-- k - language of file stuff

-- file finding operations
local telescope_bi = require('telescope.builtin')
vim.keymap.set("n", "<leader>ff", telescope_bi.find_files, { desc = "Find Files" })
vim.keymap.set("n", "<leader>fp", telescope_bi.git_files, { desc = "Find Files in current project" })
vim.keymap.set("n", "<leader>fw", telescope_bi.grep_string, { desc = "Find using current word under cursor" })
vim.keymap.set("n", "<leader>fg", telescope_bi.live_grep, { desc = "Find with grep" })
vim.keymap.set("n", "<leader>fh", telescope_bi.help_tags, { desc = "Find help tags" })
vim.keymap.set("n", "<leader>fb", telescope_bi.buffers, { desc = "List open buffers" })
vim.keymap.set("n", "<leader>fc", telescope_bi.commands, { desc = "Find vim commands" })
vim.keymap.set("n", "<leader>fs", function()
	telescope_bi.grep_string({ search = vim.fn.input("Grep > ")});
end, { desc = "Find with grep and allow second filtering" })

-- code completion
-- vim.keymap.set('i', '<C-l>', '<C-x><C-o>', { noremap = true, desc = "Trigger completion" })
-- attempts to use spacebar are failing
-- vim.keymap.set('i', '<C-Space>', '<C-x><C-o>', { noremap = true, silent = true, desc = "Trigger completion" })
-- vim.keymap.set('i', '<Esc><Space>', '<C-x><C-o>', { noremap = true, silent = true, desc = "Trigger completion" })

-- formatting
-- format entire file
vim.keymap.set("n", "<leader>kf", 
	function()
		local clients = vim.lsp.get_clients({ bufnr = 0 })
		if #clients > 0 then
			-- LSP formatting
			vim.lsp.buf.format({ async = true })
		else
			-- Built-in reindent whole file
			vim.cmd("normal! gg=G")
		end
	end,
	{ desc = "Format file"}
)
vim.keymap.set("n", "<M-F>",  --shift+alt+f
	function()
		local clients = vim.lsp.get_clients({ bufnr = 0 })
		if #clients > 0 then
			-- LSP formatting
			vim.lsp.buf.format({ async = true })
		else
			-- Built-in reindent whole file
			vim.cmd("normal! gg=G")
		end
	end,
	{ desc = "Format file"}
)
vim.keymap.set("v", "<M-F>",  --shift+alt+f
	function()
		local clients = vim.lsp.get_clients({ bufnr = 0 })
		if #clients > 0 then
			-- LSP formatting
			vim.lsp.buf.format({ async = true })
		else
			-- Built-in reindent whole file
			vim.cmd("normal! =")
		end
	end,
	{ desc = "Format selected text"}
)