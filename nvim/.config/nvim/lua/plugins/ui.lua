-- ============================================================================
-- ui.lua - Configuración de Interfaz de Usuario
-- Tema, statusline, y mejoras visuales para Vue 3, Nuxt 3, y TypeScript
-- ============================================================================

return {
  -- ============================================================================
  -- tokyonight.nvim - Tema principal
  -- ============================================================================
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "night",       -- Opciones: storm, moon, night, day
      transparent = false,
      terminal_colors = true,
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
        functions = {},
        variables = {},
        sidebars = "dark",
        floats = "dark",
      },
      sidebars = { "qf", "help", "terminal", "packer", "neo-tree" },
      -- Personalización de colores para Vue/TypeScript
      on_highlights = function(hl, c)
        -- Mejor contraste para componentes Vue
        hl["@tag"] = { fg = c.red }
        hl["@tag.attribute"] = { fg = c.yellow }
        hl["@tag.delimiter"] = { fg = c.dark5 }
        -- TypeScript/JavaScript
        hl["@type.typescript"] = { fg = c.blue1 }
        hl["@constructor.typescript"] = { fg = c.magenta }
      end,
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd([[colorscheme tokyonight]])
    end,
  },

  -- ============================================================================
  -- dracula.nvim - Dracula theme
  -- ============================================================================
  {
    "dracula/vim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme dracula]])
    end,
  },

  -- ============================================================================
  -- lualine.nvim - Línea de estado
  -- ============================================================================
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = function()
      local icons = {
        diagnostics = {
          Error = " ",
          Warn = " ",
          Hint = " ",
          Info = " ",
        },
        git = {
          added = " ",
          modified = " ",
          removed = " ",
        },
      }

      return {
        options = {
          theme = "auto",
          globalstatus = true,
          disabled_filetypes = { statusline = { "dashboard", "alpha" } },
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
        },
        sections = {
          lualine_a = {
            { "mode", separator = { left = "" }, right_padding = 2 },
          },
          lualine_b = {
            { "branch", icon = "" },
            {
              "diff",
              symbols = {
                added = icons.git.added,
                modified = icons.git.modified,
                removed = icons.git.removed,
              },
            },
          },
          lualine_c = {
            {
              "filename",
              path = 1,               -- Mostrar ruta relativa
              symbols = {
                modified = "●",
                readonly = "",
                unnamed = "[Sin nombre]",
                newfile = "[Nuevo]",
              },
            },
            {
              "diagnostics",
              sources = { "nvim_diagnostic" },
              symbols = {
                error = icons.diagnostics.Error,
                warn = icons.diagnostics.Warn,
                info = icons.diagnostics.Info,
                hint = icons.diagnostics.Hint,
              },
            },
          },
          lualine_x = {
            -- Mostrar si hay LSP activo
            {
              function()
                local clients = vim.lsp.get_clients({ bufnr = 0 })
                if #clients == 0 then
                  return ""
                end
                local names = {}
                for _, client in ipairs(clients) do
                  table.insert(names, client.name)
                end
                return "󰒋 " .. table.concat(names, ", ")
              end,
              color = { fg = "#7aa2f7" },
            },
          },
          lualine_y = {
            { "filetype",   icon_only = true },
            { "encoding" },
            { "fileformat", symbols = { unix = "", dos = "", mac = "" } },
          },
          lualine_z = {
            { "progress" },
            { "location", separator = { right = "" }, left_padding = 2 },
          },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { { "filename", path = 1 } },
          lualine_x = { "location" },
          lualine_y = {},
          lualine_z = {},
        },
        extensions = { "neo-tree", "lazy", "quickfix", "man", "fugitive" },
      }
    end,
  },

  -- ============================================================================
  -- bufferline.nvim - Pestañas de buffers
  -- ============================================================================
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        mode = "buffers",
        themable = true,
        numbers = "none",
        close_command = "bdelete! %d",
        right_mouse_command = "bdelete! %d",
        left_mouse_command = "buffer %d",
        middle_mouse_command = nil,
        indicator = {
          icon = "▎",
          style = "icon",
        },
        buffer_close_icon = "󰅖",
        modified_icon = "●",
        close_icon = "",
        left_trunc_marker = "",
        right_trunc_marker = "",
        -- Mostrar iconos por tipo de archivo
        show_buffer_icons = true,
        show_buffer_close_icons = true,
        show_close_icon = false,
        show_tab_indicators = true,
        persist_buffer_sort = true,
        separator_style = "thin",
        enforce_regular_tabs = false,
        always_show_bufferline = true,
        hover = {
          enabled = true,
          delay = 150,
          reveal = { "close" },
        },
        -- Diagnósticos del LSP en las pestañas
        diagnostics = "nvim_lsp",
        diagnostics_update_in_insert = false,
        diagnostics_indicator = function(count, level, diagnostics_dict, context)
          local s = " "
          for e, n in pairs(diagnostics_dict) do
            local sym = e == "error" and " " or (e == "warning" and " " or " ")
            s = s .. sym .. n
          end
          return s
        end,
        -- Desplazamiento cuando hay muchos buffers
        offsets = {
          {
            filetype = "neo-tree",
            text = "Explorador",
            highlight = "Directory",
            text_align = "center",
            separator = true,
          },
        },
      },
    },
    keys = {
      { "<leader>bp", "<cmd>BufferLineTogglePin<cr>",            desc = "Pin buffer" },
      { "<leader>bP", "<cmd>BufferLineGroupClose ungrouped<cr>", desc = "Cerrar buffers no pinneados" },
      { "<leader>bo", "<cmd>BufferLineCloseOthers<cr>",          desc = "Cerrar otros buffers" },
      { "<leader>br", "<cmd>BufferLineCloseRight<cr>",           desc = "Cerrar buffers a la derecha" },
      { "<leader>bl", "<cmd>BufferLineCloseLeft<cr>",            desc = "Cerrar buffers a la izquierda" },
      { "[b",         "<cmd>BufferLineCyclePrev<cr>",            desc = "Buffer anterior" },
      { "]b",         "<cmd>BufferLineCycleNext<cr>",            desc = "Buffer siguiente" },
    },
  },

  -- ============================================================================
  -- indent-blankline.nvim - Guías de indentación
  -- ============================================================================
  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPost", "BufNewFile" },
    main = "ibl",
    opts = {
      indent = {
        char = "│",
        tab_char = "│",
      },
      scope = {
        enabled = true,
        show_start = true,
        show_end = false,
        highlight = { "Function", "Label" },
      },
      exclude = {
        filetypes = {
          "help",
          "alpha",
          "dashboard",
          "neo-tree",
          "Trouble",
          "lazy",
          "mason",
          "notify",
          "toggleterm",
          "lazyterm",
        },
      },
    },
  },

  -- ============================================================================
  -- nvim-notify - Notificaciones mejoradas
  -- ============================================================================
  {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    opts = {
      timeout = 3000,
      max_height = function()
        return math.floor(vim.o.lines * 0.75)
      end,
      max_width = function()
        return math.floor(vim.o.columns * 0.75)
      end,
      stages = "fade_in_slide_out",
      render = "default",
      background_colour = "#000000",
      icons = {
        ERROR = "",
        WARN = "",
        INFO = "",
        DEBUG = "",
        TRACE = "✎",
      },
    },
    config = function(_, opts)
      require("notify").setup(opts)
      vim.notify = require("notify")
    end,
    keys = {
      {
        "<leader>un",
        function()
          require("notify").dismiss({ silent = true, pending = true })
        end,
        desc = "Descartar notificaciones",
      },
    },
  },

  -- ============================================================================
  -- noice.nvim - UI mejorada para cmdline, mensajes, y popupmenu
  -- ============================================================================
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
        hover = {
          enabled = true,
        },
        signature = {
          enabled = true,
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = true,
        lsp_doc_border = true,
      },
      routes = {
        -- Ocultar mensajes de "written" al guardar
        {
          filter = {
            event = "msg_show",
            kind = "",
            find = "written",
          },
          opts = { skip = true },
        },
        -- Ocultar mensajes de búsqueda
        {
          filter = {
            event = "msg_show",
            kind = "search_count",
          },
          opts = { skip = true },
        },
      },
    },
    keys = {
      { "<leader>nl", function() require("noice").cmd("last") end,    desc = "Último mensaje de Noice" },
      { "<leader>nh", function() require("noice").cmd("history") end, desc = "Historial de Noice" },
      { "<leader>na", function() require("noice").cmd("all") end,     desc = "Todos los mensajes de Noice" },
      { "<leader>nd", function() require("noice").cmd("dismiss") end, desc = "Descartar mensajes de Noice" },
    },
  },

  -- ============================================================================
  -- which-key.nvim - Mostrar keymaps disponibles
  -- ============================================================================
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      plugins = {
        marks = true,
        registers = true,
        spelling = {
          enabled = true,
          suggestions = 20,
        },
        presets = {
          operators = true,
          motions = true,
          text_objects = true,
          windows = true,
          nav = true,
          z = true,
          g = true,
        },
      },
      -- Grupos de keymaps para el menú
      defaults = {},
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)

      -- Registrar grupos de keymaps
      wk.add({
        { "<leader>i", group = "AI (DeepSeek)" },
        { "<leader>b", group = "Buffer" },
        { "<leader>c", group = "Code" },
        { "<leader>d", group = "Diagnósticos" },
        { "<leader>f", group = "Buscar (Telescope)" },
        { "<leader>g", group = "Git / Go to" },
        { "<leader>q", group = "Salir" },
        { "<leader>r", group = "Renombrar" },
        { "<leader>s", group = "Swap" },
        { "<leader>t", group = "Toggle" },
        { "<leader>u", group = "UI/Utils" },
        { "<leader>p", group = "Peek" },
      })
    end,
  },

  -- ============================================================================
  -- neo-tree.nvim - Explorador de archivos
  -- ============================================================================
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "<leader>e",  "<cmd>Neotree toggle<cr>",     desc = "Explorador de archivos" },
      { "<leader>E",  "<cmd>Neotree reveal<cr>",     desc = "Revelar archivo actual" },
      { "<leader>ge", "<cmd>Neotree git_status<cr>", desc = "Git status en Neo-tree" },
      { "<leader>be", "<cmd>Neotree buffers<cr>",    desc = "Buffers en Neo-tree" },
    },
    opts = {
      close_if_last_window = true,
      popup_border_style = "rounded",
      enable_git_status = true,
      enable_diagnostics = true,
      sort_case_insensitive = true,
      default_component_configs = {
        indent = {
          with_expanders = true,
          expander_collapsed = "",
          expander_expanded = "",
        },
        icon = {
          folder_closed = "",
          folder_open = "",
          folder_empty = "",
          default = "󰈙",
        },
        modified = {
          symbol = "●",
        },
        git_status = {
          symbols = {
            added     = "",
            modified  = "",
            deleted   = "",
            renamed   = "󰁕",
            untracked = "",
            ignored   = "",
            unstaged  = "󰄱",
            staged    = "",
            conflict  = "",
          },
        },
      },
      filesystem = {
        bind_to_cwd = true,
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = true,
          hide_by_name = {
            "node_modules",
            ".git",
            ".nuxt",
            ".output",
          },
          never_show = {
            ".DS_Store",
            "thumbs.db",
          },
        },
      },
      window = {
        position = "left",
        width = 35,
        mappings = {
          ["<space>"] = "none",
          ["<cr>"] = "open",
          ["o"] = "open",
          ["s"] = "open_split",
          ["v"] = "open_vsplit",
          ["t"] = "open_tabnew",
          ["a"] = { "add", config = { show_path = "relative" } },
          ["d"] = "delete",
          ["r"] = "rename",
          ["c"] = "copy",
          ["m"] = "move",
          ["y"] = "copy_to_clipboard",
          ["x"] = "cut_to_clipboard",
          ["p"] = "paste_from_clipboard",
          ["q"] = "close_window",
          ["R"] = "refresh",
          ["?"] = "show_help",
        },
      },
    },
  },

  -- ============================================================================
  -- dressing.nvim - UI mejorada para vim.ui.select y vim.ui.input
  -- ============================================================================
  {
    "stevearc/dressing.nvim",
    lazy = true,
    init = function()
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.select = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.select(...)
      end
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.input = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.input(...)
      end
    end,
  },

  -- ============================================================================
  -- todo-comments.nvim - Resaltar comentarios TODO, FIXME, etc.
  -- ============================================================================
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      signs = true,
      keywords = {
        FIX = { icon = " ", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
        TODO = { icon = " ", color = "info" },
        HACK = { icon = " ", color = "warning" },
        WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
        PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
        NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
        TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
      },
    },
    keys = {
      { "]t",         function() require("todo-comments").jump_next() end, desc = "Siguiente TODO" },
      { "[t",         function() require("todo-comments").jump_prev() end, desc = "TODO anterior" },
      { "<leader>ft", "<cmd>TodoTelescope<cr>",                            desc = "Buscar TODOs" },
      { "<leader>fT", "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>",    desc = "Buscar TODO/FIX/FIXME" },
    },
  },

  -- ============================================================================
  -- nvim-colorizer.lua - Visualizar colores en el código
  -- ============================================================================
  {
    "NvChad/nvim-colorizer.lua",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      filetypes = {
        "*",
        vue = { names = true, css = true, tailwind = true },
        css = { names = true, css = true },
        scss = { names = true, css = true },
        html = { names = true },
      },
      user_default_options = {
        RGB = true,
        RRGGBB = true,
        RRGGBBAA = true,
        css = true,
        css_fn = true,
        tailwind = true,
        mode = "background",
        virtualtext = "■",
      },
    },
  },
}
