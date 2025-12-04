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

			-- Configure each LSP server using the new vim.lsp.config API
			vim.lsp.config.lua_ls = {
				cmd = { "lua-language-server" },
				filetypes = { "lua" },
				root_markers = {
					".luarc.json",
					".luarc.jsonc",
					".luacheckrc",
					".stylua.toml",
					"stylua.toml",
					"selene.toml",
					"selene.yml",
					".git",
				},
				capabilities = capabilities,
			}

			vim.lsp.config.ts_ls = {
				cmd = { "typescript-language-server", "--stdio" },
				filetypes = {
					"javascript",
					"javascriptreact",
					"javascript.jsx",
					"typescript",
					"typescriptreact",
					"typescript.tsx",
					"vue",
				},
				root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
				capabilities = capabilities,
			}

			vim.lsp.config.html = {
				cmd = { "vscode-html-language-server", "--stdio" },
				filetypes = { "html" },
				root_markers = { "package.json", ".git" },
				capabilities = capabilities,
			}

			vim.lsp.config.volar = {
				cmd = { "vue-language-server", "--stdio" },
				filetypes = { "vue" },
				root_markers = { "package.json", "vue.config.js", "vite.config.js", "nuxt.config.ts", ".git" },
				capabilities = capabilities,
				init_options = {
					typescript = {
						tsdk = vim.fn.getcwd() .. "/node_modules/typescript/lib",
					},
					languageFeatures = {
						implementation = true,
						references = true,
						definition = true,
						typeDefinition = true,
						callHierarchy = true,
						hover = true,
						rename = true,
						renameFileRefactoring = true,
						signatureHelp = true,
						codeAction = true,
						workspaceSymbol = true,
						completion = {
							defaultTagNameCase = "both",
							defaultAttrNameCase = "kebabCase",
							getDocumentNameCasesRequest = false,
							getDocumentSelectionRequest = false,
						},
					},
				},
				on_attach = function(client, bufnr)
					-- Tu función on_attach aquí si tienes una
				end,
			}

			-- Enable LSP servers
			vim.lsp.enable("lua_ls")
			vim.lsp.enable("ts_ls")
			vim.lsp.enable("html")
			vim.lsp.enable("volar")

			vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
			vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, {})
			vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, {})
			vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {})
		end,
	},
}
