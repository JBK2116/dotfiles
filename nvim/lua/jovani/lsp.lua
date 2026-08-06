-- Defines the editor-wide LSP behavior that isn't tied to any single server.
-- On LspAttach it sets the buffer-local keymaps (code actions, rename, hover,
-- diagnostic navigation) and enables inlay hints. Also configures diagnostic
-- signs/float styling and rounds the borders on hover and signature popups.
local keymap = vim.keymap

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    local opts = { buffer = ev.buf, silent = true }
    opts.desc = "See available code actions"
    keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
    opts.desc = "Smart rename"
    keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    opts.desc = "Show line diagnostics"
    keymap.set("n", "<leader>xd", vim.diagnostic.open_float, opts)
    opts.desc = "Go to previous diagnostic"
    keymap.set("n", "[d", function()
      vim.diagnostic.jump({ count = -1, float = true })
    end, opts)
    opts.desc = "Go to next diagnostic"
    keymap.set("n", "]d", function()
      vim.diagnostic.jump({ count = 1, float = true })
    end, opts)
    opts.desc = "Show documentation"
    keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
  end,
})

vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "󰅚 ",
      [vim.diagnostic.severity.WARN] = "󰀪 ",
      [vim.diagnostic.severity.HINT] = "󰌶 ",
      [vim.diagnostic.severity.INFO] = "󰋽 ",
    },
  },
  float = { border = "rounded" },
  update_in_insert = false,
  virtual_text = true,
})

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })
