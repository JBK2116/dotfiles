-- Configures trouble.nvim, a pretty list for diagnostics and related lists.
-- Opens in a bottom split with preview and binds <leader>x keymaps for
-- workspace/document diagnostics, quickfix, location list, and todos.
return {
  "folke/trouble.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons", "folke/todo-comments.nvim" },
  cmd = "Trouble",
  opts = {
    focus = true, -- steal focus when opening trouble
    auto_preview = true, -- preview item under cursor
    follow = true, -- follow cursor in source buffer
    indent_guides = true, -- show tree indent guides
    multiline = true, -- show full multi-line messages
    win = {
      type = "split",
      position = "bottom",
      size = 12,
    },
  },
  keys = {
    { "<leader>xw", "<cmd>Trouble diagnostics toggle<CR>", desc = "Workspace diagnostics" },
    { "<leader>xq", "<cmd>Trouble quickfix toggle<CR>", desc = "Quickfix list" },
    { "<leader>xl", "<cmd>Trouble loclist toggle<CR>", desc = "Location list" },
  },
}
