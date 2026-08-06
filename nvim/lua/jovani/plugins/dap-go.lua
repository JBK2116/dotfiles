-- Go debug adapter for nvim-dap.
-- Uses Delve (dlv) under the hood — the standard Go debugger also used by
-- VS Code and GoLand.  nvim-dap-go registers the adapter and default
-- launch/attach/test configurations, so your generic DAP keymaps
-- (<leader>dc, <leader>do, …) work out of the box.
-- Delve itself is auto-installed by Mason (see lsp/mason.lua).
return {
  {
    "leoluz/nvim-dap-go",
    ft = "go",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      require("dap-go").setup()
    end,
  },
}
