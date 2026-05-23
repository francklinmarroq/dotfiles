-- ============================================================================
-- java.lua - Configuración para desarrollo Java/Kotlin con Spring Boot
-- Incluye jdtls, kotlin-language-server, debugging, testing, y soporte Spring Boot
-- ============================================================================

return {
    -- ============================================================================
    -- Función para detectar Java runtimes automáticamente
    -- ============================================================================
    -- Esta función busca JDKs instalados en paths comunes de Linux
    -- y los configura dinámicamente en jdtls settings
    -- ============================================================================

    -- ============================================================================
    -- nvim-jdtls - Java Language Server (Eclipse JDT.LS)
    -- ============================================================================
    {
        "mfussenegger/nvim-jdtls",
        ft = { "java" },
        dependencies = {
            "mfussenegger/nvim-dap",
            "mason-org/mason.nvim",
        },
        opts = function()
            local mason_registry = require("mason-registry")

            -- Paths for jdtls - use pcall to handle missing packages gracefully
            local ok, jdtls_pkg = pcall(mason_registry.get_package, mason_registry, "jdtls")
            local jdtls_path = ok and jdtls_pkg:get_install_path() or nil

            local ok_debug, java_debug_pkg = pcall(mason_registry.get_package, mason_registry, "java-debug-adapter")
            local java_debug_path = ok_debug and java_debug_pkg:get_install_path() or nil

            local ok_test, java_test_pkg = pcall(mason_registry.get_package, mason_registry, "java-test")
            local java_test_path = ok_test and java_test_pkg:get_install_path() or nil

            -- Check if critical jdtls package is installed
            if not jdtls_path then
                vim.notify("jdtls not installed. Run :MasonInstall jdtls", vim.log.levels.WARN)
                return {}
            end

            -- Bundles for debugging and testing
            local bundles = {}

            -- Add java-debug-adapter (if installed)
            if java_debug_path then
                local java_debug_bundle = vim.fn.glob(
                java_debug_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar", true)
                if java_debug_bundle ~= "" then
                    table.insert(bundles, java_debug_bundle)
                end
            else
                vim.notify("java-debug-adapter not installed. Debugging may not work. Run :MasonInstall java-debug-adapter", vim.log.levels.WARN)
            end

            -- Add java-test (if installed)
            if java_test_path then
                local java_test_bundles = vim.split(vim.fn.glob(java_test_path .. "/extension/server/*.jar", true), "\n")
                for _, bundle in ipairs(java_test_bundles) do
                    if bundle ~= "" then
                        table.insert(bundles, bundle)
                    end
                end
            else
                vim.notify("java-test not installed. Testing may not work. Run :MasonInstall java-test", vim.log.levels.WARN)
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
                            -- Runtimes detectados automáticamente
                            runtimes = (function()
                                local runtimes = {}
                                local search_paths = {
                                    "/usr/lib/jvm",
                                    "/usr/local/lib/jvm",
                                    vim.fn.expand("$HOME/.sdkman/candidates/java"),
                                }

                                -- Patrones para detectar JDK 17 y 21
                                local jdk_patterns = {
                                    { version = "JavaSE-17", pattern = "java%-17", priority = 17 },
                                    { version = "JavaSE-21", pattern = "java%-21", priority = 21 },
                                }

                                for _, search_path in ipairs(search_paths) do
                                    if vim.fn.isdirectory(search_path) == 1 then
                                        local handle = vim.loop.fs_scandir(search_path)
                                        if handle then
                                            while true do
                                                local name, type = vim.loop.fs_scandir_next(handle)
                                                if not name then break end
                                                if type == "directory" or type == "link" then
                                                    for _, jdk in ipairs(jdk_patterns) do
                                                        if name:match(jdk.pattern) then
                                                            local jdk_path = search_path .. "/" .. name
                                                            -- Verificar que java exista en el path
                                                            if vim.fn.executable(jdk_path .. "/bin/java") == 1 then
                                                                table.insert(runtimes, {
                                                                    name = jdk.version,
                                                                    path = jdk_path,
                                                                })
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end

                                -- Si no se encontraron runtimes, dejar comentado con instrucciones
                                if #runtimes == 0 then
                                    -- Para configurar runtimes manualmente, descomenta y ajusta:
                                    -- runtimes = {
                                    --     { name = "JavaSE-17", path = "/usr/lib/jvm/java-17-openjdk" },
                                    --     { name = "JavaSE-21", path = "/usr/lib/jvm/java-21-openjdk" },
                                    -- }
                                    vim.notify(
                                        "No se detectaron JDK 17/21 automáticamente. Configura runtimes manualmente en java.lua",
                                        vim.log.levels.WARN)
                                end

                                return runtimes
                            end)(),
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
            -- Create an augroup to avoid duplicate autocmds
            local jdtls_augroup = vim.api.nvim_create_augroup("jdtls_setup", { clear = true })

            -- Setup autocmd to attach jdtls
            vim.api.nvim_create_autocmd("FileType", {
                group = jdtls_augroup,
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

                        -- Hot code replace manual
                        keymap("n", "<leader>jh", function()
                            jdtls.java_execute_command("java.edit.handleFileEvent")
                            vim.notify("Hot code replace ejecutado", vim.log.levels.INFO)
                        end, vim.tbl_extend("force", kopts, { desc = "Java: Hot Code Replace" }))

                        -- Run Spring Boot app
                        keymap("n", "<leader>jr", function()
                            local root = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" })
                            if not root then
                                vim.notify("No se encontró un proyecto Java/Kotlin", vim.log.levels.WARN)
                                return
                            end

                            -- Detectar si es Maven o Gradle
                            local build_tool = nil
                            if vim.fn.filereadable(root .. "/mvnw") == 1 then
                                build_tool = "maven"
                            elseif vim.fn.filereadable(root .. "/gradlew") == 1 then
                                build_tool = "gradle"
                            elseif vim.fn.filereadable(root .. "/pom.xml") == 1 then
                                build_tool = "maven"
                            elseif vim.fn.filereadable(root .. "/build.gradle") == 1 or vim.fn.filereadable(root .. "/build.gradle.kts") == 1 then
                                build_tool = "gradle"
                            end

                            if build_tool == "maven" then
                                local cmd = vim.fn.filereadable(root .. "/mvnw") == 1 and "./mvnw" or "mvn"
                                vim.cmd("term " .. cmd .. " spring-boot:run")
                            elseif build_tool == "gradle" then
                                local cmd = vim.fn.filereadable(root .. "/gradlew") == 1 and "./gradlew" or "gradle"
                                vim.cmd("term " .. cmd .. " bootRun")
                            else
                                vim.notify("No se detectó Maven ni Gradle", vim.log.levels.WARN)
                            end
                        end, vim.tbl_extend("force", kopts, { desc = "Java: Run Spring Boot App" }))

                        -- Build project
                        keymap("n", "<leader>jb", function()
                            local root = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" })
                            if not root then
                                vim.notify("No se encontró un proyecto Java/Kotlin", vim.log.levels.WARN)
                                return
                            end

                            local build_tool = nil
                            if vim.fn.filereadable(root .. "/mvnw") == 1 then
                                build_tool = "maven"
                            elseif vim.fn.filereadable(root .. "/gradlew") == 1 then
                                build_tool = "gradle"
                            elseif vim.fn.filereadable(root .. "/pom.xml") == 1 then
                                build_tool = "maven"
                            elseif vim.fn.filereadable(root .. "/build.gradle") == 1 or vim.fn.filereadable(root .. "/build.gradle.kts") == 1 then
                                build_tool = "gradle"
                            end

                            if build_tool == "maven" then
                                local cmd = vim.fn.filereadable(root .. "/mvnw") == 1 and "./mvnw" or "mvn"
                                vim.cmd("term " .. cmd .. " clean compile")
                            elseif build_tool == "gradle" then
                                local cmd = vim.fn.filereadable(root .. "/gradlew") == 1 and "./gradlew" or "gradle"
                                vim.cmd("term " .. cmd .. " build")
                            else
                                vim.notify("No se detectó Maven ni Gradle", vim.log.levels.WARN)
                            end
                        end, vim.tbl_extend("force", kopts, { desc = "Java: Build Project" }))

                        -- Spring Boot dashboard / show beans
                        keymap("n", "<leader>js", function()
                            -- Intentar usar jdtls para listar beans si está disponible
                            local client = vim.lsp.get_clients({ bufnr = 0, name = "jdtls" })[1]
                            if client then
                                vim.notify("Spring Boot: Revisa el output de jdtls para beans registrados", vim.log.levels.INFO)
                                -- Mostrar información del proyecto Spring Boot
                                local root = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" })
                                if root then
                                    -- Buscar archivos de configuración de Spring Boot
                                    local props = vim.fs.find({ "application.properties", "application.yml", "application.yaml" }, {
                                        path = root,
                                        upward = false,
                                        limit = 10,
                                    })
                                    if #props > 0 then
                                        vim.ui.select(props, { prompt = "Spring Boot Config Files:" }, function(choice)
                                            if choice then
                                                vim.cmd("edit " .. choice)
                                            end
                                        end)
                                    else
                                        vim.notify("No se encontraron archivos de configuración Spring Boot", vim.log.levels.WARN)
                                    end
                                end
                            else
                                vim.notify("jdtls no está conectado", vim.log.levels.WARN)
                            end
                        end, vim.tbl_extend("force", kopts, { desc = "Java: Spring Boot Dashboard" }))

                        -- Run with profile
                        keymap("n", "<leader>jp", function()
                            vim.ui.input({ prompt = "Spring Profile: " }, function(profile)
                                if not profile or profile == "" then return end

                                local root = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" })
                                if not root then
                                    vim.notify("No se encontró un proyecto Java/Kotlin", vim.log.levels.WARN)
                                    return
                                end

                                local build_tool = nil
                                if vim.fn.filereadable(root .. "/mvnw") == 1 then
                                    build_tool = "maven"
                                elseif vim.fn.filereadable(root .. "/gradlew") == 1 then
                                    build_tool = "gradle"
                                elseif vim.fn.filereadable(root .. "/pom.xml") == 1 then
                                    build_tool = "maven"
                                elseif vim.fn.filereadable(root .. "/build.gradle") == 1 or vim.fn.filereadable(root .. "/build.gradle.kts") == 1 then
                                    build_tool = "gradle"
                                end

                                if build_tool == "maven" then
                                    local cmd = vim.fn.filereadable(root .. "/mvnw") == 1 and "./mvnw" or "mvn"
                                    vim.cmd("term " .. cmd .. " spring-boot:run -Dspring-boot.run.profiles=" .. profile)
                                elseif build_tool == "gradle" then
                                    local cmd = vim.fn.filereadable(root .. "/gradlew") == 1 and "./gradlew" or "gradle"
                                    vim.cmd("term " .. cmd .. " bootRun --args='--spring.profiles.active=" .. profile .. "'")
                                else
                                    vim.notify("No se detectó Maven ni Gradle", vim.log.levels.WARN)
                                end
                            end)
                        end, vim.tbl_extend("force", kopts, { desc = "Java: Run with Profile" }))

                        -- Implementations code lens
                        keymap("n", "<leader>ji", function()
                            local params = vim.lsp.util.make_position_params()
                            vim.lsp.buf.request(0, "textDocument/implementation", params, function(err, result, ctx, _)
                                if err then
                                    vim.notify("Error: " .. err.message, vim.log.levels.ERROR)
                                    return
                                end
                                if not result or vim.tbl_isempty(result) then
                                    vim.notify("No se encontraron implementaciones", vim.log.levels.INFO)
                                    return
                                end
                                vim.lsp.util.jump_to_location(result[1])
                            end)
                        end, vim.tbl_extend("force", kopts, { desc = "Java: Go to Implementations" }))

                        -- Setup DAP
                        pcall(function()
                            jdtls.setup_dap({ hotcodereplace = "auto" })
                            require("jdtls.dap").setup_dap_main_class_configs()
                        end)
                    end

                    -- Start or attach jdtls with error handling
                    local ok, err = pcall(jdtls.start_or_attach, opts)
                    if not ok then
                        vim.notify("Failed to start jdtls: " .. tostring(err), vim.log.levels.ERROR)
                    end
                end,
            })
        end,
    },

    -- ============================================================================
    -- kotlin-language-server - Kotlin Language Server
    -- ============================================================================
    {
        "neovim/nvim-lspconfig",
        optional = true,
        opts = function(_, opts)
            local lspconfig = require("lspconfig")

            -- Configurar kotlin-language-server
            lspconfig.kotlin_language_server.setup({
                cmd = { "kotlin-language-server" },
                filetypes = { "kotlin", "kts" },
                root_dir = function(fname)
                    return require("lspconfig.util").root_pattern(
                        "build.gradle",
                        "build.gradle.kts",
                        "pom.xml",
                        "settings.gradle",
                        "settings.gradle.kts",
                        ".git"
                    )(fname)
                end,
                settings = {
                    kotlin = {
                        compiler = {
                            jvm = {
                                target = "17",
                            },
                        },
                        externalSources = {
                            autoConvertToKotlin = true,
                            useKlsScheme = true,
                        },
                        debugging = {
                            enabled = true,
                        },
                        completion = {
                            snippets = {
                                enabled = true,
                            },
                        },
                    },
                },
                on_attach = function(client, bufnr)
                    local keymap = vim.keymap.set
                    local kopts = { noremap = true, silent = true, buffer = bufnr }

                    -- Kotlin specific keymaps
                    keymap("n", "<leader>ko", function()
                        vim.lsp.buf.code_action({
                            context = { only = { "source.organizeImports" } },
                            apply = true,
                        })
                    end, vim.tbl_extend("force", kopts, { desc = "Kotlin: Organize Imports" }))

                    keymap("n", "<leader>kk", function()
                        vim.ui.select({
                            "Organize Imports",
                            "Generate toString",
                            "Generate equals/hashCode",
                            "Generate hashCode",
                            "Generate equals",
                        }, { prompt = "Kotlin Actions:" }, function(choice)
                            if choice == "Organize Imports" then
                                vim.lsp.buf.code_action({
                                    context = { only = { "source.organizeImports" } },
                                    apply = true,
                                })
                            else
                                vim.lsp.buf.code_action()
                            end
                        end)
                    end, vim.tbl_extend("force", kopts, { desc = "Kotlin: Quick Actions" }))
                end,
                capabilities = (function()
                    local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
                    if ok then
                        return cmp_nvim_lsp.default_capabilities()
                    else
                        return vim.lsp.protocol.make_client_capabilities()
                    end
                end)(),
            })
        end,
    },

    -- ============================================================================
    -- NOTA: Spring Boot Tools NO es un servidor LSP válido en nvim-lspconfig
    -- ============================================================================
    -- El servidor "spring_boot_tools" no existe en nvim-lspconfig.
    -- La funcionalidad de Spring Boot ya está manejada por jdtls (Eclipse JDT.LS).
    --
    -- Si necesitas características específicas de Spring Boot (como navegación de beans,
    -- dashboard, etc.), se recomienda usar el plugin "spring-boot.nvim" por separado,
    -- pero NO a través de lspconfig.
    --
    -- Referencia: https://github.com/spring-projects-experimental/spring-boot.nvim
    -- ============================================================================


    -- ============================================================================
    -- nvim-dap - Debug Adapter Protocol
    -- ============================================================================
    {
        "mfussenegger/nvim-dap",
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
        config = function()
            -- Basic DAP configuration
            local dap = require("dap")

            -- Set up signs for breakpoints
            vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpoint", linehl = "", numhl = "" })
            vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DapBreakpointCondition", linehl = "", numhl = "" })
            vim.fn.sign_define("DapLogPoint", { text = "◆", texthl = "DapLogPoint", linehl = "", numhl = "" })
        end,
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
    -- Mason - Ensure Java/Kotlin tools are installed
    -- ============================================================================
    {
        "mason-org/mason.nvim",
        opts = {
            ensure_installed = {
                "jdtls",
                "java-debug-adapter",
                "java-test",
                "google-java-format",
                "kotlin-language-server",
                "ktfmt",
            },
        },
    },

    -- ============================================================================
    -- Treesitter - Java/Kotlin parsers
    -- ============================================================================
    {
        "nvim-treesitter/nvim-treesitter",
        opts = function(_, opts)
            if type(opts.ensure_installed) == "table" then
                vim.list_extend(opts.ensure_installed, { "java", "kotlin" })
            end
        end,
    },

    -- ============================================================================
    -- Conform - Java/Kotlin formatting
    -- ============================================================================
    {
        "stevearc/conform.nvim",
        opts = {
            formatters_by_ft = {
                java = { "google-java-format" },
                kotlin = { "ktfmt" },
            },
            formatters = {
                ["google-java-format"] = {
                    prepend_args = { "--aosp" }, -- Android style (4 spaces indent)
                },
                ["ktfmt"] = {
                    prepend_args = { "--kotlinlang-style" },
                },
            },
        },
    },

    -- ============================================================================
    -- Which-key - Java/Kotlin keymaps groups
    -- ============================================================================
    {
        "folke/which-key.nvim",
        opts = function(_, opts)
            local wk = require("which-key")
            wk.add({
                { "<leader>j", group = "Java/Spring Boot" },
                { "<leader>jo", desc = "Java: Organize Imports" },
                { "<leader>jc", desc = "Java: Extract Constant" },
                { "<leader>jv", desc = "Java: Extract Variable" },
                { "<leader>jm", desc = "Java: Extract Method" },
                { "<leader>jt", desc = "Java: Test Class" },
                { "<leader>jn", desc = "Java: Test Nearest" },
                { "<leader>jd", desc = "Java: Debug Class" },
                { "<leader>jg", desc = "Java: Generate Code" },
                { "<leader>jh", desc = "Java: Hot Code Replace" },
                { "<leader>jr", desc = "Java: Run Spring Boot App" },
                { "<leader>jb", desc = "Java: Build Project" },
                { "<leader>js", desc = "Java: Spring Boot Dashboard" },
                { "<leader>jp", desc = "Java: Run with Profile" },
                { "<leader>ji", desc = "Java: Go to Implementations" },
                { "<leader>k",  group = "Kotlin" },
                { "<leader>ko", desc = "Kotlin: Organize Imports" },
                { "<leader>kk", desc = "Kotlin: Quick Actions" },
                { "<leader>d",  group = "Debug" },
            })
        end,
    },
}
