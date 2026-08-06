-- Highlights and searches for TODO, FIXME, HACK, WARN, NOTE, and PERF
-- comments across the codebase. Integrates with trouble and snacks picker.
return {
  "folke/todo-comments.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  event = "BufReadPre",
  opts = {
    signs = true,
    sign_priority = 8,
    keywords = {
      FIX = { icon = "󰁨 ", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
      TODO = { icon = " ", color = "info" },
      HACK = { icon = " ", color = "warning" },
      WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
      PERF = { icon = "", color = "default", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
      NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
    },
    highlight = {
      before = "",
      keyword = "wide_bg",
      after = "fg",
      pattern = [[.*<(KEYWORDS)\s*:]],
      comments_only = true,
    },
    search = {
      command = "rg",
      args = {
        "--color=never",
        "--no-heading",
        "--with-filename",
        "--line-number",
        "--column",
      },
      pattern = [=[\b(KEYWORDS)[\s:]]=],
    },
  },
  keys = {
    {
      "]t",
      function()
        require("todo-comments").jump_next()
      end,
      desc = "Next TODO",
    },
    {
      "[t",
      function()
        require("todo-comments").jump_prev()
      end,
      desc = "Prev TODO",
    },
    {
      "<leader>xt",
      "<cmd>Trouble todo toggle<CR>",
      desc = "TODOs (Trouble)",
    },
  },
}
