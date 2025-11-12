require("config.vim-options")
require("config.lazy")
require("config.keymaps")
vim.g.lazyvim_check_order = false
vim.diagnostic.enable = true
vim.diagnostic.config({
  virtual_lines = true
})
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  pattern = "*.html",
  callback = function()
    vim.bo.filetype = "html"
  end
})
