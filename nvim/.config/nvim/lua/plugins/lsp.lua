-- ============================================================================
-- lsp.lua - Configuración de LSP para Vue 3, Nuxt 3, y TypeScript
-- Optimizado para rendimiento y precisión en componentes Vue
-- ============================================================================

return {
    -- ============================================================================
    -- nvim-lspconfig - Configuración principal de LSP
    -- ============================================================================
    {
        "neovim/nvim-lspconfig",
        opts = {
            -- Configuración de servidores LSP
            servers = {
                -- ====================================================================
                -- Vue Language Server (Volar) - PRIORIDAD MÁXIMA para Vue 3/Nuxt 3
                -- ====================================================================
                volar = {
                    filetypes = { "vue" },
                    init_options = {
                        vue = {
                            hybridMode = true,
                        },
                    },
                },

                -- ====================================================================
                -- TypeScript Language Server
                -- ====================================================================
                ts_ls = {
                    filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact" },
                    settings = {
                        typescript = {
                            inlayHints = {
                                includeInlayParameterNameHints = "all",
                                includeInlayFunctionParameterTypeHints = true,
                                includeInlayVariableTypeHints = true,
                                includeInlayPropertyDeclarationTypeHints = true,
                                includeInlayFunctionLikeReturnTypeHints = true,
                            },
                        },
                        javascript = {
                            inlayHints = {
                                includeInlayParameterNameHints = "all",
                                includeInlayFunctionParameterTypeHints = true,
                                includeInlayVariableTypeHints = true,
                                includeInlayPropertyDeclarationTypeHints = true,
                                includeInlayFunctionLikeReturnTypeHints = true,
                            },
                        },
                    },
                },

                -- ====================================================================
                -- CSS Language Server - Para <style> en componentes Vue
                -- ====================================================================
                cssls = {
                    filetypes = { "css", "scss", "less" },
                    settings = {
                        css = {
                            validate = true,
                            lint = { unknownAtRules = "ignore" },
                        },
                        scss = { validate = true },
                        less = { validate = true },
                    },
                },

                -- ====================================================================
                -- TailwindCSS Language Server
                -- ====================================================================
                tailwindcss = {
                    filetypes = { "html", "css", "scss", "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
                    settings = {
                        tailwindCSS = {
                            experimental = {
                                classRegex = {
                                    { ":class=\"([^\"]*)", "([^\"\\s]+)" },
                                    { "class=\"([^\"]*)",  "([^\"\\s]+)" },
                                },
                            },
                            validate = true,
                        },
                    },
                },

                -- ====================================================================
                -- ESLint Language Server
                -- ====================================================================
                eslint = {
                    filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
                    settings = {
                        workingDirectory = { mode = "auto" },
                    },
                },

                -- ====================================================================
                -- HTML Language Server
                -- ====================================================================
                html = {
                    filetypes = { "html" },
                },

                -- ====================================================================
                -- JSON Language Server
                -- ====================================================================
                jsonls = {
                    on_new_config = function(new_config)
                        new_config.settings.json.schemas = new_config.settings.json.schemas or {}
                        local ok, schemastore = pcall(require, "schemastore")
                        if ok then
                            vim.list_extend(new_config.settings.json.schemas, schemastore.json.schemas())
                        end
                    end,
                    settings = {
                        json = {
                            format = { enable = true },
                            validate = { enable = true },
                        },
                    },
                },

                -- ====================================================================
                -- Emmet Language Server
                -- ====================================================================
                emmet_ls = {
                    filetypes = { "html", "css", "scss", "vue", "javascriptreact", "typescriptreact" },
                },

                -- ====================================================================
                -- Kotlin Language Server - Para desarrollo Kotlin/Spring Boot
                -- ====================================================================
                kotlin_language_server = {
                    filetypes = { "kotlin", "kts" },
                    root_dir = function(fname)
                        return vim.fs.root(fname, {
                            ".git",
                            "build.gradle",
                            "build.gradle.kts",
                            "pom.xml",
                            "settings.gradle",
                            "settings.gradle.kts",
                        })
                    end,
                    settings = {
                        kotlin = {
                            compiler = {
                                jvm = {
                                    target = "17",
                                },
                            },
                            completion = {
                                snippets = {
                                    enabled = true,
                                },
                            },
                            linting = {
                                enabled = true,
                            },
                        },
                    },
                },
            },

            -- ====================================================================
            -- Configuración de diagnósticos
            -- ====================================================================
            diagnostics = {
                underline = true,
                update_in_insert = false,
                virtual_text = {
                    spacing = 4,
                    source = "if_many",
                    prefix = "●",
                },
                severity_sort = true,
                float = {
                    border = "rounded",
                    source = "always",
                },
            },
        },
    },

    -- ============================================================================
    -- SchemaStore - Esquemas JSON para autocompletado
    -- ============================================================================
    {
        "b0o/schemastore.nvim",
        lazy = true,
    },
}
