-- Configures conform.nvim, the code formatter. Maps each filetype to its
-- formatter (prettier, stylua, ruff, clang-format, gofmt, ...), formats
-- automatically when the user stops typing (debounced, since init.lua
-- autosaves on InsertLeave/TextChanged), and exposes <leader>cf for manual
-- formatting.
return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local conform = require("conform")

    conform.setup({
      formatters_by_ft = {
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        svelte = { "prettier" },
        css = { "prettier" },
        html = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        graphql = { "prettier" },
        liquid = { "prettier" },
        lua = { "stylua" },
        python = { "ruff_format" },
        c = { "clang-format" },
        cpp = { "clang-format" },
        go = { "gofmt" },
      },
      -- NOTE: format_on_save is intentionally NOT set. init.lua autosaves on
      -- InsertLeave/TextChanged, so format_on_save would spawn a formatter on
      -- every one of those writes. Debounced idle formatting is set up below
      -- instead.
    })

    vim.keymap.set({ "n", "v" }, "<leader>cf", function()
      conform.format({
        lsp_format = "fallback",
        async = false,
        timeout_ms = 1000,
      })
    end, { desc = "Format file or range (in visual mode)" })
  end,
}
