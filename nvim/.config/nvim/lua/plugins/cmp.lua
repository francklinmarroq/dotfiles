-- ============================================================================
-- cmp.lua - Configuración de Autocompletado con nvim-cmp
-- Optimizado para Vue 3, Nuxt 3, TypeScript, y desarrollo web moderno
-- ============================================================================

return {
    -- ============================================================================
    -- nvim-cmp - Motor de autocompletado principal
    -- ============================================================================
    {
        "hrsh7th/nvim-cmp",
        version = false,
        event = "InsertEnter",
        dependencies = {
            -- Fuentes de completado
            "hrsh7th/cmp-nvim-lsp",                -- LSP
            "hrsh7th/cmp-buffer",                  -- Texto del buffer actual
            "hrsh7th/cmp-path",                    -- Rutas de archivos
            "hrsh7th/cmp-cmdline",                 -- Línea de comandos
            "hrsh7th/cmp-nvim-lsp-signature-help", -- Firma de funciones

            -- Snippets
            {
                "L3MON4D3/LuaSnip",
                version = "v2.*",
                build = "make install_jsregexp",
                dependencies = {
                    -- Colección de snippets predefinidos
                    {
                        "rafamadriz/friendly-snippets",
                        config = function()
                            require("luasnip.loaders.from_vscode").lazy_load()
                            -- Cargar snippets específicos para Vue
                            require("luasnip.loaders.from_vscode").lazy_load({
                                paths = { vim.fn.stdpath("config") .. "/snippets" }
                            })
                        end,
                    },
                },
                opts = {
                    history = true,
                    delete_check_events = "TextChanged",
                    region_check_events = "CursorMoved",
                },
            },
            "saadparwaiz1/cmp_luasnip", -- Integración LuaSnip con cmp

            -- Íconos para el menú de completado
            "onsails/lspkind.nvim",
        },
        opts = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")
            local lspkind = require("lspkind")

            -- Función para verificar si hay palabras antes del cursor
            local has_words_before = function()
                unpack = unpack or table.unpack
                local line, col = unpack(vim.api.nvim_win_get_cursor(0))
                return col ~= 0 and
                    vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
            end

            return {
                -- ====================================================================
                -- Motor de snippets
                -- ====================================================================
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },

                -- ====================================================================
                -- Comportamiento del completado
                -- ====================================================================
                completion = {
                    completeopt = "menu,menuone,noinsert",
                },

                -- ====================================================================
                -- Apariencia de la ventana de completado
                -- ====================================================================
                window = {
                    completion = cmp.config.window.bordered({
                        border = "rounded",
                        winhighlight = "Normal:CmpNormal,FloatBorder:CmpBorder,CursorLine:CmpSelection,Search:None",
                        col_offset = -3,
                        side_padding = 0,
                    }),
                    documentation = cmp.config.window.bordered({
                        border = "rounded",
                        winhighlight = "Normal:CmpDocNormal,FloatBorder:CmpDocBorder",
                        max_width = 80,
                        max_height = 20,
                    }),
                },

                -- ====================================================================
                -- Formateo de los items del menú
                -- ====================================================================
                formatting = {
                    fields = { "kind", "abbr", "menu" },
                    format = function(entry, vim_item)
                        local kind = lspkind.cmp_format({
                            mode = "symbol_text",
                            maxwidth = 50,
                            ellipsis_char = "...",
                            symbol_map = {
                                -- Símbolos personalizados para Vue/TypeScript
                                Text = "󰉿",
                                Method = "󰆧",
                                Function = "󰊕",
                                Constructor = "",
                                Field = "󰜢",
                                Variable = "󰀫",
                                Class = "󰠱",
                                Interface = "",
                                Module = "",
                                Property = "󰜢",
                                Unit = "󰑭",
                                Value = "󰎠",
                                Enum = "",
                                Keyword = "󰌋",
                                Snippet = "",
                                Color = "󰏘",
                                File = "󰈙",
                                Reference = "󰈇",
                                Folder = "󰉋",
                                EnumMember = "",
                                Constant = "󰏿",
                                Struct = "󰙅",
                                Event = "",
                                Operator = "󰆕",
                                TypeParameter = "",
                                -- Vue específicos
                                Component = "",
                            },
                        })(entry, vim_item)

                        -- Agregar nombre de la fuente
                        local source_names = {
                            nvim_lsp = "[LSP]",
                            luasnip = "[Snip]",
                            buffer = "[Buf]",
                            path = "[Path]",
                            nvim_lsp_signature_help = "[Sig]",
                        }
                        kind.menu = source_names[entry.source.name] or string.format("[%s]", entry.source.name)

                        return kind
                    end,
                },

                -- ====================================================================
                -- Keymaps para navegación y selección
                -- ====================================================================
                mapping = cmp.mapping.preset.insert({
                    -- Navegación en el menú
                    ["<C-j>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
                    ["<C-k>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
                    ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
                    ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),

                    -- Scroll en documentación
                    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"] = cmp.mapping.scroll_docs(4),
                    ["<C-u>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-d>"] = cmp.mapping.scroll_docs(4),

                    -- Mostrar/ocultar menú
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-e>"] = cmp.mapping.abort(),

                    -- Confirmar selección
                    ["<CR>"] = cmp.mapping.confirm({
                        behavior = cmp.ConfirmBehavior.Replace,
                        select = true,
                    }),

                    -- Tab para navegar y expandir snippets
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_locally_jumpable() then
                            luasnip.expand_or_jump()
                        elseif has_words_before() then
                            cmp.complete()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),

                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                }),

                -- ====================================================================
                -- Fuentes de completado (ordenadas por prioridad)
                -- ====================================================================
                sources = cmp.config.sources({
                    -- Prioridad alta: LSP y Snippets
                    {
                        name = "nvim_lsp",
                        priority = 1000,
                        -- Filtrar algunos tipos de completado innecesarios
                        entry_filter = function(entry, ctx)
                            local kind = require("cmp.types").lsp.CompletionItemKind[entry:get_kind()]
                            -- Filtrar snippets del LSP (usamos LuaSnip)
                            if kind == "Snippet" then
                                return false
                            end
                            return true
                        end,
                    },
                    { name = "nvim_lsp_signature_help", priority = 900 },
                    { name = "luasnip",                 priority = 800 },
                    { name = "path",                    priority = 700 },
                }, {
                    -- Prioridad baja: Buffer (solo si no hay resultados de arriba)
                    {
                        name = "buffer",
                        priority = 500,
                        keyword_length = 3,
                        option = {
                            -- Incluir todos los buffers visibles
                            get_bufnrs = function()
                                local bufs = {}
                                for _, win in ipairs(vim.api.nvim_list_wins()) do
                                    bufs[vim.api.nvim_win_get_buf(win)] = true
                                end
                                return vim.tbl_keys(bufs)
                            end,
                        },
                    },
                }),

                -- ====================================================================
                -- Ordenamiento de resultados
                -- ====================================================================
                sorting = {
                    priority_weight = 2,
                    comparators = {
                        cmp.config.compare.offset,
                        cmp.config.compare.exact,
                        cmp.config.compare.score,
                        cmp.config.compare.recently_used,
                        cmp.config.compare.locality,
                        cmp.config.compare.kind,
                        cmp.config.compare.sort_text,
                        cmp.config.compare.length,
                        cmp.config.compare.order,
                    },
                },

                -- ====================================================================
                -- Comportamiento experimental
                -- ====================================================================
                experimental = {
                    ghost_text = {
                        hl_group = "CmpGhostText",
                    },
                },
            }
        end,

        -- ====================================================================
        -- Configuración adicional después de setup
        -- ====================================================================
        config = function(_, opts)
            local cmp = require("cmp")
            cmp.setup(opts)

            -- Configuración para la línea de comandos (:)
            cmp.setup.cmdline(":", {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources({
                    { name = "path" },
                }, {
                    {
                        name = "cmdline",
                        option = {
                            ignore_cmds = { "Man", "!" },
                        },
                    },
                }),
            })

            -- Configuración para búsqueda (/ y ?)
            cmp.setup.cmdline({ "/", "?" }, {
                mapping = cmp.mapping.preset.cmdline(),
                sources = {
                    { name = "buffer" },
                },
            })

            -- Configuración específica para archivos Vue
            cmp.setup.filetype("vue", {
                sources = cmp.config.sources({
                    { name = "nvim_lsp",                priority = 1000 },
                    { name = "nvim_lsp_signature_help", priority = 900 },
                    { name = "luasnip",                 priority = 800 },
                    { name = "path",                    priority = 700 },
                }, {
                    { name = "buffer", keyword_length = 3 },
                }),
            })

            -- Configuración para gitcommit
            cmp.setup.filetype("gitcommit", {
                sources = cmp.config.sources({
                    { name = "buffer" },
                }),
            })

            -- Highlight groups personalizados
            vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
        end,
    },
}
