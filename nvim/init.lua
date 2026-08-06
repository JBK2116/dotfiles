-- Disable netrw (nvim-tree replaces it)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("jovani.core.init")
require("jovani.lazy")
require("jovani.lsp")

-- Auto-save on insert leave or normal-mode text change
vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
  pattern = "*",
  command = "silent! write",
  nested = true,
})
