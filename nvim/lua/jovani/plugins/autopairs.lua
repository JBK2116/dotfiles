-- Configures nvim-autopairs to automatically insert matching brackets,
-- quotes, and parentheses as you type. Uses treesitter to avoid pairing in
-- contexts where it would be wrong (e.g. inside strings).
return {
  "windwp/nvim-autopairs",
  event = "InsertEnter",
  config = function()
    require("nvim-autopairs").setup({
      check_ts = true,
      ts_config = {
        lua = { "string" },
        javascript = { "template_string" },
      },
    })
  end,
}
