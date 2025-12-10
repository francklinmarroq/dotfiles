-- ============================================================================
-- keymaps.lua - Atajos de Teclado Personalizados
-- Leader: <Space> (configurado en init.lua)
-- Optimizado para Vue 3, Nuxt 3, y desarrollo moderno
-- ============================================================================

local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Helper para crear opciones con descripción
local function with_desc(description)
    return vim.tbl_extend("force", opts, { desc = description })
end

-- ============================================================================
-- TELESCOPE - Fuzzy Finder & Grep
-- ============================================================================

-- <leader>ff - Fuzzy Finder (búsqueda de archivos)
keymap("n", "<leader>ff", "<cmd>Telescope find_files<cr>", with_desc("Fuzzy Finder - Buscar archivos"))

-- <leader>fg - Fuzzy Grep (búsqueda de texto en el proyecto)
keymap("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", with_desc("Fuzzy Grep - Buscar texto en proyecto"))

-- Keymaps adicionales de Telescope (útiles para desarrollo)
keymap("n", "<leader>fb", "<cmd>Telescope buffers<cr>", with_desc("Buscar en buffers abiertos"))
keymap("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", with_desc("Archivos recientes"))
keymap("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", with_desc("Buscar en ayuda"))
keymap("n", "<leader>fw", "<cmd>Telescope grep_string<cr>", with_desc("Buscar palabra bajo cursor"))
keymap("n", "<leader>fc", "<cmd>Telescope commands<cr>", with_desc("Buscar comandos"))
keymap("n", "<leader>fk", "<cmd>Telescope keymaps<cr>", with_desc("Buscar keymaps"))
keymap("n", "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", with_desc("Símbolos del documento"))
keymap("n", "<leader>fS", "<cmd>Telescope lsp_workspace_symbols<cr>", with_desc("Símbolos del workspace"))

-- ============================================================================
-- LSP - Language Server Protocol
-- ============================================================================

-- Configuración de keymaps LSP que se activan cuando un LSP se conecta
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
    callback = function(ev)
        local buffer = ev.buf
        local lsp_opts = function(desc)
            return { noremap = true, silent = true, buffer = buffer, desc = desc }
        end

        -- <leader>gf - Formatear documento completo
        keymap("n", "<leader>gf", function()
            require("conform").format({
                async = true,
                lsp_fallback = true,
                timeout_ms = 5000,
            })
        end, lsp_opts("Formatear documento"))

        -- <leader>gd - Go to Definition
        keymap("n", "<leader>gd", vim.lsp.buf.definition, lsp_opts("LSP: Ir a definición"))

        -- <leader>gD - Go to Declaration
        keymap("n", "<leader>gD", vim.lsp.buf.declaration, lsp_opts("LSP: Ir a declaración"))

        -- Keymaps LSP adicionales (muy útiles para Vue/TypeScript)
        keymap("n", "<leader>gi", vim.lsp.buf.implementation, lsp_opts("LSP: Ir a implementación"))
        keymap("n", "<leader>gt", vim.lsp.buf.type_definition, lsp_opts("LSP: Ir a tipo"))
        keymap("n", "<leader>gr", "<cmd>Telescope lsp_references<cr>", lsp_opts("LSP: Buscar referencias"))

        -- Hover y Signature Help
        keymap("n", "K", vim.lsp.buf.hover, lsp_opts("LSP: Hover información"))
        keymap("n", "<C-k>", vim.lsp.buf.signature_help, lsp_opts("LSP: Signature help"))
        keymap("i", "<C-k>", vim.lsp.buf.signature_help, lsp_opts("LSP: Signature help"))

        -- Renombrar símbolo (muy útil en refactoring)
        keymap("n", "<leader>rn", vim.lsp.buf.rename, lsp_opts("LSP: Renombrar símbolo"))

        -- Code Actions (ej: auto-import, quick fixes)
        keymap("n", "<leader>ca", vim.lsp.buf.code_action, lsp_opts("LSP: Code actions"))
        keymap("v", "<leader>ca", vim.lsp.buf.code_action, lsp_opts("LSP: Code actions"))

        -- Diagnósticos
        keymap("n", "<leader>dl", vim.diagnostic.open_float, lsp_opts("Diagnóstico: Ver línea"))
        keymap("n", "[d", vim.diagnostic.goto_prev, lsp_opts("Diagnóstico: Anterior"))
        keymap("n", "]d", vim.diagnostic.goto_next, lsp_opts("Diagnóstico: Siguiente"))
        keymap("n", "<leader>dq", vim.diagnostic.setloclist, lsp_opts("Diagnóstico: Lista"))
    end,
})

