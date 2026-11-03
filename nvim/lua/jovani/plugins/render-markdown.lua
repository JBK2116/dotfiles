-- render-markdown.nvim: in-buffer rendering + noice hover/signature docs.
return {
  "MeanderingProgrammer/render-markdown.nvim",
  lazy = false,
  dependencies = {
    "nvim-treesitter/nvim-treesitter", -- parsers: markdown, markdown_inline, html, latex, yaml
    "nvim-tree/nvim-web-devicons", -- code block language icons
  },
  ---@module 'render-markdown'
  ---@type render.md.UserConfig
  opts = {
    preset = "obsidian",
    file_types = { "markdown", "quarto", "rmd" },

    -- Render in every mode (insert included); anti_conceal handles editing.
    render_modes = true,
    debounce = 100,
    max_file_size = 10.0,

    -- Raw text on the cursor line only. Block backgrounds, indent and signs stay.
    anti_conceal = {
      enabled = true,
      above = 0,
      below = 0,
      ignore = {
        code_background = true,
        indent = true,
        sign = true,
        virtual_lines = true,
      },
    },

    win_options = {
      conceallevel = { default = vim.o.conceallevel, rendered = 3 },
      concealcursor = { default = vim.o.concealcursor, rendered = "" },
    },

    heading = {
      sign = false, -- no gutter clutter
      position = "inline",
      width = "full",
      left_pad = 0,
      right_pad = 1,
      border = false,
      icons = { "󰉫 ", "󰉬 ", "󰉭 ", "󰉮 ", "󰉯 ", "󰉰 " },
    },

    code = {
      style = "full",
      sign = false,
      width = "full",
      left_pad = 1,
      right_pad = 1,
      border = "thin",
      conceal_delimiters = true,
      language_icon = true,
      language_name = true,
      language_info = true,
      disable_background = { "diff" },
      inline = true,
      inline_pad = 1,
    },

    bullet = {
      icons = { "●", "○", "◆", "◇" },
      right_pad = 1,
      -- Fixed: nil-safe (`or 0`), matches upstream default.
      ordered_icons = function(ctx)
        local value = vim.trim(ctx.value)
        local index = tonumber(value:sub(1, #value - 1)) or 0
        return ("%d."):format(index > 1 and index or ctx.index)
      end,
    },

    checkbox = {
      right_pad = 1,
      custom = {
        todo = { raw = "[-]", rendered = "󰥔 ", highlight = "RenderMarkdownTodo" },
        progress = { raw = "[~]", rendered = "󰦖 ", highlight = "RenderMarkdownInfo" },
        important = { raw = "[!]", rendered = "󰀪 ", highlight = "RenderMarkdownWarn" },
        cancelled = { raw = "[/]", rendered = "󰅖 ", highlight = "RenderMarkdownError" },
      },
    },

    quote = { icon = "▋", repeat_linebreak = false },

    pipe_table = {
      style = "full",
      preset = "round",
      cell = "padded",
      wrap = true, -- fit wide tables to the window
      padding = 1,
    },

    link = {
      footnote = { enabled = true, superscript = true },
      wiki = { enabled = true, conceal_destination = true },
    },

    inline_highlight = { enabled = true }, -- ==text==

    -- Needs utftex (libtexprintf) or latex2text (pylatexenc) on PATH.
    latex = { enabled = true, converter = { "utftex", "latex2text" } },

    html = { comment = { conceal = true } },

    completions = { lsp = { enabled = true } }, -- callout/checkbox completion
  },

  keys = {
    { "<leader>mp", "<cmd>RenderMarkdown preview<cr>", desc = "Markdown preview (split)" },
    { "<leader>mt", "<cmd>RenderMarkdown toggle<cr>", desc = "Toggle rendering" },
    { "<leader>mb", "<cmd>RenderMarkdown buf_toggle<cr>", desc = "Toggle rendering (buffer)" },
    { "<leader>me", "<cmd>RenderMarkdown expand<cr>", desc = "Expand anti-conceal margin" },
    { "<leader>mc", "<cmd>RenderMarkdown contract<cr>", desc = "Contract anti-conceal margin" },
  },
}
