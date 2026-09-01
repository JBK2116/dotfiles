-- aerial.nvim: code outline window, grouped/ordered by symbol kind.
-- Complements fzf-lua's lsp_document_symbols (which is unsorted) by
-- giving a persistent sidebar and a fuzzy picker that IS sorted/filtered.
return {
  "stevearc/aerial.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  keys = {
    { "<leader>ao", "<cmd>AerialToggle<CR>", desc = "Aerial Outline" },
    -- fzf-lua-powered symbol picker (replaces plain lsp_document_symbols)
    {
      "<leader>fs",
      function()
        require("aerial").fzf_lua_picker()
      end,
      desc = "Document Symbols (Aerial)",
    },
  },
  opts = {
    backends = { "treesitter", "lsp", "markdown", "man" },

    layout = {
      default_direction = "prefer_left",
      width = 30,
      min_width = 20,
      resize_to_content = true,
    },

    -- Keep noise out: only the symbol kinds worth navigating to
    filter_kind = {
      "Class",
      "Constructor",
      "Enum",
      "Function",
      "Interface",
      "Module",
      "Method",
      "Struct",
    },

    autojump = false,
    close_on_select = true,

    highlight_on_hover = true,
    highlight_on_jump = 300,

    open_automatic = false,

    on_attach = function(bufnr)
      vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr, desc = "Prev Symbol" })
      vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr, desc = "Next Symbol" })
    end,
  },
}
