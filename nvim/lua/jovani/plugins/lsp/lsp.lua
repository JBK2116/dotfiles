-- Configures nvim-lspconfig and the per-server LSP setup. Wires blink.cmp
-- capabilities into every server, sets project-scoped root patterns and
-- tuned settings for each language server (ty, lua_ls, svelte, clangd,
-- gopls, ruff, ...), and enables them.
return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    { "antosha417/nvim-lsp-file-operations", config = true },
    { "folke/lazydev.nvim", opts = {} },
  },
  config = function()
    -- Forces the community default launch structures to merge into the native runtime path
    local lspconfig = require("lspconfig")
    local capabilities = require("blink.cmp").get_lsp_capabilities({
      textDocument = {
        completion = {
          completionItem = { snippetSupport = false },
        },
      },
    })
    local lsputil = require("lspconfig.util")

    -- Global: debounce all LSP requests slightly, reduces hammering on keystroke
    vim.lsp.config("*", {
      capabilities = capabilities,
      flags = { debounce_text_changes = 150 },
    })

    -- Tailwind: only in tailwind projects
    vim.lsp.config.tailwindcss = {
      root_dir = lsputil.root_pattern("tailwind.config.js", "tailwind.config.ts"),
    }

    -- GraphQL: only in graphql projects
    vim.lsp.config.graphql = {
      root_dir = lsputil.root_pattern(".graphqlrc", ".graphqlrc.json", "graphql.config.js"),
    }

    -- python: fastest lsp (Ty)
    vim.lsp.config.ty = {}

    -- lua_ls: minimal, no workspace spam
    vim.lsp.config.lua_ls = {
      settings = {
        Lua = {
          diagnostics = { globals = { "vim" } },
          workspace = { checkThirdParty = false },
          telemetry = { enable = false },
        },
      },
    }

    -- Svelte LSP gets its own capabilities copy with dynamic file watching disabled
    -- the watcher causes Neovim to flood the svelte process with fs events on large projects
    local svelte_capabilities = vim.deepcopy(capabilities)
    if svelte_capabilities.workspace and svelte_capabilities.workspace.didChangeWatchedFiles then
      svelte_capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = false
    end

    vim.lsp.config.svelte = {
      capabilities = svelte_capabilities,
      filetypes = { "svelte" },
      on_attach = function(client)
        client.server_capabilities.colorProvider = nil
        client.server_capabilities.semanticTokensProvider = nil
        client.server_capabilities.foldingRangeProvider = nil
        client.server_capabilities.codeLensProvider = nil
      end,
      init_options = {
        -- Use svelte integrated lsp
        typescript = {
          tsdk = vim.fn.stdpath("data") .. "/mason/packages/svelte-language-server/node_modules/typescript/lib",
        },
      },
      settings = {
        svelte = {
          plugin = {
            css = { diagnostics = { enable = false } }, -- Noisy and handled by other tooling
            html = { completions = { enable = true } },
          },
        },
      },
    }

    -- vtsls: native TS/JS lsp for non-svelte projects
    vim.lsp.config.vtsls = {}

    -- clangd: keep indexing, skip clang-tidy
    vim.lsp.config.clangd = {
      cmd = {
        "clangd",
        "--background-index",
        "--clang-tidy=false",
        "--completion-style=bundled",
        "--header-insertion=never",
        "--pch-storage=memory",
        "-j=4",
      },
    }

    -- gopls
    vim.lsp.config.gopls = {
      settings = {
        gopls = {
          staticcheck = true,
          analyses = {
            unusedparams = true,
            shadow = true,
            nilness = true,
          },
          usePlaceholders = false,
          hints = {
            assignVariableTypes = true,
            parameterNames = true,
          },
        },
      },
    }

    -- dockerls: Dockerfile language server (same engine VS Code's Docker extension uses)
    vim.lsp.config.dockerls = {
      settings = {
        docker = {
          languageserver = {
            formatter = { ignoreMultilineInstructions = true },
          },
        },
      },
    }

    -- docker-compose: IntelliSense for compose files (uses yaml.docker-compose filetype)
    vim.lsp.config.docker_compose_language_service = {}

    -- typos-lsp: Autocorrect in neovim
    vim.lsp.config("typos_lsp", {
      -- must be installed in path
      cmd = { "typos-lsp" },
      -- log level
      cmd_env = { RUST_LOG = "typos_lsp=error" },
      -- init starutp options
      init_options = {
        -- How typos are rendered in the editor, can be one of an Error, Warning, Info or Hint.
        -- Defaults to Info.
        diagnosticSeverity = "Info",
      },
    })

    -- Extra lsp configurations (Now properly inheriting global settings)
    vim.lsp.config.cssls = {}
    vim.lsp.config.prismals = {}
    vim.lsp.config.eslint = {}
    vim.lsp.config.ruff = {
      settings = {
        ruff = {
          fixAll = true, -- Fix all auto-fixable violations
          organizeImports = true, -- Automatically sort/clean imports
          unsafeFixes = true, -- Include unsafe fixes (broader coverage)
        },
      },
    }

    -- Ensure docker-compose files get the correct filetype for the compose LSP
    vim.filetype.add({
      pattern = {
        [".*docker%-compose.*%.ya?ml"] = "yaml.docker-compose",
        [".*compose.*%.ya?ml"] = "yaml.docker-compose",
      },
    })

    -- Crucial step: Tells Neovim to actually activate and spin up these engines
    vim.lsp.enable({
      "tailwindcss",
      "graphql",
      "ty",
      "lua_ls",
      "svelte",
      "clangd",
      "gopls",
      "cssls",
      "prismals",
      "eslint",
      "ruff",
      "vtsls",
      "dockerls",
      "docker_compose_language_service",
      "typos_lsp",
    })
  end,
}
