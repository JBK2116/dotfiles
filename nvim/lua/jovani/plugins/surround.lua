-- Configures nvim-surround for adding, changing, and deleting surrounding
-- pairs (quotes, brackets, tags) around text objects and selections.
return {
  "kylechui/nvim-surround",
  event = { "BufReadPre", "BufNewFile" },
  version = "*", -- Use for stability; omit to use `main` branch for the latest features
  config = true,
}
