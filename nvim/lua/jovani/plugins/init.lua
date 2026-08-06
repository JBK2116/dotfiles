-- Declares shared library/dependency plugins that other plugins build on:
-- plenary's lua helpers and tmux-aware split navigation.
return {
  "nvim-lua/plenary.nvim", -- lua functions that many plugins use
  "christoomey/vim-tmux-navigator", -- tmux & split window navigation
}
