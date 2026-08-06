-- Replaces snacks.bufdelete.  Provides smart buffer deletion that preserves
-- window layout.  The keymaps (<leader>bd / <leader>bD) are in snacks.lua.
return {
  "famiu/bufdelete.nvim",
  event = "VeryLazy",
}
