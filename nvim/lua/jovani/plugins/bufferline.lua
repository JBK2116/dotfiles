-- Configures bufferline to render a tab line across the top of the editor.
-- Runs in "tabs" mode and surfaces LSP diagnostics as icons on each tab for
-- a cleaner, IDE-style buffer/tab bar.
local diagnostic_icons = { error = " ", warning = " " }

return {
  "akinsho/bufferline.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  version = "*",
  event = "VeryLazy",
  opts = {
    options = {
      mode = "tabs",
      show_buffer_close_icons = false, -- cleaner look
      show_close_icon = false,
      diagnostics = "nvim_lsp", -- show LSP errors in tabs
      diagnostics_indicator = function(count, level)
        return (diagnostic_icons[level] or "") .. count
      end,
      color_icons = true,
      always_show_bufferline = true,
      indicator = { style = "icon", icon = "▎" },
      separator_style = "thin",
      offsets = {
        {
          filetype = "NvimTree",
          text = "File Explorer",
          highlight = "Directory",
          text_align = "left",
        },
      },
    },
  },
}
