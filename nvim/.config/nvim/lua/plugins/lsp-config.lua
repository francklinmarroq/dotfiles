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

			-- Check if @vue/typescript-plugin is installed in Vue projects
			local function check_vue_typescript_plugin()
				local cwd = vim.fn.getcwd()
				local package_json = cwd .. "/package.json"

				-- Check if package.json exists
				if vim.fn.filereadable(package_json) == 1 then
					local file = io.open(package_json, "r")
					if file then
						local content = file:read("*all")
						file:close()

						-- Check if it's a Vue project
						if content:match('"vue"') then
							local plugin_path = cwd .. "/node_modules/@vue/typescript-plugin"

							-- Check if plugin is NOT installed
							if vim.fn.isdirectory(plugin_path) == 0 then
								vim.notify(
									"Vue project detected!\n" ..
									"Install TypeScript plugin for better LSP support:\n" ..
									"npm install --save-dev @vue/typescript-plugin",
									vim.log.levels.WARN,
									{ title = "Vue LSP Setup" }
								)
							end
						end
					end
				end
			end

			-- Run check after a short delay to avoid blocking startup
			vim.defer_fn(check_vue_typescript_plugin, 1000)

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
			lspconfig.volar.setup({
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
