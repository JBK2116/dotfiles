-- codediff.nvim: view-only git diff / history (VSCode-style two-tier highlighting). Commits etc. happen in lazygit/Neogit.
-- Inside a CodeDiff view, press g? for keymaps. Close with q.
-- Neogit uses this as its diff viewer (see neogit config: diff_viewer = "codediff").
-- Highlights follow the colorscheme automatically; see the README `highlights` option to override.
return {
  "esmuellert/codediff.nvim",
  cmd = "CodeDiff",
  dependencies = { "MunifTanjim/nui.nvim" }, -- explorer UI (harmless if the current version no longer needs it)
  keys = {
    { "<leader>gD", "<cmd>CodeDiff HEAD~1<CR>", desc = "Git: Diff against HEAD~1" },
    { "<leader>gf", "<cmd>CodeDiff history %<CR>", desc = "Git: File history" },
    { "<leader>gf", ":CodeDiff history<CR>", mode = "x", desc = "Git: History of selected lines" },
    { "<leader>gF", "<cmd>CodeDiff history<CR>", desc = "Git: Repo history" },
  },
  opts = {},
}
