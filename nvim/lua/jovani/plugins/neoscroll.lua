-- Smooth, animated scrolling for the standard scroll keys. Mappings are
-- declared through lazy.nvim's `keys` (with the plugin's internal
-- `mappings` disabled) so the plugin loads on first use, which-key
-- descriptions are available, and the deprecated set_mappings() path is
-- avoided.
return {
  "karb94/neoscroll.nvim",
  event = "VeryLazy",
  opts = {
    mappings = {}, -- keys are declared below so lazy-loading works
    easing = "quadratic", -- smoother than the default linear glide
    pre_hook = function()
      vim.wo.cursorline = false -- no cursorline flicker mid-animation
    end,
    post_hook = function()
      vim.wo.cursorline = true
    end,
  },
  keys = {
    {
      "<C-u>",
      function()
        require("neoscroll").ctrl_u({ duration = 250 })
      end,
      mode = { "n", "v", "x" },
      desc = "Scroll up half page",
    },
    {
      "<C-d>",
      function()
        require("neoscroll").ctrl_d({ duration = 250 })
      end,
      mode = { "n", "v", "x" },
      desc = "Scroll down half page",
    },
    {
      "<C-b>",
      function()
        require("neoscroll").ctrl_b({ duration = 450 })
      end,
      mode = { "n", "v", "x" },
      desc = "Scroll up one page",
    },
    {
      "<C-f>",
      function()
        require("neoscroll").ctrl_f({ duration = 450 })
      end,
      mode = { "n", "v", "x" },
      desc = "Scroll down one page",
    },
    {
      "<C-y>",
      function()
        require("neoscroll").scroll(-0.1, { move_cursor = false, duration = 100 })
      end,
      mode = { "n", "v", "x" },
      desc = "Scroll up one line",
    },
    {
      "<C-e>",
      function()
        require("neoscroll").scroll(0.1, { move_cursor = false, duration = 100 })
      end,
      mode = { "n", "v", "x" },
      desc = "Scroll down one line",
    },
    {
      "zt",
      function()
        require("neoscroll").zt({ half_win_duration = 250 })
      end,
      mode = { "n", "v", "x" },
      desc = "Cursor to top of window",
    },
    {
      "zz",
      function()
        require("neoscroll").zz({ half_win_duration = 250 })
      end,
      mode = { "n", "v", "x" },
      desc = "Cursor to center of window",
    },
    {
      "zb",
      function()
        require("neoscroll").zb({ half_win_duration = 250 })
      end,
      mode = { "n", "v", "x" },
      desc = "Cursor to bottom of window",
    },
  },
}
