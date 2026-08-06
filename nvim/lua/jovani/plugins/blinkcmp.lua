-- Configures blink.cmp, the autocompletion engine. Pulls suggestions from
-- LSP, snippets, file paths, and open buffers, with native Rust fuzzy matching,
-- signature help, documentation popups, and ghost text. Cmdline completion
-- (native + plugin commands) is handled by blink's internal defaults.
-- Defines the completion keymaps and tunes source priorities for IDE-like behavior.
---@module 'blink.cmp'
---@type blink.cmp.KeymapConfig
local keymap = {
  preset = "enter",
  ["<C-k>"] = { "select_prev", "fallback" },
  ["<C-j>"] = { "select_next", "fallback" },
  ["<C-s>"] = { "show_signature", "hide_signature", "fallback" },
  ["<C-b>"] = { "scroll_documentation_up", "fallback" },
  ["<C-f>"] = { "scroll_documentation_down", "fallback" },
  ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
  ["<C-e>"] = { "hide", "fallback" },
}

---@type blink.cmp.Config
local opts = {
  keymap = keymap,

  appearance = {
    nerd_font_variant = "mono",
    use_nvim_cmp_as_default = false,
  },

  -- Native fuzzy = faster, disable typo resistance for speed
  fuzzy = {
    implementation = "rust",
    frecency = {
      enabled = true,
      unsafe_no_lock = true,
    },
    use_proximity = true,
  },

  completion = {
    keyword = { range = "full" },

    trigger = {
      show_on_keyword = true,
      show_on_trigger_character = true,
      show_on_insert_on_trigger_character = true,
      show_on_accept_on_trigger_character = true,
    },

    accept = {
      auto_brackets = {
        enabled = true,
        default_brackets = { "(", ")" },
      },
    },

    list = {
      max_items = 20, -- 50 is wasteful, 20 is IDE-standard
      selection = {
        preselect = true,
        auto_insert = false,
      },
    },

    menu = {
      auto_show = true,
      max_height = 15,
      border = "rounded",
      scrollbar = true,
      draw = {
        treesitter = { "lsp" },
        columns = {
          { "kind_icon" },
          { "label", "label_description", gap = 1 },
          { "kind" },
          { "source_name" },
        },
      },
    },

    documentation = {
      auto_show = true,
      auto_show_delay_ms = 100,
      window = {
        border = "shadow",
        max_width = 80,
      },
    },

    ghost_text = { enabled = true },
  },

  signature = {
    enabled = true,
    window = { border = "rounded" },
  },

  sources = {
    default = { "lsp", "snippets", "path", "buffer" },
    providers = {
      snippets = {
        score_offset = 4,
        min_keyword_length = 1,
        max_items = 5,
      },
      lsp = {
        score_offset = 10,
        fallbacks = { "buffer" },
        async = true,
      },
      path = {
        score_offset = 3,
        opts = {
          trailing_slash = true,
          show_hidden_files_by_default = false,
        },
      },
      buffer = {
        score_offset = -5,
        min_keyword_length = 2,
        max_items = 10,
        opts = {
          get_bufnrs = function()
            return vim.tbl_filter(function(b)
              return vim.bo[b].buftype == ""
            end, vim.api.nvim_list_bufs())
          end,
        },
      },
    },
  },
}

return {
  "saghen/blink.cmp",
  event = { "InsertEnter", "CmdlineEnter" },
  version = "1.*",
  dependencies = {
    "rafamadriz/friendly-snippets",
  },
  opts = opts,
  opts_extend = { "sources.default" },
}
