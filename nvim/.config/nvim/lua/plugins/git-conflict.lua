-- Merge-conflict resolution: in-buffer marker hunks (git-conflict.nvim) plus the
-- 3-way merge tool for the whole conflicted repo (diffview.nvim, see git-diff.lua).

return {
  {
    "akinsho/git-conflict.nvim",
    version = "*",
    -- Conflicts have to be detected as files are opened, not on first keypress.
    event = "BufReadPre",
    opts = {
      -- Own the mappings below instead of the plugin's bare co/ct/cb/c0.
      default_mappings = false,
      default_commands = true,
      -- Handled in config() instead: the plugin's implementation still calls
      -- vim.diagnostic.disable(), which nvim 0.12 removed.
      disable_diagnostics = false,
      list_opener = "copen",
      highlights = {
        current = "DiffText",
        incoming = "DiffAdd",
        ancestor = "DiffChange",
      },
    },
    keys = {
      { "<leader>gx", "", desc = "+conflict" },
      { "<leader>gxo", "<cmd>GitConflictChooseOurs<cr>", desc = "Choose ours (current)" },
      { "<leader>gxt", "<cmd>GitConflictChooseTheirs<cr>", desc = "Choose theirs (incoming)" },
      { "<leader>gxb", "<cmd>GitConflictChooseBoth<cr>", desc = "Choose both" },
      { "<leader>gxn", "<cmd>GitConflictChooseNone<cr>", desc = "Choose none" },
      { "<leader>gxl", "<cmd>GitConflictListQf<cr>", desc = "List conflicts (quickfix)" },
      { "<leader>gxr", "<cmd>GitConflictRefresh<cr>", desc = "Refresh conflict markers" },
      { "]x", "<cmd>GitConflictNextConflict<cr>", desc = "Next conflict" },
      { "[x", "<cmd>GitConflictPrevConflict<cr>", desc = "Previous conflict" },
      { "<leader>gxd", "<cmd>DiffviewOpen<cr>", desc = "Resolve in merge tool (diffview)" },
    },
    config = function(_, opts)
      require("git-conflict").setup(opts)

      -- LSP treats a file full of <<<<<<< markers as one big syntax error, so
      -- mute diagnostics for as long as the buffer has conflicts in it.
      local function diagnostics(enabled, buf)
        if vim.api.nvim_buf_is_valid(buf) then
          vim.diagnostic.enable(enabled, { bufnr = buf })
        end
      end

      vim.api.nvim_create_autocmd("User", {
        pattern = "GitConflictDetected",
        callback = function(args)
          diagnostics(false, args.buf)
          vim.notify(
            ("Conflicts in %s — ]x/[x to move, <leader>gx to resolve"):format(
              vim.fn.fnamemodify(vim.api.nvim_buf_get_name(args.buf), ":t")
            ),
            vim.log.levels.WARN,
            { title = "git-conflict" }
          )
        end,
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "GitConflictResolved",
        callback = function(args)
          diagnostics(true, args.buf)
          vim.notify("All conflicts resolved in this buffer", vim.log.levels.INFO, { title = "git-conflict" })
        end,
      })
    end,
  },
}
