-- Full Java development environment via nvim-java.
-- Orchestrates JDTLS (LSP), lombok, java-debug-adapter (DAP),
-- java-test (JUnit runner), and Spring Boot tools (STS4).
-- All components are auto-installed via Mason's nvim-java registry.
-- Dependencies on nvim-dap and nvim-lspconfig are satisfied by
-- the separate dap.lua and lsp.lua plugin specs.
return {
  "nvim-java/nvim-java",
  ft = "java",
  dependencies = {
    "nvim-java/lua-async-await",
    "nvim-java/nvim-java-core",
    "nvim-java/nvim-java-test",
    "nvim-java/nvim-java-dap",
    "MunifTanjim/nui.nvim",
    "neovim/nvim-lspconfig",
    "mfussenegger/nvim-dap",
  },
  ---@type java.Config
  opts = {
    -- JDTLS (Eclipse Java Language Server)
    jdtls = {
      version = "1.43.0",
      auto_install = true,
    },

    -- Lombok annotation processor
    lombok = {
      enable = true,
      version = "1.18.40",
      auto_install = true,
    },

    -- Java Test runner (JUnit, via Eclipse test framework)
    java_test = {
      enable = true,
      version = "0.40.1",
      auto_install = true,
    },

    -- Debug Adapter for Java (DAP)
    java_debug_adapter = {
      enable = true,
      version = "0.58.2",
      auto_install = true,
    },

    -- Spring Boot Tools (STS4 language server extension)
    spring_boot_tools = {
      enable = true,
      version = "1.55.1",
      auto_install = true,
    },

    -- JDK — use the system JDK 25 we already installed
    jdk = {
      auto_install = false,
    -- NOTE: Ensure that the path here matches the systems installed path
      path = "/usr/lib/jvm/java-25-openjdk",
    },

    -- Startup checks
    checks = {
      nvim_version = true,
      nvim_jdtls_conflict = true,
    },

    -- DAP notifications
    notifications = {
      dap = true,
    },

    -- JDTLS settings exposed via nvim-lspconfig
    settings = {
      java = {
        -- Auto-organize imports on save (handled by JDTLS save actions)
        saveActions = {
          organizeImports = true,
        },
        -- Enable signature help
        signatureHelp = {
          enabled = true,
        },
        -- Code generation preferences
        codeGeneration = {
          toString = {
            template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
          },
          useBlocks = false,
        },
        -- Completion preferences
        completion = {
          favoriteStaticMembers = {
            "org.junit.Assert.*",
          },
          importOrder = { "#", "java", "javax", "org", "com" },
        },
        -- Show inlay hints for parameter names
        inlayHints = {
          parameterNames = {
            enabled = "all",
          },
        },
        -- Maven/Gradle import
        import = {
          gradle = {
            enabled = true,
          },
          maven = {
            enabled = true,
          },
        },
      },
    },
  },

  -- Keymaps added after nvim-java is fully initialized
  config = function(_, opts)
    require("java").setup(opts)

    -- Java-specific keymaps (only active in java buffers)
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "java",
      callback = function()
        local map = vim.keymap.set
        local buf = { buffer = true, silent = true }

        -- Running and debugging
        map("n", "<leader>jr", "<cmd>JavaRunner<CR>", vim.tbl_extend("force", buf, { desc = "Run main class" }))
        map("n", "<leader>jd", "<cmd>JavaRunnerDebug<CR>", vim.tbl_extend("force", buf, { desc = "Debug main class" }))
        map("n", "<leader>jR", "<cmd>JavaRunnerRun<CR>", vim.tbl_extend("force", buf, { desc = "Run without debug" }))

        -- Testing
        map("n", "<leader>jtc", "<cmd>JavaTestClass<CR>", vim.tbl_extend("force", buf, { desc = "Test current class" }))
        map("n", "<leader>jtm", "<cmd>JavaTestMethod<CR>", vim.tbl_extend("force", buf, { desc = "Test nearest method" }))
        map("n", "<leader>jtd", "<cmd>JavaTestDebugClass<CR>", vim.tbl_extend("force", buf, { desc = "Debug test class" }))
        map("n", "<leader>jtn", "<cmd>JavaTestDebugMethod<CR>", vim.tbl_extend("force", buf, { desc = "Debug test method" }))
        map("n", "<leader>jtr", "<cmd>JavaTestRepeat<CR>", vim.tbl_extend("force", buf, { desc = "Repeat last test" }))

        -- Profile management
        map("n", "<leader>jpl", "<cmd>JavaProfileList<CR>", vim.tbl_extend("force", buf, { desc = "List run profiles" }))
        map("n", "<leader>jps", "<cmd>JavaProfileSwitch<CR>", vim.tbl_extend("force", buf, { desc = "Switch run profile" }))

        -- JDTLS code actions that are Java-specific
        map("n", "<leader>jo", "<cmd>JavaOrganizeImports<CR>", vim.tbl_extend("force", buf, { desc = "Organize imports" }))
      end,
    })

    vim.api.nvim_create_autocmd("User", {
      pattern = "JavaUpdateServerConfig",
      callback = function()
        vim.notify("JDTLS configuration updated", vim.log.levels.INFO, { title = "Java" })
      end,
    })
  end,
}
