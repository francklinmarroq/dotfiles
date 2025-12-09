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
                    -- Habilitar para archivos Vue
                    filetypes = { "vue", "typescript", "javascript" },
                    -- Configuración de Volar para máximo rendimiento
                    init_options = {
                        vue = {
                            -- Soporte completo para todas las secciones de Vue SFC
                            hybridMode = false,
                        },
                        typescript = {
                            tsdk = vim.fn.getcwd() .. "/node_modules/typescript/lib",
                        },
                    },
                    settings = {
                        volar = {
                            codeLens = {
                                references = true,
                                pugTools = true,
                                scriptSetupTools = true,
                            },
                        },
                        vue = {
                            -- Completado y diagnóstico en <template>
                            template = {
                                interpolationMode = true,
                            },
                            -- Soporte para script setup (Vue 3)
                            script = {
                                setup = true,
                            },
                            -- Validación de estilos
                            style = {
                                defaultLanguage = "css",
                            },
                        },
                    },
                },

                -- ====================================================================
                -- TypeScript Language Server
                -- ====================================================================
                ts_ls = {
                    -- Deshabilitar para archivos Vue (Volar se encarga)
                    filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact" },
                    -- Excluir archivos Vue para evitar conflictos
                    root_dir = function(fname)
                        -- No iniciar en proyectos que tengan archivos Vue
                        local util = require("lspconfig.util")
                        return util.root_pattern("tsconfig.json", "jsconfig.json", "package.json")(fname)
                    end,
                    settings = {
                        typescript = {
                            inlayHints = {
                                includeInlayParameterNameHints = "all",
                                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                                includeInlayFunctionParameterTypeHints = true,
                                includeInlayVariableTypeHints = true,
                                includeInlayPropertyDeclarationTypeHints = true,
                                includeInlayFunctionLikeReturnTypeHints = true,
                                includeInlayEnumMemberValueHints = true,
                            },
                        },
                        javascript = {
                            inlayHints = {
                                includeInlayParameterNameHints = "all",
                                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                                includeInlayFunctionParameterTypeHints = true,
                                includeInlayVariableTypeHints = true,
                                includeInlayPropertyDeclarationTypeHints = true,
                                includeInlayFunctionLikeReturnTypeHints = true,
                                includeInlayEnumMemberValueHints = true,
                            },
                        },
                    },
                },

                -- ====================================================================
                -- CSS Language Server - Para <style> en componentes Vue
                -- ====================================================================
                cssls = {
                    filetypes = { "css", "scss", "less", "vue" },
                    settings = {
                        css = {
                            validate = true,
                            lint = {
                                unknownAtRules = "ignore", -- Ignora @apply de TailwindCSS
                            },
                        },
                        scss = {
                            validate = true,
                        },
                        less = {
                            validate = true,
                        },
                    },
                },

                -- ====================================================================
                -- TailwindCSS Language Server - Soporte para Tailwind
                -- ====================================================================
                tailwindcss = {
                    filetypes = { "html", "css", "scss", "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
                    settings = {
                        tailwindCSS = {
                            experimental = {
                                classRegex = {
                                    -- Soporte para class bindings en Vue
                                    { ":class=\"([^\"]*)", "([^\"\\s]+)" },
                                    { "class=\"([^\"]*)",  "([^\"\\s]+)" },
                                },
                            },
                            validate = true,
                            lint = {
                                cssConflict = "warning",
                                invalidApply = "error",
                                invalidScreen = "error",
                                invalidVariant = "error",
                                invalidConfigPath = "error",
                                invalidTailwindDirective = "error",
                                recommendedVariantOrder = "warning",
                            },
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
                        format = { enable = true },
                        lint = { enable = true },
                    },
                },

                -- ====================================================================
                -- HTML Language Server
                -- ====================================================================
                html = {
                    filetypes = { "html" },
                    init_options = {
                        provideFormatter = true,
                    },
                },

                -- ====================================================================
                -- JSON Language Server
                -- ====================================================================
                jsonls = {
                    on_new_config = function(new_config)
                        new_config.settings.json.schemas = new_config.settings.json.schemas or {}
                        vim.list_extend(new_config.settings.json.schemas, require("schemastore").json.schemas())
                    end,
                    settings = {
                        json = {
                            format = { enable = true },
                            validate = { enable = true },
                        },
                    },
                },

                -- ====================================================================
                -- Emmet Language Server - Expansión HTML/CSS rápida
                -- ====================================================================
                emmet_ls = {
                    filetypes = { "html", "css", "scss", "vue", "javascriptreact", "typescriptreact" },
                },
            },

            -- ====================================================================
            -- Configuración de diagnósticos
            -- ====================================================================
            diagnostics = {
                underline = true,
                update_in_insert = false, -- No actualizar en modo insert (mejor rendimiento)
                virtual_text = {
                    spacing = 4,
                    source = "if_many",
                    prefix = "●",
                },
                severity_sort = true,
                float = {
                    border = "rounded",
                    source = "always",
                    header = "",
                    prefix = "",
                },
            },

            -- Formateo automático al guardar
            format = {
                timeout_ms = 3000,
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
<<<<<<< HEAD
=======

    -- ============================================================================
    -- Mason - Instalación automática de servidores LSP
    -- ============================================================================
    {
        "mason-org/mason.nvim",
        opts = {
            ensure_installed = {
                -- Vue/Nuxt
                "vue-language-server",
                -- TypeScript/JavaScript
                "typescript-language-server",
                -- Linting/Formatting
                "eslint-lsp",
                "prettier",
                "eslint_d",
                -- CSS
                "css-lsp",
                "tailwindcss-language-server",
                -- HTML
                "html-lsp",
                "emmet-ls",
                -- JSON
                "json-lsp",
                -- Formateadores adicionales
                "stylua",
                "shfmt",
                -- Linters adicionales
                "jsonlint",
                "markdownlint",
                "shellcheck",
            },
        },
    },

    -- ============================================================================
    -- Configuración específica para TypeScript/Vue con LazyVim
    -- ============================================================================
    {
        "pmizio/typescript-tools.nvim",
        enabled = false, -- Deshabilitado porque usamos Volar para Vue
    },
>>>>>>> main
}
