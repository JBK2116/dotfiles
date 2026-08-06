-- Replaces snacks.words.  Highlights all LSP references to the word under
-- cursor with the same LSP document-highlight infrastructure blink.cmp uses.
return {
  "RRethy/vim-illuminate",
  event = "VeryLazy",
  opts = {
    delay = 200,
    filetypes_denylist = {
      "neo-tree",
      "Trouble",
      "trouble",
      "dashboard",
      "alpha",
      "lazy",
      "mason",
      "NvimTree",
    },
    under_cursor = true,
    large_file_cutoff = 2000,
    large_file_overrides = {
      providers = { "lsp" },
    },
  },
  config = function(_, opts)
    require("illuminate").configure(opts)
  end,
}
