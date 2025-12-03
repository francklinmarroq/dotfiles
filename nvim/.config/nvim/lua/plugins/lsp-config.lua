return {

	{
		"williamboman/mason.nvim",
		lazy = false,
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		lazy = false,
		opts = {
			auto_install = true,
		},
	},
	{
		"neovim/nvim-lspconfig",
		lazy = false,
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()
			local lspconfig = require("lspconfig")

			-- Lua Language Server
			lspconfig.lua_ls.setup({
				capabilities = capabilities,
			})

			-- TypeScript Language Server with Vue plugin
			lspconfig.ts_ls.setup({
				capabilities = capabilities,
				init_options = {
					plugins = {
						{
							name = "@vue/typescript-plugin",
							location = vim.fn.getcwd() .. "/node_modules/@vue/typescript-plugin",
							languages = { "vue" }
						}
					}
				},
				filetypes = { 'javascript', 'javascriptreact', 'javascript.jsx', 'typescript', 'typescriptreact', 'typescript.tsx', 'vue' },
			})

			-- HTML Language Server
			lspconfig.html.setup({
				capabilities = capabilities,
			})

			-- Vue Language Server in hybrid mode
			lspconfig.vue_ls.setup({
				capabilities = capabilities,
				init_options = {
					vue = {
						hybridMode = true
					}
				}
			})

			vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
			vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, {})
			vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, {})
			vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {})
		end,
	},
}