-- ============================================================================
-- NAVEGACIÓN Y EDICIÓN GENERAL
-- ============================================================================

-- Mejor navegación entre ventanas
keymap("n", "<C-h>", "<C-w>h", with_desc("Mover a ventana izquierda"))
keymap("n", "<C-j>", "<C-w>j", with_desc("Mover a ventana inferior"))
keymap("n", "<C-k>", "<C-w>k", with_desc("Mover a ventana superior"))
keymap("n", "<C-l>", "<C-w>l", with_desc("Mover a ventana derecha"))

-- Redimensionar ventanas con flechas
keymap("n", "<C-Up>", "<cmd>resize +2<cr>", with_desc("Aumentar altura ventana"))
keymap("n", "<C-Down>", "<cmd>resize -2<cr>", with_desc("Reducir altura ventana"))
keymap("n", "<C-Left>", "<cmd>vertical resize -2<cr>", with_desc("Reducir ancho ventana"))
keymap("n", "<C-Right>", "<cmd>vertical resize +2<cr>", with_desc("Aumentar ancho ventana"))

-- Mover líneas arriba/abajo
keymap("n", "<A-j>", "<cmd>m .+1<cr>==", with_desc("Mover línea abajo"))
keymap("n", "<A-k>", "<cmd>m .-2<cr>==", with_desc("Mover línea arriba"))
keymap("v", "<A-j>", ":m '>+1<cr>gv=gv", with_desc("Mover selección abajo"))
keymap("v", "<A-k>", ":m '<-2<cr>gv=gv", with_desc("Mover selección arriba"))
keymap("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", with_desc("Mover línea abajo"))
keymap("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", with_desc("Mover línea arriba"))

-- Navegación en buffers
keymap("n", "<S-h>", "<cmd>bprevious<cr>", with_desc("Buffer anterior"))
keymap("n", "<S-l>", "<cmd>bnext<cr>", with_desc("Buffer siguiente"))
keymap("n", "<leader>bd", "<cmd>bdelete<cr>", with_desc("Cerrar buffer"))
keymap("n", "<leader>bD", "<cmd>bdelete!<cr>", with_desc("Cerrar buffer (forzar)"))

-- Limpiar resaltado de búsqueda
keymap("n", "<Esc>", "<cmd>nohlsearch<cr>", with_desc("Limpiar búsqueda"))

-- Mantener cursor centrado al navegar
keymap("n", "<C-d>", "<C-d>zz", with_desc("Media página abajo (centrado)"))
keymap("n", "<C-u>", "<C-u>zz", with_desc("Media página arriba (centrado)"))
keymap("n", "n", "nzzzv", with_desc("Siguiente resultado (centrado)"))
keymap("n", "N", "Nzzzv", with_desc("Resultado anterior (centrado)"))

-- Mejor indentación en modo visual (mantiene selección)
keymap("v", "<", "<gv", with_desc("Reducir indentación"))
keymap("v", ">", ">gv", with_desc("Aumentar indentación"))

-- Pegar sin perder el registro
keymap("v", "p", '"_dP', with_desc("Pegar sin perder registro"))

-- ============================================================================
-- UTILIDADES
-- ============================================================================

-- Guardar archivo
keymap("n", "<C-s>", "<cmd>w<cr>", with_desc("Guardar archivo"))
keymap("i", "<C-s>", "<esc><cmd>w<cr>", with_desc("Guardar archivo"))

-- Salir
keymap("n", "<leader>qq", "<cmd>qa<cr>", with_desc("Salir de Neovim"))

-- Nuevo archivo
keymap("n", "<leader>fn", "<cmd>enew<cr>", with_desc("Nuevo archivo"))

-- Toggle wrap
keymap("n", "<leader>uw", "<cmd>set wrap!<cr>", with_desc("Toggle word wrap"))

-- Toggle números relativos
keymap("n", "<leader>un", "<cmd>set relativenumber!<cr>", with_desc("Toggle números relativos"))
