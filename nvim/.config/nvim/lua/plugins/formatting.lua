-- ============================================================================
-- formatting.lua - Configuración de Formateo y Linting
-- Prioriza ESLint cuando existe configuración en el proyecto
-- Optimizado para Vue 3, Nuxt 3, TypeScript, y desarrollo web moderno
-- ============================================================================

-- Función para detectar si existe configuración de ESLint en el proyecto
local function has_eslint_config(bufnr)
    local root_files = {
        ".eslintrc",
        ".eslintrc.js",
        ".eslintrc.cjs",
        ".eslintrc.mjs",
        ".eslintrc.json",
        ".eslintrc.yaml",
        ".eslintrc.yml",
        "eslint.config.js",
        "eslint.config.mjs",
        "eslint.config.cjs",
        "eslint.config.ts",
    }

    local buf_path = bufnr and vim.api.nvim_buf_get_name(bufnr) or vim.fn.expand("%:p")
    local found = vim.fs.find(root_files, {
        path = vim.fn.fnamemodify(buf_path, ":h"),
        upward = true,
        stop = vim.env.HOME,
    })

    return #found > 0
end

-- Función para detectar si existe configuración de Prettier
local function has_prettier_config()
    local root_files = {
        ".prettierrc",
        ".prettierrc.js",
        ".prettierrc.cjs",
        ".prettierrc.mjs",
        ".prettierrc.json",
        ".prettierrc.yaml",
        ".prettierrc.yml",
        ".prettierrc.toml",
        "prettier.config.js",
        "prettier.config.cjs",
        "prettier.config.mjs",
    }

    local found = vim.fs.find(root_files, {
        path = vim.fn.getcwd(),
        upward = true,
        stop = vim.env.HOME,
    })

    return #found > 0
end

return {
    -- ============================================================================
    -- conform.nvim - Formateo de código
    -- ============================================================================
    {
        "stevearc/conform.nvim",
        event = { "BufWritePre" },
        cmd = { "ConformInfo" },
        opts = {
            -- ====================================================================
            -- Formateadores por tipo de archivo
            -- Usa función para decidir dinámicamente entre eslint_d y prettier
            -- ====================================================================
            formatters_by_ft = {
                -- JavaScript/TypeScript - ESLint si hay config, sino Prettier
                javascript = function(bufnr)
                    if has_eslint_config(bufnr) then
                        return { "eslint_d" }
                    end
                    return { "prettier" }
                end,
                javascriptreact = function(bufnr)
                    if has_eslint_config(bufnr) then
                        return { "eslint_d" }
                    end
                    return { "prettier" }
                end,
                typescript = function(bufnr)
                    if has_eslint_config(bufnr) then
                        return { "eslint_d" }
                    end
                    return { "prettier" }
                end,
                typescriptreact = function(bufnr)
                    if has_eslint_config(bufnr) then
                        return { "eslint_d" }
                    end
                    return { "prettier" }
                end,

                -- Vue - ESLint si hay config, sino Prettier
                vue = function(bufnr)
                    if has_eslint_config(bufnr) then
                        return { "eslint_d" }
                    end
                    return { "prettier" }
                end,

                -- HTML/CSS - Prettier
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

                -- GraphQL
                graphql = { "prettier" },

                -- Shell
                sh = { "shfmt" },
                bash = { "shfmt" },
                zsh = { "shfmt" },

                -- Fallback
                ["_"] = { "trim_whitespace", "trim_newlines" },
            },

            -- ====================================================================
            -- Configuración de formateadores específicos
            -- ====================================================================
            formatters = {
                eslint_d = {
                    -- Usar eslint_d con --fix para formatear
                    command = "eslint_d",
                    args = {
                        "--fix-to-stdout",
                        "--stdin",
                        "--stdin-filename",
                        "$FILENAME",
                    },
                    stdin = true,
                    -- Condición: solo usar si hay config de ESLint
                    condition = function(self, ctx)
                        return has_eslint_config()
                    end,
                },

                prettier = {
                    -- Usar prettier del proyecto si existe
                    command = function()
                        local local_prettier = vim.fn.getcwd() .. "/node_modules/.bin/prettier"
                        if vim.fn.executable(local_prettier) == 1 then
                            return local_prettier
                        end
                        return "prettier"
                    end,
                    args = function()
                        local args = { "--stdin-filepath", "$FILENAME" }

                        -- Si no hay config de prettier, usar defaults razonables
                        if not has_prettier_config() then
                            vim.list_extend(args, {
                                "--single-quote",
                                "--trailing-comma", "es5",
                                "--tab-width", "2",
                                "--semi", "false",
                            })
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
                    timeout_ms = 5000,
                    lsp_fallback = true,
                }
            end,
        },

        -- ====================================================================
        -- Comandos y keymaps
        -- ====================================================================
        init = function()
            -- Crear comando para toggle de autoformato
            vim.api.nvim_create_user_command("FormatToggle", function(args)
                if args.bang then
                    vim.b.disable_autoformat = not vim.b.disable_autoformat
                    local status = vim.b.disable_autoformat and "desactivado" or "activado"
                    vim.notify("Autoformato (buffer): " .. status, vim.log.levels.INFO)
                else
                    vim.g.disable_autoformat = not vim.g.disable_autoformat
                    local status = vim.g.disable_autoformat and "desactivado" or "activado"
                    vim.notify("Autoformato (global): " .. status, vim.log.levels.INFO)
                end
            end, {
                desc = "Toggle autoformato (! para buffer-local)",
                bang = true,
            })

            -- Comando para ver qué formateador se usará
            vim.api.nvim_create_user_command("FormatInfo", function()
                local bufnr = vim.api.nvim_get_current_buf()
                local ft = vim.bo[bufnr].filetype
                local has_eslint = has_eslint_config(bufnr)
                local has_prettier = has_prettier_config()

                local msg = string.format(
                    "Filetype: %s\nESLint config: %s\nPrettier config: %s\nFormateador: %s",
                    ft,
                    has_eslint and "✓ Encontrado" or "✗ No encontrado",
                    has_prettier and "✓ Encontrado" or "✗ No encontrado",
                    has_eslint and "eslint_d" or "prettier"
                )
                vim.notify(msg, vim.log.levels.INFO, { title = "Format Info" })
            end, { desc = "Mostrar info de formateo" })
        end,

        keys = {
            {
                "<leader>gf",
                function()
                    require("conform").format({
                        async = true,
                        lsp_fallback = true,
                        timeout_ms = 5000,
                    })
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
            {
                "<leader>fi",
                "<cmd>FormatInfo<cr>",
                desc = "Info de formateo",
            },
        },
    },

    -- ============================================================================
    -- nvim-lint - Linting asíncrono
    -- ============================================================================
    {
        "mfussenegger/nvim-lint",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            local lint = require("lint")

            -- Linters por tipo de archivo
            lint.linters_by_ft = {
                javascript = { "eslint_d" },
                javascriptreact = { "eslint_d" },
                typescript = { "eslint_d" },
                typescriptreact = { "eslint_d" },
                vue = { "eslint_d" },
            }

            -- Crear autocommands para linting
            vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
                group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
                callback = function()
                    -- Solo ejecutar si hay config de ESLint
                    if has_eslint_config() then
                        vim.defer_fn(function()
                            lint.try_lint()
                        end, 100)
                    end
                end,
            })
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
