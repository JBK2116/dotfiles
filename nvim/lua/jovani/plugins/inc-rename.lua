-- inc-rename.lua
return {
  "smjonas/inc-rename.nvim",
  cmd = "IncRename",
  opts = {},
  keys = {
    {
      "<leader>rn",
      function()
        return ":IncRename " .. vim.fn.expand("<cword>")
      end,
      expr = true,
      desc = "Rename symbol",
    },
  },
}
