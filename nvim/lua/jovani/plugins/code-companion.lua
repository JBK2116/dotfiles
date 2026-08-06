-- Configures CodeCompanion, the in-editor AI assistant. Wires up DeepSeek
-- V4 adapters (V4-Pro Premium Reasoner for complex chat, V4-Flash Efficient
-- Chat for inline/cmd/background) and Brave Search via MCP, defines keymaps
-- for chat, inline edits, the action palette, and CLI-driven workflows, plus
-- a custom prompt library and auto-generated chat titles.
local spec = {
  "olimorris/codecompanion.nvim",

  -- Load only when an AI keymap is used.
  keys = {
    -- Force Delete Chat Buffer
    {
      "<leader>aD",
      function()
        local chat = require("codecompanion").last_chat()
        if chat then
          chat:close()
        end
      end,
      desc = "AI Delete current chat",
    },

    -- Reopen the last used chat
    {
      "<leader>ar",
      "<cmd>CodeCompanionChat Toggle<cr>",
      desc = "AI Reopen last chat",
    },

    -- Pick any existing chat
    {
      "<leader>af",
      function()
        local all = require("codecompanion").buf_get_chat()
        if not all or #all == 0 then
          vim.notify("No chats open", vim.log.levels.INFO)
          return
        end
        local items = {}
        for _, entry in ipairs(all) do
          local label = entry.name
          if entry.title and entry.title ~= "" then
            label = label .. ": " .. entry.title
          end
          table.insert(items, { label = label, chat = entry.chat })
        end
        vim.ui.select(items, {
          prompt = "Select chat:",
          format_item = function(item)
            return item.label
          end,
        }, function(choice)
          if choice then
            choice.chat.ui:open()
          end
        end)
      end,
      desc = "AI Find chat",
    },

    -- New Chat with Reasoner (V4-Pro)
    {
      "<leader>as",
      function()
        require("codecompanion").chat({
          adapter = "reasoner",
        })
      end,
      mode = { "n", "v" },
      desc = "AI New chat (Reasoner)",
    },

    -- New Chat with Chat (V4-Flash)
    {
      "<leader>ah",
      function()
        require("codecompanion").chat({
          adapter = "chat",
        })
      end,
      desc = "AI New chat (Chat)",
    },

    -- New Chat with Web Search (V4-Flash + Brave Search MCP)
    {
      "<leader>aw",
      function()
        require("codecompanion").chat({
          adapter = "web_search",
        })
      end,
      desc = "AI Web search",
    },

    -- Add visual selection to current chat
    {
      "<leader>aA",
      "<cmd>CodeCompanionChat Add<cr>",
      mode = "v",
      desc = "AI Add selection to chat",
    },

    -- Inline In Editor
    {
      "<leader>ai",
      function()
        local mode = vim.api.nvim_get_mode().mode
        vim.ui.input({ prompt = "CodeCompanion: " }, function(input)
          if input then
            -- Bypass the :CodeCompanion command so we can force a
            -- placement, preventing the LLM from choosing "chat" or
            -- "new" and opening a side buffer.
            local ctx = require("codecompanion.utils.context").get(0)
            local placement = mode:lower() == "v" and "replace" or "add"
            local inline = require("codecompanion.interactions.inline").new({
              buffer_context = ctx,
              placement = placement,
            })
            if inline then
              inline:prompt(input)
            end
          end
        end)
      end,
      mode = { "n", "v" },
      desc = "AI Inline edit",
    },

    -- Action palette In Editor
    {
      "<leader>aa",
      "<cmd>CodeCompanionActions<cr>",
      mode = { "n", "v" },
      desc = "AI Actions",
    },
  },

  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },

  opts = {
    rules = {
      default = {
        description = "Common rule files",
        files = { "AGENTS.md", "CLAUDE.md" },
        is_preset = true,
      },
      opts = {
        chat = {
          autoload = "default",
          enabled = true,
        },
      },
    },

    prompt_library = {
      ["Explain Code"] = {
        interaction = "chat",
        adapter = "reasoner",
        description = "Explain the selected code in detail",
        prompts = {
          {
            role = "system",
            content = "You are an expert programmer who excels at explaining code clearly. Provide thorough explanations covering what the code does, how it works, and any notable patterns or potential issues.",
          },
          {
            role = "user",
            content = function(context)
              local text = require("codecompanion.helpers.code").get_code(context.start_line, context.end_line)
              return "Explain this code:\n\n```" .. context.filetype .. "\n" .. text .. "\n```"
            end,
          },
        },
      },
      ["Write Tests"] = {
        interaction = "chat",
        adapter = "reasoner",
        description = "Generate comprehensive unit tests for the selected code",
        prompts = {
          {
            role = "system",
            content = "You are an expert at writing tests. Generate comprehensive, well-structured unit tests covering normal cases, edge cases, and error conditions. Use the appropriate test framework for the language.",
          },
          {
            role = "user",
            content = function(context)
              local text = require("codecompanion.helpers.code").get_code(context.start_line, context.end_line)
              return "Write unit tests for this code:\n\n```" .. context.filetype .. "\n" .. text .. "\n```"
            end,
          },
        },
      },
      ["Review Code"] = {
        interaction = "chat",
        adapter = "reasoner",
        description = "Review the selected code for bugs, issues, and improvements",
        prompts = {
          {
            role = "system",
            content = "You are an expert code reviewer. Analyze the code for bugs, security issues, performance problems, and adherence to best practices. Provide specific, actionable feedback.",
          },
          {
            role = "user",
            content = function(context)
              local text = require("codecompanion.helpers.code").get_code(context.start_line, context.end_line)
              return "Review this code:\n\n```" .. context.filetype .. "\n" .. text .. "\n```"
            end,
          },
        },
      },
      ["Optimize Code"] = {
        interaction = "inline",
        adapter = "chat",
        description = "Optimize the selected code inline",
        prompts = {
          {
            role = "system",
            content = "You are an expert at code optimization. Rewrite the code for performance, readability, and maintainability. Output only the optimized code, no explanations.",
          },
          {
            role = "user",
            content = "Optimize this code:\n\n#{buffer}",
          },
        },
      },
      ["Fix LSP Diagnostics"] = {
        interaction = "inline",
        adapter = "chat",
        description = "Fix LSP diagnostics inline",
        prompts = {
          {
            role = "system",
            content = "You are an expert at fixing code issues. Fix ALL LSP diagnostics shown below. Output the complete corrected file — no explanations, no markdown fences, just the fixed code.",
          },
          {
            role = "user",
            content = function(_context)
              local filetype = vim.bo.filetype
              local buf_content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
              local diagnostics = vim.diagnostic.get(0)
              local diag_lines = {}
              for _, d in ipairs(diagnostics) do
                local sev = ({ [1] = "ERROR", [2] = "WARNING", [3] = "INFO", [4] = "HINT" })[d.severity] or "?"
                table.insert(
                  diag_lines,
                  string.format("Line %d [%s]: %s (source: %s)", d.lnum + 1, sev, d.message, d.source or "unknown")
                )
              end
              local header = #diagnostics > 0
                  and string.format("%d diagnostic(s) found:\n%s\n", #diagnostics, table.concat(diag_lines, "\n"))
                or "No diagnostics found in this file.\n"
              return "Fix the following LSP diagnostics in this "
                .. filetype
                .. " file:\n\n"
                .. header
                .. "```"
                .. filetype
                .. "\n"
                .. buf_content
                .. "\n```"
            end,
          },
        },
      },
      ["Review Git Changes"] = {
        interaction = "chat",
        adapter = "reasoner",
        description = "Review unstaged git changes",
        prompts = {
          {
            role = "system",
            content = "You are an expert code reviewer. Review the git diff and provide feedback on the changes, checking for bugs, security issues, and best practices.",
          },
          {
            role = "user",
            content = function()
              local handle = io.popen("git diff 2>/dev/null")
              if not handle then
                return "No git diff available"
              end
              local diff = handle:read("*a")
              handle:close()
              if diff == "" then
                return "No unstaged changes found"
              end
              return "Review these git changes:\n\n```diff\n" .. diff .. "\n```"
            end,
          },
        },
      },
      ["Add Docstrings"] = {
        interaction = "inline",
        adapter = "chat",
        description = "Add docstrings to the selected function",
        opts = {
          placement = "replace",
        },
        prompts = {
          {
            role = "system",
            content = "You are an expert at writing clear and comprehensive documentation. Add or improve docstrings using the appropriate format (JSDoc, Python docstrings, LuaDoc, etc.). Follow the existing conventions.",
          },
          {
            role = "user",
            content = "Add docstrings to the following code:\n\n#{buffer}",
          },
        },
      },
    },

    adapters = {
      http = {
        -- Premium Reasoner — V4-Pro (1.6T params, thinking enabled, max effort)
        reasoner = function()
          return require("codecompanion.adapters").extend("deepseek", {
            name = "reasoner",
            schema = {
              model = {
                default = "deepseek-v4-pro",
              },
            },
            env = {
              api_key = "DEEPSEEK_API_KEY",
            },
          })
        end,

        -- Efficient Chat — V4-Flash (284B params, thinking disabled for speed)
        chat = function()
          return require("codecompanion.adapters").extend("deepseek", {
            name = "chat",
            schema = {
              model = {
                default = "deepseek-v4-flash",
              },
              ["thinking.type"] = {
                default = "disabled",
              },
            },
            env = {
              api_key = "DEEPSEEK_API_KEY",
            },
          })
        end,

        -- Fast Web Search — V4-Flash (same model, dedicated adapter for MCP Brave Search)
        web_search = function()
          return require("codecompanion.adapters").extend("deepseek", {
            name = "web_search",
            schema = {
              model = {
                default = "deepseek-v4-flash",
              },
              ["thinking.type"] = {
                default = "disabled",
              },
            },
            env = {
              api_key = "DEEPSEEK_API_KEY",
            },
          })
        end,
      },
    },

    mcp = {
      servers = {
        ["brave_search"] = {
          cmd = {
            "npx",
            "-y",
            "@modelcontextprotocol/server-brave-search",
          },
          env = {
            BRAVE_API_KEY = "BRAVE_API_KEY",
          },
        },
      },
      opts = {
        default_servers = { "brave_search" },
      },
    },

    interactions = {
      -- Sidebar In Editor
      chat = {
        adapter = "reasoner",
      },

      -- Inline In Editor — uses chat adapter (V4-Flash, thinking disabled for speed)
      inline = {
        adapter = "chat",
      },

      -- Command-line In Editor
      cmd = {
        adapter = "chat",
      },

      background = {
        adapter = "chat",
        chat = {
          callbacks = {
            ["on_ready"] = {
              actions = { "interactions.background.builtin.chat_make_title" },
              enabled = true,
            },
          },
          opts = {
            enabled = true,
          },
        },
        gates = {
          judge = {
            enabled = false,
          },
        },
      },
    },

    display = {
      diff = {
        enabled = false,
      },
      action_palette = {
        provider = "snacks",
      },

      chat = {
        fold_reasoning = false,
        show_reasoning = true,
        show_token_count = true,
        show_header_separator = false,

        token_count = function(tokens, _adapter)
          return " " .. tokens .. " tokens"
        end,
      },
    },
  },
}

return spec
