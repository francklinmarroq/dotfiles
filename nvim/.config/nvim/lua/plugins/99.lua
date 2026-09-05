return {
  "ThePrimeagen/99",
  config = function()
    local _99 = require("99")

    _99.setup({
      provider = _99.Providers.ClaudeCodeProvider,
      model = "claude-sonnet-4-5",
    })

    vim.keymap.set("v", "<leader>9v", function()
      _99.visual()
    end, { desc = "99: Fill/replace visual selection with AI" })

    vim.keymap.set("n", "<leader>9x", function()
      _99.stop_all_requests()
    end, { desc = "99: Stop all requests" })

    vim.keymap.set("n", "<leader>9s", function()
      _99.search()
    end, { desc = "99: Search project" })
  end,
}
