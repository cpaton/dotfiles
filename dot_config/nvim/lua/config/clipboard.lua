-- to improve startup times run this after NVim has started
vim.api.nvim_create_autocmd('UIEnter', {
    callback = function()
      vim.opt.clipboard = 'unnamedplus' -- always use the system clipboard instead of nvim registers
    end,
  }
)
-- vim.g.clipboard = 'osc52'   

-- Show visual highlight when yanking (copying) text.
vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    callback = function()
      vim.hl.on_yank({
        timeout = 300
      })
    end,
  }
)