-- CSS/SCSS/Less support: LazyVim has no lang.css extra, so wire up
-- treesitter parsers and the vscode css language server directly.
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "css", "scss" } },
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        cssls = {},
      },
    },
  },
}
