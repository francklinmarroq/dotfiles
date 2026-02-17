-- ============================================================================
-- options.lua - Opciones Generales de Neovim
-- Optimizado para desarrollo moderno con Vue 3, Nuxt 3, y TypeScript
-- ============================================================================

local opt = vim.opt

-- ============================================================================
-- Interfaz de Usuario
-- ============================================================================
opt.number = true         -- Mostrar números de línea
opt.relativenumber = true -- Números relativos para navegación rápida
opt.cursorline = true     -- Resaltar línea actual
opt.signcolumn = "yes"    -- Siempre mostrar columna de signos (para LSP/git)
opt.termguicolors = true  -- Colores de 24-bit
opt.showmode = false      -- No mostrar modo (ya lo muestra lualine)
opt.showcmd = false       -- No mostrar comandos parciales
opt.laststatus = 3        -- Línea de estado global
opt.cmdheight = 1         -- Altura de la línea de comandos
opt.pumheight = 10        -- Máximo items en popup de completado
opt.pumblend = 10         -- Transparencia del popup
opt.winblend = 10         -- Transparencia de ventanas flotantes
opt.scrolloff = 8         -- Líneas de contexto al hacer scroll
opt.sidescrolloff = 8     -- Columnas de contexto al hacer scroll horizontal

-- ============================================================================
-- Indentación y Formateo
-- ============================================================================
opt.expandtab = true   -- Usar espacios en lugar de tabs
opt.shiftwidth = 2     -- Tamaño de indentación (común en Vue/JS/TS)
opt.tabstop = 2        -- Tamaño visual de tab
opt.softtabstop = 2    -- Espacios por tab al editar
opt.smartindent = true -- Indentación inteligente
opt.autoindent = true  -- Mantener indentación de línea anterior
opt.wrap = false       -- No hacer wrap de líneas largas

-- ============================================================================
-- Búsqueda
-- ============================================================================
opt.ignorecase = true -- Búsqueda case-insensitive
opt.smartcase = true  -- Case-sensitive si hay mayúsculas
opt.hlsearch = true   -- Resaltar resultados de búsqueda
opt.incsearch = true  -- Búsqueda incremental

-- ============================================================================
-- Archivos y Buffers
-- ============================================================================
opt.hidden = true          -- Permitir buffers ocultos sin guardar
opt.backup = false         -- No crear archivos de backup
opt.writebackup = false    -- No crear backup al escribir
opt.swapfile = false       -- No crear archivos swap
opt.undofile = true        -- Persistir historial de undo
opt.undolevels = 10000     -- Niveles de undo
opt.autoread = true        -- Recargar archivos modificados externamente
opt.fileencoding = "utf-8" -- Encoding de archivos

-- ============================================================================
-- Rendimiento y Tiempos
-- ============================================================================
opt.updatetime = 200  -- Tiempo para CursorHold (ms) - importante para LSP
opt.timeoutlen = 500  -- Tiempo para secuencias de teclas (ms)
opt.redrawtime = 1500 -- Tiempo máximo para resaltado de sintaxis

-- ============================================================================
-- Completado y Menús
-- ============================================================================
opt.completeopt = { "menu", "menuone", "noselect" }
opt.wildmode = "longest:full,full"
opt.wildmenu = true

-- ============================================================================
-- Splits (División de Ventanas)
-- ============================================================================
opt.splitbelow = true    -- Splits horizontales abajo
opt.splitright = true    -- Splits verticales a la derecha
opt.splitkeep = "screen" -- Mantener posición de pantalla al dividir

-- ============================================================================
-- Clipboard
-- ============================================================================
opt.clipboard = "unnamedplus" -- Usar clipboard del sistema

-- ============================================================================
-- Mouse
-- ============================================================================
opt.mouse = "a" -- Habilitar mouse en todos los modos

-- ============================================================================
-- Folding (Plegado de Código)
-- ============================================================================
opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"
opt.foldlevel = 99 -- No plegar por defecto
opt.foldlevelstart = 99
opt.foldenable = true

-- ============================================================================
-- Caracteres Especiales
-- ============================================================================
opt.list = true
opt.listchars = {
    tab = "» ",
    trail = "·",
    nbsp = "␣",
    extends = "❯",
    precedes = "❮",
}
opt.fillchars = {
    foldopen = "-",
    foldclose = "+",
    fold = " ",
    foldsep = " ",
    diff = "/",
    eob = " ",
}

-- ============================================================================
-- Grep (para búsquedas con Telescope)
-- ============================================================================
opt.grepformat = "%f:%l:%c:%m"
opt.grepprg = "rg --vimgrep"

-- ============================================================================
-- Configuración específica para Vue/Nuxt
-- ============================================================================
vim.filetype.add({
    extension = {
        vue = "vue",
    },
    pattern = {
        [".*%.vue"] = "vue",
        ["nuxt%.config%.[jt]s"] = "typescript",
        ["app%.config%.[jt]s"] = "typescript",
    },
})

-- ============================================================================
-- Deshabilitar proveedores innecesarios (mejora rendimiento)
-- ============================================================================
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

