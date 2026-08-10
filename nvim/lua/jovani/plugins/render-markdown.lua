-- render-markdown.nvim: Single-plugin markdown rendering + live document preview.
-- Replaces markview.nvim entirely. Provides both in-buffer WYSIWYG rendering
-- AND a synchronized split-view preview (`:RenderMarkdown preview`) that
-- shows the final rendered document — no browser, no second plugin.
return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = { "markdown", "quarto", "rmd", "codecompanion" },
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons", -- language icons on code blocks
  },
  ---@module 'render-markdown'
  ---@type render.md.UserConfig
  opts = {
    -- Mimic Obsidian UI: render in ALL modes (including insert)
    preset = "obsidian",

    -- Also attach to CodeCompanion and R Markdown buffers
    file_types = { "markdown", "quarto", "rmd", "codecompanion" },

    -- Anti-conceal (hybrid mode equivalent)
    -- Hides decorations on the cursor line so you can edit raw text.
    -- Similar to your old markview hybrid_modes = { "i" } but smarter.
    anti_conceal = {
      enabled = true,
      above = 0, -- show rendered content starting at cursor
      below = 0,
      ignore = {
        code_background = true, -- always show code block backgrounds
        indent = true,
        sign = true,
        virtual_lines = true,
      },
    },

    -- Headings
    heading = {
      enabled = true,
      sign = true,
      -- Match your old markview icons
      icons = { "󰉫 ", "󰉬 ", "󰉭 ", "󰉮 ", "󰉯 ", "󰉰 " },
      signs = { "󰫎 " },
      position = "inline",
      width = "full",
      left_pad = 0,
      right_pad = 1,
      min_width = 0,
      border = false,
      backgrounds = {
        "RenderMarkdownH1Bg",
        "RenderMarkdownH2Bg",
        "RenderMarkdownH3Bg",
        "RenderMarkdownH4Bg",
        "RenderMarkdownH5Bg",
        "RenderMarkdownH6Bg",
      },
      foregrounds = {
        "RenderMarkdownH1",
        "RenderMarkdownH2",
        "RenderMarkdownH3",
        "RenderMarkdownH4",
        "RenderMarkdownH5",
        "RenderMarkdownH6",
      },
    },

    -- Code Blocks
    code = {
      enabled = true,
      sign = true,
      style = "full",
      position = "left",
      language_icon = true,
      language_name = true,
      width = "full",
      left_pad = 0,
      right_pad = 1,
      min_width = 0,
      border = "thin",
      above = "▄",
      below = "▀",
      inline = true,
      inline_pad = 1,
      highlight = "RenderMarkdownCode",
      highlight_inline = "RenderMarkdownCodeInline",
    },

    -- Block Quotes & Callouts
    quote = {
      enabled = true,
      icon = "▋", -- your old markview border
      repeat_linebreak = false,
      highlight = {
        "RenderMarkdownQuote1",
        "RenderMarkdownQuote2",
        "RenderMarkdownQuote3",
        "RenderMarkdownQuote4",
        "RenderMarkdownQuote5",
        "RenderMarkdownQuote6",
      },
    },
    -- All GitHub + Obsidian callouts come pre-configured.
    -- GitHub: NOTE, TIP, IMPORTANT, WARNING, CAUTION
    -- Obsidian: ABSTRACT, SUMMARY, TLDR, INFO, TODO, HINT, SUCCESS,
    --           CHECK, DONE, QUESTION, HELP, FAQ, ATTENTION,
    --           FAILURE, FAIL, MISSING, DANGER, ERROR, BUG,
    --           EXAMPLE, QUOTE, CITE

    -- Tables
    pipe_table = {
      enabled = true,
      style = "full",
      preset = "none",
      cell = "padded",
      padding = 1,
      min_width = 0,
      alignment_indicator = "━",
      -- stylua: ignore
      border = {
        "┌", "┬", "┐",
        "├", "┼", "┤",
        "└", "┴", "┘",
        "│", "─",
      },
      head = "RenderMarkdownTableHead",
      row = "RenderMarkdownTableRow",
    },

    -- Lists & Bullets
    bullet = {
      enabled = true,
      -- Cycle through icons per nesting level (matches old markview)
      icons = { "●", "○", "◆", "◇" },
      ordered_icons = function(ctx)
        local value = vim.trim(ctx.value)
        local index = tonumber(value:sub(1, #value - 1))
        return ("%d."):format(index > 1 and index or ctx.index)
      end,
      left_pad = 0,
      right_pad = 1,
      highlight = "RenderMarkdownBullet",
    },

    -- Checkboxes
    checkbox = {
      enabled = true,
      bullet = false,
      left_pad = 0,
      right_pad = 1,
      unchecked = {
        icon = "󰄱 ",
        highlight = "RenderMarkdownUnchecked",
      },
      checked = {
        icon = "󰱒 ",
        highlight = "RenderMarkdownChecked",
      },
      custom = {
        todo = { raw = "[-]", rendered = "󰥔 ", highlight = "RenderMarkdownTodo" },
        pending = { raw = "[?]", rendered = "󰥔 ", highlight = "RenderMarkdownTodo" },
      },
    },

    -- Horizontal Rules
    dash = {
      enabled = true,
      icon = "─",
      width = "full",
      highlight = "RenderMarkdownDash",
    },

    -- Links
    link = {
      enabled = true,
      image = "󰥶 ",
      email = "󰀓 ",
      hyperlink = "󰌹 ",
      highlight = "RenderMarkdownLink",
      wiki = {
        enabled = true,
        icon = "󱗖 ",
        conceal_destination = true,
        highlight = "RenderMarkdownWikiLink",
      },
      -- Destination-specific icons (pre-configured for GitHub, YouTube, etc.)
      custom = {
        github = { icon = "󰊤 ", pattern = "github%.com", kind = "url" },
        youtube = { icon = "󰗃 ", pattern = "youtube[^.]*%.com", kind = "url" },
        reddit = { icon = "󰑍 ", pattern = "reddit%.com", kind = "url" },
        stackoverflow = { icon = "󰓌 ", pattern = "stackoverflow%.com", kind = "url" },
      },
    },

    -- Obsidian Inline Highlights (==text==)
    inline_highlight = {
      enabled = true,
      highlight = "RenderMarkdownInlineHighlight",
    },

    -- LaTeX Math
    latex = {
      enabled = true,
      inline = true,
      block = true,
      converter = { "latex2text" },
      highlight = "RenderMarkdownMath",
      position = "center",
      top_pad = 0,
      bottom_pad = 0,
    },

    -- HTML
    html = {
      enabled = true,
      comment = {
        conceal = true,
      },
    },

    -- Window Options
    win_options = {
      conceallevel = {
        default = vim.o.conceallevel,
        rendered = 3, -- fully conceal markdown syntax
      },
      concealcursor = {
        default = vim.o.concealcursor,
        rendered = "", -- show concealed text in all modes when cursor is on it
      },
    },

    -- Completions
    completions = {
      lsp = { enabled = true },
    },
  },

  keys = {
    -- Toggle the split-view document preview (Obsidian reading view)
    { "<leader>mp", "<cmd>RenderMarkdown preview<cr>", desc = "Toggle markdown preview (split)" },
    -- Toggle rendering on/off globally
    { "<leader>mt", "<cmd>RenderMarkdown toggle<cr>", desc = "Toggle markdown rendering" },
    -- Toggle rendering for current buffer only
    { "<leader>mbt", "<cmd>RenderMarkdown buf_toggle<cr>", desc = "Toggle rendering (buffer)" },
    -- Expand anti-conceal margin (show more rendered lines around cursor)
    { "<leader>me", "<cmd>RenderMarkdown expand<cr>", desc = "Expand anti-conceal margin" },
    -- Contract anti-conceal margin (show fewer rendered lines)
    { "<leader>mc", "<cmd>RenderMarkdown contract<cr>", desc = "Contract anti-conceal margin" },
  },
}
