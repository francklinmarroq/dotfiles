-- ============================================================================
-- java.lua - Configuración para desarrollo Java con Spring Boot
-- Incluye jdtls, debugging, testing, y soporte para Spring Boot
-- ============================================================================

return {
    -- ============================================================================
    -- nvim-jdtls - Java Language Server (Eclipse JDT.LS)
    -- ============================================================================
    {
        "mfussenegger/nvim-jdtls",
        ft = { "java" },
        dependencies = {
            "mfussenegger/nvim-dap",
            "williamboman/mason.nvim",
        },
        opts = function()
            local mason_registry = require("mason-registry")

            -- Paths for jdtls
            local jdtls_path = mason_registry.get_package("jdtls"):get_install_path()
            local java_debug_path = mason_registry.get_package("java-debug-adapter"):get_install_path()
            local java_test_path = mason_registry.get_package("java-test"):get_install_path()

            -- Bundles for debugging and testing
            local bundles = {}

            -- Add java-debug-adapter
            local java_debug_bundle = vim.fn.glob(
            java_debug_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar", true)
            if java_debug_bundle ~= "" then
                table.insert(bundles, java_debug_bundle)
            end

            -- Add java-test
            local java_test_bundles = vim.split(vim.fn.glob(java_test_path .. "/extension/server/*.jar", true), "\n")
            for _, bundle in ipairs(java_test_bundles) do
                if bundle ~= "" then
                    table.insert(bundles, bundle)
                end
            end

            return {
                -- Command to start jdtls
                cmd = {
                    "java",
                    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
                    "-Dosgi.bundles.defaultStartLevel=4",
                    "-Declipse.product=org.eclipse.jdt.ls.core.product",
                    "-Dlog.protocol=true",
                    "-Dlog.level=ALL",
                    "-Xmx1g",
                    "--add-modules=ALL-SYSTEM",
                    "--add-opens", "java.base/java.util=ALL-UNNAMED",
                    "--add-opens", "java.base/java.lang=ALL-UNNAMED",
                    "-jar", vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar"),
                    "-configuration", jdtls_path .. "/config_linux",
                    "-data", vim.fn.stdpath("cache") .. "/jdtls/" .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t"),
                },

                root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }),

                settings = {
                    java = {
                        -- Eclipse settings
                        eclipse = {
                            downloadSources = true,
                        },
                        -- Maven settings
                        maven = {
                            downloadSources = true,
                        },
                        -- Gradle settings
                        gradle = {
                            enabled = true,
                        },
                        -- References and implementations code lens
                        referencesCodeLens = {
                            enabled = true,
                        },
                        implementationsCodeLens = {
                            enabled = true,
                        },
                        -- Signature help
                        signatureHelp = {
                            enabled = true,
                            description = {
                                enabled = true,
                            },
                        },
                        -- Formatting
                        format = {
                            enabled = true,
                            settings = {
                                url = vim.fn.stdpath("config") .. "/java-formatter.xml",
                                profile = "GoogleStyle",
                            },
                        },
                        -- Completion settings
                        completion = {
                            favoriteStaticMembers = {
                                "org.junit.Assert.*",
                                "org.junit.Assume.*",
                                "org.junit.jupiter.api.Assertions.*",
                                "org.junit.jupiter.api.Assumptions.*",
                                "org.junit.jupiter.api.DynamicContainer.*",
                                "org.junit.jupiter.api.DynamicTest.*",
                                "org.mockito.Mockito.*",
                                "org.mockito.ArgumentMatchers.*",
                                "org.mockito.Answers.*",
                                "org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*",
                                "org.springframework.test.web.servlet.result.MockMvcResultMatchers.*",
                                "org.springframework.test.web.servlet.result.MockMvcResultHandlers.*",
                                "org.hamcrest.Matchers.*",
                                "org.hamcrest.CoreMatchers.*",
                            },
                            importOrder = {
                                "java",
                                "javax",
                                "jakarta",
                                "org",
                                "com",
                            },
                            filteredTypes = {
                                "com.sun.*",
                                "io.micrometer.shaded.*",
                                "java.awt.*",
                                "jdk.*",
                                "sun.*",
                            },
                        },
                        -- Source settings
                        sources = {
                            organizeImports = {
                                starThreshold = 9999,
                                staticStarThreshold = 9999,
                            },
                        },
                        -- Code generation settings
                        codeGeneration = {
                            toString = {
                                template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
                            },
                            useBlocks = true,
                            hashCodeEquals = {
                                useJava7Objects = true,
                                useInstanceof = true,
                            },
                        },
                        -- Inlay hints
                        inlayHints = {
                            parameterNames = {
                                enabled = "all",
                            },
                        },
                        -- Configuration settings
                        configuration = {
                            updateBuildConfiguration = "automatic",
                            -- Add your runtime environments here
                            runtimes = {
                                -- {
                                --     name = "JavaSE-17",
                                --     path = "/usr/lib/jvm/java-17-openjdk",
                                -- },
                                -- {
                                --     name = "JavaSE-21",
                                --     path = "/usr/lib/jvm/java-21-openjdk",
                                -- },
                            },
                        },
                    },
                },

                -- Bundles for debugging and testing
                init_options = {
                    bundles = bundles,
                    extendedClientCapabilities = {
                        progressReportProvider = true,
                        classFileContentsSupport = true,
                        generateToStringPromptSupport = true,
                        hashCodeEqualsPromptSupport = true,
                        advancedExtractRefactoringSupport = true,
                        advancedOrganizeImportsSupport = true,
                        generateConstructorsPromptSupport = true,
                        generateDelegateMethodsPromptSupport = true,
                        moveRefactoringSupport = true,
                        overrideMethodsPromptSupport = true,
                        inferSelectionSupport = { "extractMethod", "extractVariable", "extractConstant" },
                    },
                },
            }
        end,

        config = function(_, opts)
            -- Setup autocmd to attach jdtls
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "java",
                callback = function()
                    local jdtls = require("jdtls")

                    -- Attach keymaps when LSP attaches
                    opts.on_attach = function(client, bufnr)
                        local keymap = vim.keymap.set
                        local kopts = { noremap = true, silent = true, buffer = bufnr }

                        -- Java specific keymaps
                        keymap("n", "<leader>jo", jdtls.organize_imports,
                            vim.tbl_extend("force", kopts, { desc = "Java: Organize Imports" }))
                        keymap("n", "<leader>jv", jdtls.extract_variable,
                            vim.tbl_extend("force", kopts, { desc = "Java: Extract Variable" }))
                        keymap("v", "<leader>jv", function() jdtls.extract_variable(true) end,
                            vim.tbl_extend("force", kopts, { desc = "Java: Extract Variable" }))
                        keymap("n", "<leader>jc", jdtls.extract_constant,
                            vim.tbl_extend("force", kopts, { desc = "Java: Extract Constant" }))
                        keymap("v", "<leader>jc", function() jdtls.extract_constant(true) end,
                            vim.tbl_extend("force", kopts, { desc = "Java: Extract Constant" }))
                        keymap("v", "<leader>jm", function() jdtls.extract_method(true) end,
                            vim.tbl_extend("force", kopts, { desc = "Java: Extract Method" }))

                        -- Testing keymaps
                        keymap("n", "<leader>jt", function() jdtls.test_class() end,
                            vim.tbl_extend("force", kopts, { desc = "Java: Test Class" }))
                        keymap("n", "<leader>jn", function() jdtls.test_nearest_method() end,
                            vim.tbl_extend("force", kopts, { desc = "Java: Test Nearest Method" }))

                        -- Debug keymaps
                        keymap("n", "<leader>jd", function()
                            if vim.bo.modified then
                                vim.cmd("write")
                            end
                            jdtls.test_class({
                                config_overrides = {
                                    stepFilters = {
                                        skipClasses = { "$JDK", "junit.*" },
                                        skipSynthetics = true,
                                    },
                                },
                                after_test = function()
                                    require("dap").continue()
                                end,
                            })
                        end, vim.tbl_extend("force", kopts, { desc = "Java: Debug Class" }))

                        -- Code generation
                        keymap("n", "<leader>jg", function()
                            vim.ui.select({
                                "Generate Constructor",
                                "Generate toString",
                                "Generate hashCode and equals",
                                "Generate Delegate Methods",
                                "Override Methods",
                            }, { prompt = "Java Code Generation:" }, function(choice)
                                if choice == "Generate Constructor" then
                                    jdtls.generate_constructor()
                                elseif choice == "Generate toString" then
                                    jdtls.generate_toString()
                                elseif choice == "Generate hashCode and equals" then
                                    jdtls.generate_hashCodeEquals()
                                elseif choice == "Generate Delegate Methods" then
                                    jdtls.generate_delegate_methods()
                                elseif choice == "Override Methods" then
                                    jdtls.override_methods()
                                end
                            end)
                        end, vim.tbl_extend("force", kopts, { desc = "Java: Generate Code" }))

                        -- Setup DAP
                        pcall(function()
                            jdtls.setup_dap({ hotcodereplace = "auto" })
                            require("jdtls.dap").setup_dap_main_class_configs()
                        end)
                    end

                    jdtls.start_or_attach(opts)
                end,
            })
        end,
    },

    -- ============================================================================
    -- nvim-dap - Debug Adapter Protocol
    -- ============================================================================
    {
        "mfussenegger/nvim-dap",
        optional = true,
        keys = {
            { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, desc = "Breakpoint Condition" },
            { "<leader>db", function() require("dap").toggle_breakpoint() end,                                    desc = "Toggle Breakpoint" },
            { "<leader>dc", function() require("dap").continue() end,                                             desc = "Continue" },
            { "<leader>di", function() require("dap").step_into() end,                                            desc = "Step Into" },
            { "<leader>do", function() require("dap").step_out() end,                                             desc = "Step Out" },
            { "<leader>dO", function() require("dap").step_over() end,                                            desc = "Step Over" },
            { "<leader>dr", function() require("dap").repl.toggle() end,                                          desc = "Toggle REPL" },
            { "<leader>ds", function() require("dap").session() end,                                              desc = "Session" },
            { "<leader>dt", function() require("dap").terminate() end,                                            desc = "Terminate" },
        },
    },

    -- ============================================================================
    -- nvim-dap-ui - Debug UI
    -- ============================================================================
    {
        "rcarriga/nvim-dap-ui",
        dependencies = {
            "mfussenegger/nvim-dap",
            "nvim-neotest/nvim-nio",
        },
        keys = {
            { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle DAP UI" },
            { "<leader>de", function() require("dapui").eval() end,   desc = "Eval",         mode = { "n", "v" } },
        },
        opts = {
            layouts = {
                {
                    elements = {
                        { id = "scopes",      size = 0.25 },
                        { id = "breakpoints", size = 0.25 },
                        { id = "stacks",      size = 0.25 },
                        { id = "watches",     size = 0.25 },
                    },
                    position = "left",
                    size = 40,
                },
                {
                    elements = {
                        { id = "repl",    size = 0.5 },
                        { id = "console", size = 0.5 },
                    },
                    position = "bottom",
                    size = 10,
                },
            },
        },
        config = function(_, opts)
            local dap = require("dap")
            local dapui = require("dapui")
            dapui.setup(opts)

            -- Auto open/close DAP UI
            dap.listeners.after.event_initialized["dapui_config"] = function()
                dapui.open()
            end
            dap.listeners.before.event_terminated["dapui_config"] = function()
                dapui.close()
            end
            dap.listeners.before.event_exited["dapui_config"] = function()
                dapui.close()
            end
        end,
    },

    -- ============================================================================
    -- Mason - Ensure Java tools are installed
    -- ============================================================================
    {
        "mason-org/mason.nvim",
        opts = {
            ensure_installed = {
                "jdtls",
                "java-debug-adapter",
                "java-test",
                "google-java-format",
            },
        },
    },

    -- ============================================================================
    -- Treesitter - Java parser
    -- ============================================================================
    {
        "nvim-treesitter/nvim-treesitter",
        opts = function(_, opts)
            if type(opts.ensure_installed) == "table" then
                vim.list_extend(opts.ensure_installed, { "java" })
            end
        end,
    },

    -- ============================================================================
    -- Conform - Java formatting
    -- ============================================================================
    {
        "stevearc/conform.nvim",
        opts = {
            formatters_by_ft = {
                java = { "google-java-format" },
            },
            formatters = {
                ["google-java-format"] = {
                    prepend_args = { "--aosp" }, -- Android style (4 spaces indent)
                },
            },
        },
    },

    -- ============================================================================
    -- Which-key - Java keymaps group
    -- ============================================================================
    {
        "folke/which-key.nvim",
        opts = function(_, opts)
            local wk = require("which-key")
            wk.add({
                { "<leader>j", group = "Java" },
                { "<leader>d", group = "Debug" },
            })
        end,
    },
}
