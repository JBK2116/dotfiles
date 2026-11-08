-- Configures nvim-lspconfig and the per-server LSP setup. Wires blink.cmp
-- capabilities into every server, sets project-scoped root detection and
-- tuned settings for each language server (ty, lua_ls, svelte, clangd,
-- gopls, ruff, jsonls, yamlls, ...), and enables them.
return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    { "antosha417/nvim-lsp-file-operations", config = true },
    { "folke/lazydev.nvim", opts = {} },
    "b0o/SchemaStore.nvim",
  },
  config = function()
    local capabilities = require("blink.cmp").get_lsp_capabilities({
      textDocument = {
        completion = {
          completionItem = { snippetSupport = false },
        },
      },
    })

    -- Global: debounce all LSP requests slightly, reduces hammering on keystroke
    vim.lsp.config("*", {
      capabilities = capabilities,
      flags = { debounce_text_changes = 150 },
    })

    -- Inlay hints (gopls, vtsls, lua_ls, ...) on attach
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client:supports_method("textDocument/inlayHint") then
          vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
        end
      end,
    })

    -- Tailwind: only in tailwind projects
    vim.lsp.config.tailwindcss = {
      root_dir = function(bufnr, on_dir)
        local root = vim.fs.root(bufnr, {
          "tailwind.config.js",
          "tailwind.config.cjs",
          "tailwind.config.mjs",
          "tailwind.config.ts",
        })
        if root then
          on_dir(root)
        end
      end,
    }

    -- GraphQL: only in graphql projects
    vim.lsp.config.graphql = {
      root_dir = function(bufnr, on_dir)
        local root = vim.fs.root(bufnr, {
          ".graphqlrc",
          ".graphqlrc.json",
          ".graphqlrc.yml",
          ".graphqlrc.yaml",
          "graphql.config.js",
        })
        if root then
          on_dir(root)
        end
      end,
    }

    -- python: ty owns types, hover, and navigation.
    -- Ruff owns linting/formatting/import sorting.
    vim.lsp.config("ty", {
      settings = {
        ty = {
          -- inline settings override ty.toml / pyproject.toml
          configuration = {
            rules = {
              ["possibly-unresolved-reference"] = "warn",
            },
          },
          inlayHints = { variableTypes = true }, -- default
        },
      },
    })

    -- Pytest language server for testing functionality
    vim.lsp.config("pytest_language_server", {
      cmd = { "pytest-language-server" },
      filetypes = { "python" },
      root_markers = { "pytest.ini", "pyproject.toml", "setup.py", "setup.cfg", ".git" },
    })

    -- bash: scripting
    vim.lsp.config.bashls = {}

    -- lua_ls: minimal, no workspace spam
    vim.lsp.config.lua_ls = {
      settings = {
        Lua = {
          diagnostics = { globals = { "vim" } },
          workspace = { checkThirdParty = false },
          telemetry = { enable = false },
          hint = { enable = true },
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
    -- For .ts files importing .svelte files: add typescript-svelte-plugin to the project's
    -- devDependencies and to "compilerOptions.plugins" in tsconfig.json.
    vim.lsp.config.vtsls = {
      settings = {
        typescript = {
          inlayHints = {
            parameterNames = { enabled = "literals" },
            variableTypes = { enabled = false },
            functionLikeReturnTypes = { enabled = true },
          },
        },
      },
    }

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

    -- jsonls: JSON with schema validation/completion from SchemaStore
    vim.lsp.config.jsonls = {
      settings = {
        json = {
          schemas = require("schemastore").json.schemas(),
          validate = { enable = true },
        },
      },
    }

    -- yamlls: YAML with SchemaStore schemas (CI configs, k8s, compose, ...)
    -- schemaStore is disabled in favor of SchemaStore.nvim's schema list
    vim.lsp.config.yamlls = {
      settings = {
        yaml = {
          schemaStore = { enable = false, url = "" },
          schemas = require("schemastore").yaml.schemas(),
          keyOrdering = false,
        },
      },
    }

    -- taplo: TOML (pyproject.toml, Cargo.toml, ...)
    vim.lsp.config.taplo = {}

    -- html + emmet
    vim.lsp.config.html = {}
    vim.lsp.config.emmet_language_server = {}

    -- typos-lsp: Autocorrect in neovim
    vim.lsp.config("typos_lsp", {
      -- must be installed in path
      cmd = { "typos-lsp" },
      -- log level
      cmd_env = { RUST_LOG = "typos_lsp=error" },
      -- init startup options
      init_options = {
        -- How typos are rendered in the editor, can be one of an Error, Warning, Info or Hint.
        -- Defaults to Info.
        diagnosticSeverity = "Info",
      },
    })

    -- Extra lsp configurations (inheriting global settings)
    vim.lsp.config.cssls = {}
    vim.lsp.config.prismals = {}
    vim.lsp.config.eslint = {}

    -- Ruff configuration for python linting
    vim.lsp.config.ruff = {
      on_attach = function(client)
        client.server_capabilities.hoverProvider = false -- ty owns hover
      end,
      init_options = {
        settings = {
          fixAll = true,
          organizeImports = true,
          showSyntaxErrors = false, -- ty reports syntax errors
        },
      },
    }

    vim.lsp.config.lemminx = {}

    -- Ensure docker-compose files get the correct filetype for the compose LSP
    vim.filetype.add({
      pattern = {
        [".*docker%-compose.*%.ya?ml"] = "yaml.docker-compose",
        [".*compose.*%.ya?ml"] = "yaml.docker-compose",
      },
    })

    -- Tells Neovim to actually activate these servers
    vim.lsp.enable({
      "tailwindcss",
      "graphql",
      "ty",
      "pytest_language_server",
      "lua_ls",
      "svelte",
      "clangd",
      "gopls",
      "cssls",
      "html",
      "emmet_language_server",
      "prismals",
      "eslint",
      "ruff",
      "vtsls",
      "dockerls",
      "docker_compose_language_service",
      "jsonls",
      "yamlls",
      "taplo",
      "typos_lsp",
      "bashls",
      "lemminx",
    })
  end,
}
