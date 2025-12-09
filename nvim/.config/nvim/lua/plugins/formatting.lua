-- ============================================================================
-- formatting.lua - Configuración de Formateo y Linting
-- Usando conform.nvim para formateo y nvim-lint para linting
-- Optimizado para Vue 3, Nuxt 3, TypeScript, y desarrollo web moderno
-- ============================================================================

return {
    -- ============================================================================
    -- conform.nvim - Formateo de código
    -- ============================================================================
    {
        "stevearc/conform.nvim",
        event = { "BufWritePre" },
        cmd = { "ConformInfo" },
        dependencies = { "mason.nvim" },
        opts = {
            -- ====================================================================
            -- Formateadores por tipo de archivo
            -- ====================================================================
            formatters_by_ft = {
                -- JavaScript/TypeScript
                javascript = { "prettier" },
                javascriptreact = { "prettier" },
                typescript = { "prettier" },
                typescriptreact = { "prettier" },

                -- Vue (prioridad máxima para Nuxt 3)
                vue = { "prettier" },

                -- HTML/CSS
                html = { "prettier" },
                css = { "prettier" },
                scss = { "prettier" },
                less = { "prettier" },

                -- Datos y configuración
                json = { "prettier" },
                jsonc = { "prettier" },
                yaml = { "prettier" },
                toml = { "taplo" },

                -- Markdown
                markdown = { "prettier" },
                ["markdown.mdx"] = { "prettier" },

                -- Lua (para configuración de Neovim)
                lua = { "stylua" },

                -- GraphQL (común en proyectos Nuxt)
                graphql = { "prettier" },

                -- Prisma (ORM popular con Nuxt)
                prisma = { "prisma-fmt" },

                -- Shell
                sh = { "shfmt" },
                bash = { "shfmt" },
                zsh = { "shfmt" },

                -- SQL
                sql = { "sql_formatter" },

                -- Fallback: usar LSP formatter
                ["_"] = { "trim_whitespace", "trim_newlines" },
            },

            -- ====================================================================
            -- Configuración de formateadores específicos
            -- ====================================================================
            formatters = {
                prettier = {
                    -- Usar prettier del proyecto si existe, sino el global
                    command = function()
                        local util = require("conform.util")
                        local local_prettier = util.root_file({
                            "node_modules/.bin/prettier",
                        })(nil, vim.api.nvim_buf_get_name(0))
                        if local_prettier then
                            return local_prettier .. "/node_modules/.bin/prettier"
                        end
                        return "prettier"
                    end,
                    -- Opciones adicionales para Vue/Nuxt
                    args = function(self, ctx)
                        local args = { "--stdin-filepath", "$FILENAME" }
                        -- Detectar configuración de prettier en el proyecto
                        local has_config = vim.fn.filereadable(vim.fn.getcwd() .. "/.prettierrc") == 1
                            or vim.fn.filereadable(vim.fn.getcwd() .. "/.prettierrc.json") == 1
                            or vim.fn.filereadable(vim.fn.getcwd() .. "/.prettierrc.js") == 1
                            or vim.fn.filereadable(vim.fn.getcwd() .. "/prettier.config.js") == 1

                        if not has_config then
                            -- Configuración por defecto para Vue/Nuxt si no hay config
                            table.insert(args, "--single-quote")
                            table.insert(args, "--trailing-comma")
                            table.insert(args, "es5")
                            table.insert(args, "--tab-width")
                            table.insert(args, "2")
                            table.insert(args, "--semi")
                            table.insert(args, "false")
                        end
                        return args
                    end,
                },

                stylua = {
                    prepend_args = {
                        "--indent-type", "Spaces",
                        "--indent-width", "2",
                        "--quote-style", "AutoPreferDouble",
                    },
                },

                shfmt = {
                    prepend_args = { "-i", "2", "-ci" },
                },
            },

            -- ====================================================================
            -- Formateo automático al guardar
            -- ====================================================================
            format_on_save = function(bufnr)
                -- Desactivar para ciertos filetypes
                local ignore_filetypes = { "sql", "java" }
                if vim.tbl_contains(ignore_filetypes, vim.bo[bufnr].filetype) then
                    return
                end

                -- Desactivar si hay una variable global
                if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
                    return
                end

                return {
                    timeout_ms = 3000,
                    lsp_fallback = true,
                }
            end,

            -- Formateo manual (sin límite de tiempo)
            format_after_save = {
                lsp_fallback = true,
            },
        },

        -- ====================================================================
        -- Comandos y keymaps
        -- ====================================================================
        init = function()
            -- Crear comando para toggle de autoformato
            vim.api.nvim_create_user_command("FormatToggle", function(args)
                if args.bang then
                    -- FormatToggle! -- Toggle buffer-local
                    vim.b.disable_autoformat = not vim.b.disable_autoformat
                    local status = vim.b.disable_autoformat and "desactivado" or "activado"
                    vim.notify("Autoformato (buffer): " .. status, vim.log.levels.INFO)
                else
                    -- FormatToggle -- Toggle global
                    vim.g.disable_autoformat = not vim.g.disable_autoformat
                    local status = vim.g.disable_autoformat and "desactivado" or "activado"
                    vim.notify("Autoformato (global): " .. status, vim.log.levels.INFO)
                end
            end, {
                desc = "Toggle autoformato (! para buffer-local)",
                bang = true,
            })
        end,

        keys = {
            {
                "<leader>gf",
                function()
                    require("conform").format({ async = true, lsp_fallback = true })
                end,
                mode = { "n", "v" },
                desc = "Formatear documento/selección",
            },
            {
                "<leader>tf",
                "<cmd>FormatToggle<cr>",
                desc = "Toggle autoformato (global)",
            },
            {
                "<leader>tF",
                "<cmd>FormatToggle!<cr>",
                desc = "Toggle autoformato (buffer)",
            },
        },
    },

    -- ============================================================================
    -- nvim-lint - Linting asíncrono
    -- ============================================================================
    {
        "mfussenegger/nvim-lint",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            -- Eventos que disparan el linting
            events = { "BufWritePost", "BufReadPost", "InsertLeave" },

            -- Linters por tipo de archivo
            linters_by_ft = {
                -- JavaScript/TypeScript
                javascript = { "eslint_d" },
                javascriptreact = { "eslint_d" },
                typescript = { "eslint_d" },
                typescriptreact = { "eslint_d" },

                -- Vue (prioridad máxima)
                vue = { "eslint_d" },

                -- JSON
                json = { "jsonlint" },
                jsonc = { "jsonlint" },

                -- YAML
                yaml = { "yamllint" },

                -- Markdown
                markdown = { "markdownlint" },

                -- Shell
                sh = { "shellcheck" },
                bash = { "shellcheck" },

                -- Dockerfile
                dockerfile = { "hadolint" },

                -- GitHub Actions
                ["yaml.github"] = { "actionlint" },
            },

            -- Configuración de linters específicos
            linters = {
                eslint_d = {
                    -- Usar eslint del proyecto si existe
                    cmd = function()
                        local local_eslint = vim.fn.getcwd() .. "/node_modules/.bin/eslint"
                        if vim.fn.executable(local_eslint) == 1 then
                            return local_eslint
                        end
                        return "eslint_d"
                    end,
                    -- Solo ejecutar si hay configuración de ESLint
                    condition = function(ctx)
                        return vim.fs.find({
                            ".eslintrc",
                            ".eslintrc.js",
                            ".eslintrc.cjs",
                            ".eslintrc.json",
                            ".eslintrc.yaml",
                            ".eslintrc.yml",
                            "eslint.config.js",
                            "eslint.config.mjs",
                        }, { path = ctx.filename, upward = true })[1]
                    end,
                },

                markdownlint = {
                    args = {
                        "--disable", "MD013", -- Deshabilitar límite de línea
                        "--disable", "MD033", -- Permitir HTML inline
                    },
                },
            },
        },

        config = function(_, opts)
            local lint = require("lint")

            -- Configurar linters por filetype
            lint.linters_by_ft = opts.linters_by_ft

            -- Aplicar configuración de linters específicos
            for linter, config in pairs(opts.linters or {}) do
                if lint.linters[linter] then
                    lint.linters[linter] = vim.tbl_deep_extend("force", lint.linters[linter], config)
                end
            end

            -- Función para ejecutar linting
            local function do_lint()
                -- No ejecutar en buffers especiales
                local buftype = vim.bo.buftype
                if buftype == "nofile" or buftype == "prompt" or buftype == "help" then
                    return
                end

                lint.try_lint()
            end

            -- Crear autocommands para linting
            vim.api.nvim_create_autocmd(opts.events, {
                group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
                callback = function()
                    -- Debounce: esperar un poco antes de hacer lint
                    vim.defer_fn(do_lint, 100)
                end,
            })

            -- Comando para ejecutar lint manualmente
            vim.api.nvim_create_user_command("Lint", function()
                do_lint()
                vim.notify("Linting ejecutado", vim.log.levels.INFO)
            end, { desc = "Ejecutar linting" })
        end,

        keys = {
            {
                "<leader>cl",
                function()
                    require("lint").try_lint()
                end,
                desc = "Ejecutar linting",
            },
        },
    },

}
