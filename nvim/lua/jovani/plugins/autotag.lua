-- Uses treesitter to auto-close and auto-rename HTML/XML tags.
-- When you type </, it auto-completes the matching closing tag.
-- When you rename an opening tag, the closing tag updates automatically.
return {
  "windwp/nvim-ts-autotag",
  event = "InsertEnter",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  config = function()
    require("nvim-ts-autotag").setup({
      opts = {
        -- Disable auto-closing on specific filetypes if needed
        enable_close_on_slash = true,
      },
    })
  end,
}
