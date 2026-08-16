-- Configures mini.statusline (from mini.nvim), replacing lualine. Git
-- branch/diff, LSP diagnostics, pending lazy.nvim update count, LSP client
-- name, filetype/encoding, and location — themed to match the active
-- colorscheme via mini.statusline's built-in highlight groups.
return {
  "echasnovski/mini.statusline",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local statusline = require("mini.statusline")
    local lazy_status = require("lazy.status")

    statusline.setup({
      use_icons = true,
      set_vim_settings = true,

      content = {
        active = function()
          local mode, mode_hl = statusline.section_mode({ trunc_width = 120 })
          local git = statusline.section_git({ trunc_width = 75 })
          local diff = statusline.section_diff({ trunc_width = 75 })
          local diagnostics = statusline.section_diagnostics({
            trunc_width = 75,
            signs = { ERROR = "󰅚 ", WARN = "󰀪 ", INFO = "󰌶", HINT = "󰋽 " },
          })
          local filename = statusline.section_filename({ trunc_width = 140 })
          local fileinfo = statusline.section_fileinfo({ trunc_width = 120 })
          local location = statusline.section_location({ trunc_width = 75 })
          local search = statusline.section_searchcount({ trunc_width = 75 })

          local lsp = ""
          local clients = vim.lsp.get_clients({ bufnr = 0 })
          if #clients > 0 then
            local names = {}
            for _, c in ipairs(clients) do
              table.insert(names, c.name)
            end
            lsp = " " .. table.concat(names, ",")
          end

          local updates = ""
          if lazy_status.has_updates() then
            updates = "%#DiagnosticWarn#" .. lazy_status.updates() .. "%*"
          end

          return statusline.combine_groups({
            { hl = mode_hl, strings = { mode } },
            { hl = "MiniStatuslineDevinfo", strings = { git, diff, diagnostics } },
            "%<", -- truncation point
            { hl = "MiniStatuslineFilename", strings = { filename } },
            "%=", -- right align
            { hl = "MiniStatuslineDevinfo", strings = { updates, lsp } },
            { hl = "MiniStatuslineFileinfo", strings = { fileinfo } },
            { hl = mode_hl, strings = { search, location } },
          })
        end,
      },
    })
  end,
}
