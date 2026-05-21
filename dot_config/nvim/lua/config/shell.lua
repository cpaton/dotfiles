-- Settings which impact the host shell
vim.opt.title = true -- Enable window title setting
-- Set title to "nvim - [Directory Name]"
-- %{...} evaluates a vim expression
-- fnamemodify(getcwd(), ':t') gets the 'tail' (last component) of the current working directory
vim.opt.titlestring = "nvim - %{fnamemodify(getcwd(), ':t')}"

-- See :help shell-powershell
local powershell_options = {
    shell = vim.fn.executable "pwsh" == 1 and "pwsh" or "powershell",
    shellcmdflag =
    "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;",
    shellredir = "-RedirectStandardOutput %s -NoNewWindow -Wait",
    shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode",
    shellquote = "",
    shellxquote = "",
}

for option, value in pairs(powershell_options) do
    vim.opt[option] = value
end
