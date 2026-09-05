-- Full-repo diff viewing (diffview.nvim) + PR review inside nvim (octo.nvim)

-- Resolve the remote's default branch, e.g. "origin/main" / "origin/master".
-- Falls back to origin/main if the symbolic ref isn't set locally.
local function default_branch()
  local ref = vim.fn.systemlist("git symbolic-ref --quiet --short refs/remotes/origin/HEAD")[1]
  if vim.v.shell_error ~= 0 or not ref or ref == "" then
    ref = "origin/main"
  end
  return ref
end

return {
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose", "DiffviewToggleFiles" },
    keys = {
      { "<leader>gd", "", desc = "+diffview" },
      { "<leader>gdd", "<cmd>DiffviewOpen<cr>", desc = "Diff working tree vs HEAD" },
      { "<leader>gdc", "<cmd>DiffviewClose<cr>", desc = "Close diffview" },
      { "<leader>gdf", "<cmd>DiffviewFileHistory %<cr>", desc = "File history (current file)" },
      { "<leader>gdF", "<cmd>DiffviewFileHistory<cr>", desc = "File history (repo)" },
      {
        "<leader>gdl",
        "<cmd>DiffviewOpen HEAD~1<cr>",
        desc = "Diff vs previous commit (HEAD~1)",
      },
      {
        "<leader>gdm",
        function()
          -- PR-style diff: everything this branch adds since it forked off the
          -- remote default branch (three-dot = merge base).
          vim.cmd("DiffviewOpen " .. default_branch() .. "...HEAD")
        end,
        desc = "Diff vs remote default branch (PR view)",
      },
      {
        "<leader>gdM",
        function()
          vim.fn.system("git fetch origin")
          vim.cmd("DiffviewOpen " .. default_branch() .. "...HEAD")
        end,
        desc = "Fetch, then diff vs remote default branch",
      },
      {
        "<leader>gdu",
        function()
          -- What the remote has that you don't, on the current branch.
          vim.fn.system("git fetch origin")
          vim.cmd("DiffviewOpen HEAD..@{upstream}")
        end,
        desc = "Diff vs upstream (incoming changes)",
      },
    },
    opts = {
      enhanced_diff_hl = true,
      view = {
        merge_tool = { layout = "diff3_mixed" },
      },
    },
  },

  {
    "pwntester/octo.nvim",
    -- The LazyVim extra defaults to telescope; this config uses snacks.picker.
    opts = { picker = "snacks" },
  },
}
