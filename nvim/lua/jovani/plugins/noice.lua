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
  config = function(_, opts)
    require("noice").setup(opts)

    local function fence_indented(s, lang)
      local out, in_fence, in_code = {}, false, false
      for _, line in ipairs(vim.split(s, "\n", { plain = true })) do
        if line:match("^%s*```") then
          in_fence = not in_fence
          table.insert(out, line)
        elseif in_fence then
          table.insert(out, line)
        else
          local indented = line:match("^    ") or line:match("^\t")
          if indented and not in_code then
            in_code = true
            table.insert(out, "```" .. lang)
          elseif in_code and line:match("%S") and not indented then
            in_code = false
            table.insert(out, "```")
          end
          if in_code then
            line = line:gsub("^    ", ""):gsub("^\t", "")
          end
          table.insert(out, line)
        end
      end
      if in_code then
        table.insert(out, "```")
      end
      return table.concat(out, "\n")
    end

    local function clean(s, lang)
      s = s:gsub("%[([^%]]*)%]%b()", "_%1_")
      return fence_indented(s, lang)
    end

    local function clean_contents(c, lang)
      if type(c) == "string" then
        return clean(c, lang)
      elseif type(c) == "table" then
        if c.value then
          c.value = clean(c.value, lang)
        else
          for i, item in ipairs(c) do
            c[i] = clean_contents(item, lang)
          end
        end
      end
      return c
    end

    local h = require("noice.lsp.hover")
    local orig = h.on_hover
    h.on_hover = function(err, result, ctx, config)
      if result and result.contents then
        local lang = ctx and ctx.bufnr and vim.bo[ctx.bufnr].filetype or ""
        result.contents = clean_contents(result.contents, lang)
      end
      return orig(err, result, ctx, config)
    end
  end,

  opts = {
    -- Cmdline
    cmdline = {
      enabled = true,
      view = "cmdline_popup",
      win_options = {
        winhighlight = "NormalFloat:NormalFloat,FloatBorder:FloatBorder",
      },
      format = {
        cmdline = { pattern = "^:", icon = "", lang = "vim" },
        search_down = { view = "cmdline", kind = "search", pattern = "^/", icon = " ", lang = "regex" },
        search_up = { view = "cmdline", kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
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
          win_options = { concealcursor = "nc", conceallevel = 2 },
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
        filter = {
          event = "msg_show",
          find = "Unable to retrieve stats from logfile",
        },
        opts = { skip = true },
      },
      -- swallow "written" file messages
      {
        filter = { event = "msg_show", find = "%d+L, %d+B" },
        opts = { skip = true },
      },
      -- swallow basedpyright startups
      {
        filter = { event = "lsp", kind = "progress", find = "basedpyright" },
        opts = { skip = true },
      },
      -- swallow search count virtultext noise
      {
        filter = { event = "msg_show", kind = "search_count" },
        opts = { skip = true },
      },
      -- swallwod lint failures on diffview buffers
      {
        filter = {
          event = "notify",
          any = {
            { find = "Linter command" },
            { find = "Error running" },
            { find = "nvim%-lint" },
          },
        },
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
        border = { style = "rounded", padding = { 0, 1 } },
        position = { row = 2, col = 0 },
        size = { max_height = 16, max_width = 140, min_width = 80 },
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
