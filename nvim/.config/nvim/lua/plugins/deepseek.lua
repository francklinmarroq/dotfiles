return {
    "olimorris/codecompanion.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
        "ravitemer/mcphub.nvim",
    },
    config = function()
        require("codecompanion").setup({
            display = {
                action_palette = {
                    provider = "telescope",
                },
                diff = {
                    enabled = true,
                    provider = "mini_diff",
                },
            },
            strategies = {
                chat = {
                    adapter = "deepseek",
                    keymaps = {
                        send = {
                            modes = { n = "<C-s>", i = "<C-s>" },
                        },
                        close = {
                            modes = { n = "q", i = "<C-c>" },
                        },
                    },
                    slash_commands = {
                        buffer = { opts = { provider = "telescope" } },
                        file = { opts = { provider = "telescope" } },
                        symbols = { opts = { provider = "telescope" } },
                        help = { opts = { provider = "telescope" } },
                    },
                },
                inline = {
                    adapter = "deepseek",
                },
            },
            adapters = {
                deepseek = function()
                    return require("codecompanion.adapters").extend("deepseek", {
                        env = {
                            api_key = "DEEPSEEK_API_KEY",
                        },
                        schema = {
                            model = {
                                default = "deepseek-chat",
                            },
                        },
                    })
                end,
                opencode = function()
                    return require("codecompanion.adapters").extend("opencode", {})
                end,
            },
            extensions = {
                mcphub = {
                    callback = "mcphub.extensions.codecompanion",
                    opts = {
                        make_vars = true,
                        make_slash_commands = true,
                        show_result_in_chat = true,
                    },
                },
            },
        })

        -- Keymaps
        vim.keymap.set({ "n", "v" }, "<leader>ia", "<cmd>CodeCompanionActions<cr>", { desc = "AI Actions" })
        vim.keymap.set({ "n", "v" }, "<leader>ic", "<cmd>CodeCompanionChat<cr>", { desc = "AI Chat (DeepSeek)" })
        vim.keymap.set({ "n", "v" }, "<leader>ii", "<cmd>CodeCompanion<cr>", { desc = "AI Inline" })
        vim.keymap.set({ "n", "v" }, "<leader>io", function()
            vim.cmd("CodeCompanionChat adapter=opencode")
        end, { desc = "AI Chat (OpenCode)" })
    end,
}
