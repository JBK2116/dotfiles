-- Configures nvim-lint to run standalone linters not covered by the LSP.
-- Maps filetypes to their linters (htmlhint, golangcilint, ...), lints
-- automatically on save, and binds <leader>l to lint the current file.
-- Linters should be installed by Mason
return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require("lint")
    lint.linters_by_ft = {
      -- for future reference add more linters in here
      html = { "htmlhint" },
      -- css = { "stylelint" }, Disable this only if you are using raw css
      go = { "golangcilint" },
      java = { "checkstyle" },
    }

    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

    local function try_linting()
      local linters = lint.linters_by_ft[vim.bo.filetype]
      lint.try_lint(linters)
    end

    vim.api.nvim_create_autocmd({ "BufWritePost" }, {
      group = lint_augroup,
      callback = try_linting,
    })

    vim.keymap.set("n", "<leader>l", try_linting, { desc = "Trigger linting for current file" })
  end,
}
