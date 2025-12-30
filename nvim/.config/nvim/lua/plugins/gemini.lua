return {
    "olimorris/codecompanion.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
    },
    config = function()
        require("codecompanion").setup({
            display = {
                action_palette = {
                    provider = "telescope",
                },
            },
            strategies = {
                chat = {
                    adapter = "gemini",
                    keymaps = {
                        send = {
                            modes = { n = "<C-s>", i = "<C-s>" },
                        },
                        close = {
                            modes = { n = "q", i = "<C-c>" },
                        },
                        options = {
                            modes = { n = "gm" },
                            callback = "keymaps.options",
                            description = "Opciones (Cambiar Modelo)",
                        },
                    },
                },
                inline = {
                    adapter = "gemini",
                },
            },
            adapters = {
                gemini = function()
                    return require("codecompanion.adapters").extend("gemini", {
                        env = {
                            -- Asegúrate de tener export GEMINI_API_KEY="tu_api_key" en tu .bashrc o .zshrc
                            api_key = "cmd:echo $GEMINI_API_KEY",
                        },
                        schema = {
                            model = {
                                default = "gemini-1.5-pro",
                                choices = {
                                    "gemini-1.5-pro",
                                    "gemini-1.5-flash",
                                    "gemini-1.0-pro",
                                },
                            },
                        },
                    })
                end,
            },
        })

        -- Atajos de teclado para Gemini (Cambiados a <leader>i para evitar conflictos con 'a')
        vim.keymap.set({ "n", "v" }, "<leader>ia", "<cmd>CodeCompanionActions<cr>", { desc = "Gemini Actions" })
        vim.keymap.set({ "n", "v" }, "<leader>ic", "<cmd>CodeCompanionChat<cr>", { desc = "Gemini Chat" })
        vim.keymap.set({ "n", "v" }, "<leader>ii", "<cmd>CodeCompanion<cr>", { desc = "Gemini Inline" })
    end,
}
