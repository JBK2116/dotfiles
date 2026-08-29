-- Configures Mason and its bridges to auto-install tooling. mason-lspconfig
-- ensures the LSP servers used in lsp.lua are installed, and
-- mason-tool-installer ensures the formatters/linters (prettier, stylua,
-- clang-format, goimports, golangci-lint) are present.
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
        "checkmake", -- Makefile
      },
    },
    dependencies = { "williamboman/mason.nvim" },
  },
}
