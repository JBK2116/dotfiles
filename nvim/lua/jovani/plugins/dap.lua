-- Configures nvim-dap (Debug Adapter Protocol) with debugmaster's modal
-- debugging UI.  nvim-dap-virtual-text shows variable values inline during
-- a debug session, and nvim-nio is the async library it depends on.
--
-- Language-specific adapters live in separate files:
--   dap-python.lua  dap-go.lua  dap-js.lua
return {
  {
    "mfussenegger/nvim-dap",
    event = "VeryLazy",
    dependencies = {
      "theHamsta/nvim-dap-virtual-text",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      -- Virtual text: show variable values inline next to each line
      require("nvim-dap-virtual-text").setup({
        enabled = true,
        commented = true,
        highlight_changed_variables = true,
      })
    end,
  },
  {
    "MironPascalCaseFan/debugmaster.nvim",
    dependencies = {
      "mfussenegger/nvim-dap",
      "jbyuki/one-small-step-for-vimkind", -- optional: debug Neovim Lua code
    },
    config = function()
      local dm = require("debugmaster")

      -- <leader>d enters / exits debug mode (like Insert mode, but for debugging)
      -- All other keys in debug mode are single-press: c=continue, o=step over,
      -- m=step into, q=step out, t=toggle breakpoint, u=toggle UI, H=help
      vim.keymap.set({ "n", "v" }, "<leader>d", dm.mode.toggle, { nowait = true })

      -- Optional: enable debugging of Neovim Lua code itself
      dm.plugins.osv_integration.enabled = true
    end,
  },
}
