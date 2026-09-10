-- Configures lualine.nvim, replacing mini.statusline. Git
-- branch/diff, LSP diagnostics, pending lazy.nvim update count, LSP client
-- name, filetype/encoding, location, and pending command keys (showcmd) —
-- themed to match the active colorscheme via lualine's auto theme.
return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local lazy_status = require("lazy.status")
    require("lualine").setup({
      options = {
        theme = "auto",
        globalstatus = true,
        component_separators = "",
        section_separators = "",
      },
      sections = {
        -- "%S" renders showcmd (pending command keys) right after the
        -- mode indicator; it only shows when 'showcmdloc' includes
        -- "statusline"
        lualine_a = { "mode", "%S" },
        lualine_b = {
          "branch",
          "diff",
          {
            "diagnostics",
            symbols = { error = "󰅚 ", warn = "󰀪 ", info = "󰌶", hint = "󰋽 " },
          },
        },
        lualine_c = { { "filename", path = 1 } },
        lualine_x = {
          {
            lazy_status.updates,
            cond = lazy_status.has_updates,
            color = { fg = "Orange" },
          },
          {
            function()
              local clients = vim.lsp.get_clients({ bufnr = 0 })
              if #clients == 0 then
                return ""
              end
              local names = {}
              for _, c in ipairs(clients) do
                table.insert(names, c.name)
              end
              return " " .. table.concat(names, ",")
            end,
          },
          "encoding",
          "fileformat",
          "filetype",
        },
        lualine_y = { "searchcount" },
        lualine_z = { "location" },
      },
    })
  end,
}
