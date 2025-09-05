local map = vim.keymap.set
local builtin = require("telescope.builtin")
map("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
map("n", "<leader>fg", builtin.live_grep, { desc = "Live Grep" })

vim.keymap.set("n", "<C-n>", ":Neotree filesystem reveal left<CR>")
