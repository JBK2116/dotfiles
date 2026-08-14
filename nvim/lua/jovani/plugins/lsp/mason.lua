-- Configures Mason and its bridges to auto-install tooling. mason-lspconfig
-- ensures the LSP servers used in lsp.lua are installed, and
-- mason-tool-installer ensures the formatters/linters (prettier, stylua,
-- clang-format, goimports, golangci-lint) are present.
-- mason-nvim-dap does the same for DAP debug adapters.
return {
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      ensure_installed = {
        "tailwindcss", -- CSS
        "graphql", -- GraphQL
        "ty", -- Python
        "lua_ls", -- HTML
        "svelte", -- Svelte
        "clangd", -- C/C++
        "gopls", -- Golang
        "cssls", -- CSS
        "prismals", -- Build
        "eslint", -- JavaScript
        "ruff", -- Python
        "vtsls", -- TypeScript
        "dockerls", -- Dockerfile
        "docker_compose_language_service", -- docker-compose
        "typos_lsp", -- Spelling
      },
      automatic_enable = false,
    },
    dependencies = {
      {
        "williamboman/mason.nvim",
        opts = {
          registries = {
            "github:mason-org/mason-registry",
          },
          ui = {
            icons = {
              package_installed = " ",
              package_pending = " ",
              package_uninstalled = " ",
            },
          },
        },
      },
      "neovim/nvim-lspconfig",
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = {
        "prettier", -- JavaScript/TypeScript
        "stylua", -- CSS
        "clang-format", -- C/C++
        "goimports", -- Golang
        "golangci-lint", -- Golang
        "hadolint", -- Dockerfile linter
        "debugpy", -- Python DAP (nvim-dap-python)
        "delve", -- Go DAP (nvim-dap-go)
      },
    },
    dependencies = { "williamboman/mason.nvim" },
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    opts = {
      ensure_installed = {
        "js-debug-adapter", -- JavaScript/TypeScript (vscode-js-debug)
      },
    },
    dependencies = { "williamboman/mason.nvim", "mfussenegger/nvim-dap" },
  },
}
