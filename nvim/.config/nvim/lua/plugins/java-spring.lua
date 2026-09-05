-- Spring Boot support, layered on top of LazyVim's lang.java extra
-- (nvim-jdtls + mason-installed jdtls, enabled via lazyvim.json).
return {
  -- Ensure the Spring Boot LS/jdtls-extension jars are installed by Mason.
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "vscode-spring-boot-tools" })
    end,
  },

  -- Bean/endpoint navigation, application.properties/yml completion and
  -- code actions, backed by the Spring Boot language server.
  {
    "JavaHello/spring-boot.nvim",
    ft = { "java", "yaml", "jproperties" },
    dependencies = { "mfussenegger/nvim-jdtls" },
    opts = {},
  },

  -- Feed the Spring Boot jdtls extension jars into the jdtls bundles that
  -- LazyVim's java extra builds (see opts.jdtls in lazyvim's lang/java.lua).
  {
    "mfussenegger/nvim-jdtls",
    optional = true,
    opts = function(_, opts)
      opts.jdtls = function(config)
        local ok, spring_boot = pcall(require, "spring_boot")
        if ok then
          config.init_options = config.init_options or {}
          config.init_options.bundles = config.init_options.bundles or {}
          vim.list_extend(config.init_options.bundles, spring_boot.java_extensions())
        end
        return config
      end
      return opts
    end,
  },

  -- Run/generate helpers: <leader>Jr run, <leader>Jc/Ji/Je generate class/interface/enum.
  {
    "elmcgill/springboot-nvim",
    ft = "java",
    dependencies = { "neovim/nvim-lspconfig", "mfussenegger/nvim-jdtls" },
    config = function()
      local springboot_nvim = require("springboot-nvim")
      vim.keymap.set("n", "<leader>Jr", springboot_nvim.boot_run, { desc = "Spring Boot Run" })
      vim.keymap.set("n", "<leader>Jc", springboot_nvim.generate_class, { desc = "Create Class" })
      vim.keymap.set("n", "<leader>Ji", springboot_nvim.generate_interface, { desc = "Create Interface" })
      vim.keymap.set("n", "<leader>Je", springboot_nvim.generate_enum, { desc = "Create Enum" })
      springboot_nvim.setup({})
    end,
  },
}
