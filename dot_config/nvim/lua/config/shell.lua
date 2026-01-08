-- Settings which impact the host shell
vim.opt.title = true -- Enable window title setting
-- Set title to "nvim - [Directory Name]"
-- %{...} evaluates a vim expression
-- fnamemodify(getcwd(), ':t') gets the 'tail' (last component) of the current working directory
vim.opt.titlestring = "nvim - %{fnamemodify(getcwd(), ':t')}"
