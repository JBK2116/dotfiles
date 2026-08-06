-- Configures markview.nvim to render markdown (and CodeCompanion buffers)
-- inline with styled headings, code blocks, callouts, tables, lists,
-- checkboxes, and links. Uses hybrid mode so the line under the cursor stays
-- raw for editing while everything else renders.
return {
  "OXY2DEV/markview.nvim",
  ft = { "markdown", "quarto", "rmd", "codecompanion" },
  opts = {
    preview = {
      enable = true,
      -- Render in normal, visual, and command modes; edit freely in insert
      modes = { "n", "v", "c" },
      hybrid_modes = { "i" },
      linewise_hybrid_mode = true,
      icon_provider = "devicons", -- or "mini" / "internal"
      debounce = 50,
      max_buf_lines = 1000,
      -- Range around cursor that stays "raw" in hybrid mode
      edit_range = { 2, 2 },
      draw_range = { vim.o.lines, vim.o.lines },
      filetypes = { "markdown", "quarto", "rmd", "codecompanion" },
      ignore_buftypes = {},
      splitview_winopts = {
        split = "right",
        width = 80,
      },
    },
    markdown = {
      enable = true,
      headings = {
        enable = true,
        shift_width = 1,
        heading_1 = { style = "label", sign = "󰉫 ", hl = "MarkviewHeading1" },
        heading_2 = { style = "label", sign = "󰉬 ", hl = "MarkviewHeading2" },
        heading_3 = { style = "label", sign = "󰉭 ", hl = "MarkviewHeading3" },
        heading_4 = { style = "label", sign = "󰉮 ", hl = "MarkviewHeading4" },
        heading_5 = { style = "label", sign = "󰉯 ", hl = "MarkviewHeading5" },
        heading_6 = { style = "label", sign = "󰉰 ", hl = "MarkviewHeading6" },
      },
      code_blocks = {
        enable = true,
        style = "block", -- full bordered block
        label_direction = "right",
        min_width = 60,
        pad_amount = 2,
        sign = true,
      },
      block_quotes = {
        enable = true,
        default = {
          border = "▋",
          border_hl = "MarkviewBlockQuoteDefault",
        },
        callouts = {
          -- GitHub-flavored callouts
          NOTE = { preview = "󰋽 Note", preview_hl = "MarkviewBlockQuoteNote" },
          TIP = { preview = "󰌶 Tip", preview_hl = "MarkviewBlockQuoteTip" },
          IMPORTANT = { preview = "󰅾 Important", preview_hl = "MarkviewBlockQuoteWarn" },
          WARNING = { preview = "󰀪 Warning", preview_hl = "MarkviewBlockQuoteWarn" },
          CAUTION = { preview = "󰳦 Caution", preview_hl = "MarkviewBlockQuoteError" },
        },
      },
      horizontal_rules = {
        enable = true,
        parts = {
          { type = "repeating", text = "─", hl = "MarkviewGradient5" },
        },
      },
      tables = {
        enable = true,
        style = "padded", -- clean column alignment
        col_min_width = 10,
        block_decorator = true,
      },
      list_items = {
        enable = true,
        indent_size = 2,
        shift_width = 2,
        marker_minus = { add_padding = true, text = "●" },
        marker_plus = { add_padding = true, text = "◆" },
        marker_star = { add_padding = true, text = "◉" },
        marker_dot = { add_padding = true },
        marker_parenthesis = { add_padding = true },
      },
    },
    markdown_inline = {
      enable = true,
      checkboxes = {
        enable = true,
        checked = { text = "󰱒", hl = "MarkviewCheckboxChecked" },
        unchecked = { text = "󰄱", hl = "MarkviewCheckboxUnchecked" },
        pending = { text = "󰥔", hl = "MarkviewCheckboxPending" },
      },
      inline_codes = {
        enable = true,
        padding_left = " ",
        padding_right = " ",
        hl = "MarkviewInlineCode",
      },
      hyperlinks = {
        enable = true,
        icon = "󰌹 ",
        hl = "MarkviewHyperlink",
      },
      images = {
        enable = true,
        icon = "󰥶 ",
        hl = "MarkviewImageLink",
      },
      emails = { enable = true, icon = " ", hl = "MarkviewEmail" },
      uri_autolinks = { enable = true, icon = "󰖟 " },
    },
    latex = { enable = true },
    html = { enable = true },
    experimental = {
      prefer_nvim = true,
      list_empty_line_tolerance = 3,
    },
  },
}
