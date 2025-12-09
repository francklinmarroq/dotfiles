-- ============================================================================
-- telescope.lua - Configuración de Telescope
-- Fuzzy Finder y Grep para búsqueda rápida de archivos y texto
-- Optimizado para proyectos Vue 3, Nuxt 3, y desarrollo web moderno
-- ============================================================================

return {
    -- ============================================================================
    -- telescope.nvim - Fuzzy Finder principal
    -- ============================================================================
    {
        "nvim-telescope/telescope.nvim",
        cmd = "Telescope",
        version = false,
        dependencies = {
            -- Dependencias requeridas
            "nvim-lua/plenary.nvim",
            -- FZF nativo para mejor rendimiento
            {
                "nvim-telescope/telescope-fzf-native.nvim",
                build = "make",
                enabled = vim.fn.executable("make") == 1,
            },
            -- Íconos para los resultados
            "nvim-tree/nvim-web-devicons",
            -- UI mejorada para selección
            "nvim-telescope/telescope-ui-select.nvim",
            -- Búsqueda de archivos recientes
            "nvim-telescope/telescope-frecency.nvim",
        },
        opts = function()
            local actions = require("telescope.actions")
            local action_layout = require("telescope.actions.layout")

            return {
                -- ====================================================================
                -- Configuración por defecto
                -- ====================================================================
                defaults = {
                    -- Prompt y resultado
                    prompt_prefix = "   ",
                    selection_caret = "  ",
                    entry_prefix = "  ",
                    multi_icon = " ",

                    -- Layout
                    layout_strategy = "horizontal",
                    layout_config = {
                        horizontal = {
                            prompt_position = "top",
                            preview_width = 0.55,
                            results_width = 0.8,
                        },
                        vertical = {
                            mirror = false,
                        },
                        width = 0.87,
                        height = 0.80,
                        preview_cutoff = 120,
                    },

                    -- Ordenamiento
                    sorting_strategy = "ascending",
                    selection_strategy = "reset",

                    -- Scrolling
                    scroll_strategy = "cycle",

                    -- Bordes y estilos
                    border = true,
                    borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },

                    -- Rutas
                    path_display = { "truncate" },

                    -- Archivos a ignorar en búsquedas
                    file_ignore_patterns = {
                        -- Directorios de dependencias
                        "node_modules/",
                        "%.git/",
                        "%.nuxt/",
                        "%.output/",
                        "%.cache/",
                        "dist/",
                        "build/",
                        -- Archivos de lock
                        "package%-lock%.json",
                        "yarn%.lock",
                        "pnpm%-lock%.yaml",
                        -- Otros
                        "%.DS_Store",
                        "__pycache__/",
                        "%.pyc",
                        "%.o",
                        "%.out",
                        "%.class",
                        "%.pdf",
                        "%.zip",
                        "%.tar",
                        "%.gz",
                    },

                    -- Previewer
                    previewer = true,
                    file_previewer = require("telescope.previewers").vim_buffer_cat.new,
                    grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,

                    -- Rendimiento
                    cache_picker = {
                        num_pickers = 5,
                        limit_entries = 1000,
                    },

                    -- ====================================================================
                    -- Keymaps dentro de Telescope
                    -- ====================================================================
                    mappings = {
                        -- Modo insert
                        i = {
                            -- Navegación
                            ["<C-j>"] = actions.move_selection_next,
                            ["<C-k>"] = actions.move_selection_previous,
                            ["<C-n>"] = actions.move_selection_next,
                            ["<C-p>"] = actions.move_selection_previous,
                            ["<Down>"] = actions.move_selection_next,
                            ["<Up>"] = actions.move_selection_previous,

                            -- Historial
                            ["<C-Down>"] = actions.cycle_history_next,
                            ["<C-Up>"] = actions.cycle_history_prev,

                            -- Abrir archivos
                            ["<CR>"] = actions.select_default,
                            ["<C-x>"] = actions.select_horizontal,
                            ["<C-v>"] = actions.select_vertical,
                            ["<C-t>"] = actions.select_tab,

                            -- Preview
                            ["<C-u>"] = actions.preview_scrolling_up,
                            ["<C-d>"] = actions.preview_scrolling_down,
                            ["<C-f>"] = actions.preview_scrolling_left,
                            ["<C-b>"] = actions.preview_scrolling_right,
                            ["<M-p>"] = action_layout.toggle_preview,

                            -- Selección múltiple
                            ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
                            ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
                            ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
                            ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,

                            -- Otros
                            ["<Esc>"] = actions.close,
                            ["<C-c>"] = actions.close,
                            ["<C-l>"] = actions.complete_tag,
                            ["<C-/>"] = actions.which_key,
                        },

                        -- Modo normal
                        n = {
                            -- Navegación
                            ["j"] = actions.move_selection_next,
                            ["k"] = actions.move_selection_previous,
                            ["gg"] = actions.move_to_top,
                            ["G"] = actions.move_to_bottom,
                            ["H"] = actions.move_to_top,
                            ["M"] = actions.move_to_middle,
                            ["L"] = actions.move_to_bottom,

                            -- Abrir archivos
                            ["<CR>"] = actions.select_default,
                            ["<C-x>"] = actions.select_horizontal,
                            ["<C-v>"] = actions.select_vertical,
                            ["<C-t>"] = actions.select_tab,

                            -- Preview
                            ["<C-u>"] = actions.preview_scrolling_up,
                            ["<C-d>"] = actions.preview_scrolling_down,
                            ["<M-p>"] = action_layout.toggle_preview,

                            -- Selección múltiple
                            ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
                            ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
                            ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
                            ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,

                            -- Otros
                            ["q"] = actions.close,
                            ["<Esc>"] = actions.close,
                            ["?"] = actions.which_key,
                        },
                    },
                },

                -- ====================================================================
                -- Configuración de pickers individuales
                -- ====================================================================
                pickers = {
                    -- Find Files - Fuzzy Finder (<leader>ff)
                    find_files = {
                        hidden = true,
                        no_ignore = false,
                        find_command = { "fd", "--type", "f", "--strip-cwd-prefix" },
                        -- Mostrar archivos Vue primero para proyectos Nuxt/Vue
                        file_sorter = require("telescope.sorters").get_fuzzy_file,
                    },

                    -- Live Grep - Fuzzy Grep (<leader>fg)
                    live_grep = {
                        additional_args = function()
                            return { "--hidden", "--glob", "!.git" }
                        end,
                        -- Configuración para mejor rendimiento en proyectos grandes
                        max_results = 500,
                    },

                    -- Grep String - Buscar palabra bajo cursor
                    grep_string = {
                        additional_args = function()
                            return { "--hidden", "--glob", "!.git" }
                        end,
                    },

                    -- Buffers
                    buffers = {
                        show_all_buffers = true,
                        sort_lastused = true,
                        sort_mru = true,
                        previewer = false,
                        mappings = {
                            i = {
                                ["<C-d>"] = actions.delete_buffer,
                            },
                            n = {
                                ["dd"] = actions.delete_buffer,
                            },
                        },
                    },

                    -- Archivos recientes
                    oldfiles = {
                        only_cwd = true,
                    },

                    -- Git files
                    git_files = {
                        show_untracked = true,
                    },

                    -- LSP
                    lsp_references = {
                        show_line = true,
                        include_declaration = false,
                    },

                    lsp_definitions = {
                        show_line = true,
                    },

                    lsp_document_symbols = {
                        symbol_width = 50,
                    },

                    lsp_workspace_symbols = {
                        symbol_width = 50,
                    },
                },

                -- ====================================================================
                -- Extensiones
                -- ====================================================================
                extensions = {
                    -- FZF nativo para mejor rendimiento
                    fzf = {
                        fuzzy = true,
                        override_generic_sorter = true,
                        override_file_sorter = true,
                        case_mode = "smart_case",
                    },

                    -- UI Select (para code actions, etc.)
                    ["ui-select"] = {
                        require("telescope.themes").get_dropdown({
                            previewer = false,
                            borderchars = {
                                prompt = { "─", "│", " ", "│", "╭", "╮", "│", "│" },
                                results = { "─", "│", "─", "│", "├", "┤", "╯", "╰" },
                            },
                        }),
                    },

                    -- Frecency - Archivos recientes con prioridad
                    frecency = {
                        show_scores = false,
                        show_unindexed = true,
                        ignore_patterns = { "*.git/*", "*/tmp/*", "*/node_modules/*" },
                        workspaces = {
                            ["project"] = vim.fn.getcwd(),
                        },
                    },
                },
            }
        end,

        -- ====================================================================
        -- Cargar extensiones después de la configuración
        -- ====================================================================
        config = function(_, opts)
            local telescope = require("telescope")
            telescope.setup(opts)

            -- Cargar extensiones
            pcall(telescope.load_extension, "fzf")
            pcall(telescope.load_extension, "ui-select")
            pcall(telescope.load_extension, "frecency")
        end,

        -- ====================================================================
        -- Keymaps (definidos también en keymaps.lua, pero aquí para lazy loading)
        -- ====================================================================
        keys = {
            -- Búsqueda de archivos
            { "<leader>ff",        "<cmd>Telescope find_files<cr>",            desc = "Fuzzy Finder - Buscar archivos" },
            { "<leader>fg",        "<cmd>Telescope live_grep<cr>",             desc = "Fuzzy Grep - Buscar texto" },
            { "<leader>fb",        "<cmd>Telescope buffers<cr>",               desc = "Buscar en buffers" },
            { "<leader>fr",        "<cmd>Telescope oldfiles<cr>",              desc = "Archivos recientes" },
            { "<leader>fw",        "<cmd>Telescope grep_string<cr>",           desc = "Buscar palabra bajo cursor" },

            -- Git
            { "<leader>gf",        "<cmd>Telescope git_files<cr>",             desc = "Git files" },
            { "<leader>gc",        "<cmd>Telescope git_commits<cr>",           desc = "Git commits" },
            { "<leader>gb",        "<cmd>Telescope git_branches<cr>",          desc = "Git branches" },
            { "<leader>gs",        "<cmd>Telescope git_status<cr>",            desc = "Git status" },

            -- LSP
            { "<leader>fs",        "<cmd>Telescope lsp_document_symbols<cr>",  desc = "Símbolos del documento" },
            { "<leader>fS",        "<cmd>Telescope lsp_workspace_symbols<cr>", desc = "Símbolos del workspace" },

            -- Utilidades
            { "<leader>fh",        "<cmd>Telescope help_tags<cr>",             desc = "Buscar en ayuda" },
            { "<leader>fc",        "<cmd>Telescope commands<cr>",              desc = "Buscar comandos" },
            { "<leader>fk",        "<cmd>Telescope keymaps<cr>",               desc = "Buscar keymaps" },
            { "<leader>fm",        "<cmd>Telescope marks<cr>",                 desc = "Buscar marks" },
            { "<leader>fR",        "<cmd>Telescope registers<cr>",             desc = "Buscar registros" },

            -- Resume última búsqueda
            { "<leader>f<leader>", "<cmd>Telescope resume<cr>",                desc = "Retomar última búsqueda" },
        },
    },
}
