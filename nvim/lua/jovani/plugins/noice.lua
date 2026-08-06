-- Configures noice.nvim, which replaces Neovim's UI for the command line,
-- messages, and popups. Routes the cmdline into a floating popup, sends
-- messages through nvim-notify, styles LSP hover/signature/progress, and
-- filters out noisy "written" and search-count messages.
return {
  "folke/noice.nvim",
  event = "VeryLazy",
  dependencies = {
    "MunifTanjim/nui.nvim",
    "rcarriga/nvim-notify",
  },
  opts = {
    -- Cmdline
    cmdline = {
      enabled = true,
      view = "cmdline_popup",
      format = {
        cmdline = { pattern = "^:", icon = "", lang = "vim" },
        search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
        search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
        filter = { pattern = "^:%s*!", icon = "", lang = "bash" },
        lua = {
          pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" },
          icon = "",
          lang = "lua",
        },
        help = { pattern = "^:%s*he?l?p?%s+", icon = "󰋖" },
        input = { view = "cmdline_input", icon = "󰥻 " },
      },
    },

    -- Messages
    messages = {
      enabled = true,
      view = "notify",
      view_error = "notify",
      view_warn = "notify",
      view_history = "messages",
      view_search = "virtualtext",
    },

    -- LSP
    lsp = {
      progress = {
        enabled = true,
        view = "mini",
      },
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        ["cmp.entry.get_documentation"] = true,
      },
      hover = {
        enabled = true,
        silent = true, -- no message if hover unavailable
      },
      signature = {
        enabled = true,
        auto_open = {
          enabled = true,
          trigger = true,
          luasnip = true,
          throttle = 50,
        },
      },
      documentation = {
        view = "hover",
        opts = {
          lang = "markdown",
          replace = true,
          render = "markdown",
          format = { "{message}" },
          win_options = { concealcursor = "n", conceallevel = 3 },
        },
      },
    },

    -- Presets
    presets = {
      bottom_search = true,
      command_palette = true,
      long_message_to_split = true,
      lsp_doc_border = true,
    },

    -- Routes
    routes = {
      -- swallow "written" file messages
      {
        filter = { event = "msg_show", find = "%d+L, %d+B" },
        opts = { skip = true },
      },
      -- swallow search count virtultext noise
      {
        filter = { event = "msg_show", kind = "search_count" },
        opts = { skip = true },
      },
      -- redirect long messages to a split
      {
        filter = { event = "msg_show", min_height = 10 },
        view = "split",
      },
      -- gopls emits this when diffview/fugitive opens a Go buffer with
      -- a non-file:// URI. Skip both notify and lsp event variants.
      {
        filter = {
          event = "notify",
          find = "DocumentURI scheme is not 'file'",
        },
        opts = { skip = true },
      },
      {
        filter = {
          event = "lsp",
          kind = "",
          find = "DocumentURI scheme is not 'file'",
        },
        opts = { skip = true },
      },
    },

    -- Views (overrides)
    views = {
      cmdline_popup = {
        position = { row = "40%", col = "50%" },
        size = { width = 60, height = "auto" },
        border = { style = "rounded" },
        win_options = {
          winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
        },
      },
      hover = {
        border = { style = "none" },
        position = { row = 2 },
        win_options = {
          winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
          wrap = true,
          linebreak = true,
        },
      },
      mini = {
        win_options = { winblend = 0 },
      },
    },
  },
}
