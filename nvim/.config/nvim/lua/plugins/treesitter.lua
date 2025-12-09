-- ============================================================================
-- treesitter.lua - Configuración de Treesitter
-- Resaltado de sintaxis y análisis de código para Vue 3, Nuxt 3, y TypeScript
-- ============================================================================

return {
    -- ============================================================================
    -- nvim-treesitter - Parser y resaltado de sintaxis avanzado
    -- ============================================================================
    {
        "nvim-treesitter/nvim-treesitter",
        version = false,
        build = ":TSUpdate",
        event = { "BufReadPost", "BufNewFile", "BufWritePre", "VeryLazy" },
        dependencies = {
            -- Selección incremental y textobjects
            "nvim-treesitter/nvim-treesitter-textobjects",
            -- Contexto de código (muestra la función/clase actual en la parte superior)
            "nvim-treesitter/nvim-treesitter-context",
            -- Autotag para Vue/HTML
            "windwp/nvim-ts-autotag",
        },
        opts = {
            -- ====================================================================
            -- Parsers a instalar automáticamente
            -- Priorizando lenguajes para Vue 3, Nuxt 3, y desarrollo web moderno
            -- ====================================================================
            ensure_installed = {
                -- Vue y frameworks
                "vue",
                -- JavaScript/TypeScript
                "javascript",
                "typescript",
                "tsx",
                "jsdoc",
                -- HTML/CSS
                "html",
                "css",
                "scss",
                -- Datos y configuración
                "json",
                "json5",
                "jsonc",
                "yaml",
                "toml",
                -- Markdown y documentación
                "markdown",
                "markdown_inline",
                -- Lua (para configuración de Neovim)
                "lua",
                "luadoc",
                "luap",
                -- Git
                "git_config",
                "gitcommit",
                "gitignore",
                "diff",
                -- Otros útiles
                "bash",
                "regex",
                "query",
                "vim",
                "vimdoc",
                "dockerfile",
                "graphql",
                "prisma",
                "sql",
            },

            -- ====================================================================
            -- Configuración de módulos de Treesitter
            -- ====================================================================

            -- Resaltado de sintaxis
            highlight = {
                enable = true,
                -- Deshabilitar para archivos muy grandes (mejora rendimiento)
                disable = function(lang, buf)
                    local max_filesize = 100 * 1024 -- 100 KB
                    local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                    if ok and stats and stats.size > max_filesize then
                        return true
                    end
                end,
                -- Usar resaltado adicional de Vim para mejor compatibilidad
                additional_vim_regex_highlighting = { "vue" },
            },

            -- Indentación inteligente basada en el AST
            indent = {
                enable = true,
                -- Vue puede tener problemas de indentación, usar con cuidado
                disable = {},
            },

            -- Selección incremental
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "<C-space>", -- Iniciar selección
                    node_incremental = "<C-space>", -- Expandir al siguiente nodo
                    scope_incremental = false, -- Expandir al scope
                    node_decremental = "<bs>", -- Reducir selección
                },
            },

            -- ====================================================================
            -- Text Objects - Navegación semántica de código
            -- ====================================================================
            textobjects = {
                -- Selección de objetos de texto
                select = {
                    enable = true,
                    lookahead = true, -- Saltar automáticamente al siguiente objeto
                    keymaps = {
                        -- Funciones
                        ["af"] = { query = "@function.outer", desc = "Seleccionar función completa" },
                        ["if"] = { query = "@function.inner", desc = "Seleccionar interior de función" },
                        -- Clases
                        ["ac"] = { query = "@class.outer", desc = "Seleccionar clase completa" },
                        ["ic"] = { query = "@class.inner", desc = "Seleccionar interior de clase" },
                        -- Parámetros/argumentos
                        ["aa"] = { query = "@parameter.outer", desc = "Seleccionar parámetro completo" },
                        ["ia"] = { query = "@parameter.inner", desc = "Seleccionar interior de parámetro" },
                        -- Condicionales
                        ["ai"] = { query = "@conditional.outer", desc = "Seleccionar condicional completo" },
                        ["ii"] = { query = "@conditional.inner", desc = "Seleccionar interior de condicional" },
                        -- Loops
                        ["al"] = { query = "@loop.outer", desc = "Seleccionar loop completo" },
                        ["il"] = { query = "@loop.inner", desc = "Seleccionar interior de loop" },
                        -- Comentarios
                        ["a/"] = { query = "@comment.outer", desc = "Seleccionar comentario" },
                    },
                },

                -- Movimiento entre objetos de texto
                move = {
                    enable = true,
                    set_jumps = true, -- Agregar al jumplist
                    goto_next_start = {
                        ["]f"] = { query = "@function.outer", desc = "Siguiente función (inicio)" },
                        ["]c"] = { query = "@class.outer", desc = "Siguiente clase (inicio)" },
                        ["]a"] = { query = "@parameter.inner", desc = "Siguiente parámetro" },
                    },
                    goto_next_end = {
                        ["]F"] = { query = "@function.outer", desc = "Siguiente función (fin)" },
                        ["]C"] = { query = "@class.outer", desc = "Siguiente clase (fin)" },
                    },
                    goto_previous_start = {
                        ["[f"] = { query = "@function.outer", desc = "Función anterior (inicio)" },
                        ["[c"] = { query = "@class.outer", desc = "Clase anterior (inicio)" },
                        ["[a"] = { query = "@parameter.inner", desc = "Parámetro anterior" },
                    },
                    goto_previous_end = {
                        ["[F"] = { query = "@function.outer", desc = "Función anterior (fin)" },
                        ["[C"] = { query = "@class.outer", desc = "Clase anterior (fin)" },
                    },
                },

                -- Intercambiar elementos
                swap = {
                    enable = true,
                    swap_next = {
                        ["<leader>sa"] = { query = "@parameter.inner", desc = "Intercambiar con siguiente parámetro" },
                    },
                    swap_previous = {
                        ["<leader>sA"] = { query = "@parameter.inner", desc = "Intercambiar con parámetro anterior" },
                    },
                },

                -- LSP interoperabilidad
                lsp_interop = {
                    enable = true,
                    border = "rounded",
                    floating_preview_opts = {},
                    peek_definition_code = {
                        ["<leader>pf"] = { query = "@function.outer", desc = "Peek definición de función" },
                        ["<leader>pc"] = { query = "@class.outer", desc = "Peek definición de clase" },
                    },
                },
            },
        },
        main = "nvim-treesitter.configs",
    },

    -- ============================================================================
    -- nvim-treesitter-context - Mostrar contexto de código
    -- Muestra la función/clase actual en la parte superior de la pantalla
    -- ============================================================================
    {
        "nvim-treesitter/nvim-treesitter-context",
        event = { "BufReadPost", "BufNewFile" },
        opts = {
            enable = true,
            max_lines = 3,    -- Máximo líneas de contexto
            min_window_height = 20, -- Altura mínima para mostrar contexto
            line_numbers = true,
            multiline_threshold = 20,
            trim_scope = "outer",
            mode = "cursor", -- Mostrar contexto basado en posición del cursor
            separator = nil,
            zindex = 20,
        },
        keys = {
            {
                "<leader>tc",
                function()
                    require("treesitter-context").toggle()
                end,
                desc = "Toggle Treesitter Context",
            },
        },
    },

    -- ============================================================================
    -- nvim-ts-autotag - Auto cerrar y renombrar tags HTML/Vue
    -- ============================================================================
    {
        "windwp/nvim-ts-autotag",
        event = { "BufReadPost", "BufNewFile" },
        opts = {
            opts = {
                enable_close = true,  -- Auto cerrar tags
                enable_rename = true, -- Auto renombrar tag de cierre
                enable_close_on_slash = true, -- Auto cerrar en />
            },
            -- Configuración específica por filetype
            per_filetype = {
                ["vue"] = {
                    enable_close = true,
                },
                ["html"] = {
                    enable_close = true,
                },
            },
        },
    },
}
