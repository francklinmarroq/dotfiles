local map = vim.keymap.set

-- Telescope keymaps (loaded lazily to avoid errors if telescope isn't loaded yet)
map("n", "<leader>ff", function()
	require("telescope.builtin").find_files()
end, { desc = "Find files" })
map("n", "<leader>fg", function()
	require("telescope.builtin").live_grep()
end, { desc = "Live Grep" })

vim.keymap.set("n", "<C-n>", ":Neotree filesystem reveal left<CR>")
vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, {})
