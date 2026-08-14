-- Configures which-key.nvim, which shows a popup of available keybindings
-- after a short delay. Tunes the enabled presets for speed and labels the
-- leader-key groups (find, git, search, toggle, buffer, code, ...).
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    delay = 200,
    preset = "modern",
    icons = {
      mappings = true,
      rules = false, -- disable auto-icon rules, faster
    },
    plugins = {
      marks = true,
      registers = true,
      spelling = { enabled = false }, -- you have blink.cmp
      presets = {
        operators = false, -- slows things down
        motions = false,
        text_objects = false,
        windows = true,
        nav = false,
        z = true,
        g = false,
      },
    },
    spec = {
      { "<leader>f", group = "find" },
      { "<leader>g", group = "git" },
      { "<leader>s", group = "search" },
      { "<leader>u", group = "toggle" },
      { "<leader>b", group = "buffer" },
      { "<leader>c", group = "code" },
      { "<leader>e", group = "explorer" },
      { "<leader>x", group = "diagnostics" },
      { "<leader>o", group = "docs" },
      { "<leader>t", group = "tabs" },
      { "<leader>w", group = "windows" },
      { "g", group = "goto" },
      { "ga", group = "calls" },
      { "m", group = "mark" },
      { "dm", group = "delete mark" },
    },
  },
}
