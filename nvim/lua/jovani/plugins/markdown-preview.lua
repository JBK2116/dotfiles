-- markdown-preview.nvim: Browser-based HTML preview with live reload.
-- Pairs with render-markdown.nvim (in-buffer decorations) to provide
-- an actual rendered document view — like Obsidian's reading view, but in
-- your browser. Pure Lua, zero npm/Node.js dependency.
return {
  "selimacerbas/markdown-preview.nvim",
  ft = { "markdown", "quarto", "rmd" },
  dependencies = {
    "selimacerbas/live-server.nvim", -- pure Lua HTTP server
  },
  opts = {
    -- "takeover" = one preview tab, reused across buffers
    -- "multi"    = one tab per preview instance
    instance_mode = "takeover",
    -- 0 = auto-assign port
    port = 0,
    -- Automatically open browser on MarkdownPreview
    open_browser = true,
    -- Start with dark theme (matches your Neovim colorscheme)
    default_theme = "dark",
    -- Debounce before triggering refresh (ms)
    debounce_ms = 300,
  },
  keys = {
    -- Open browser preview
    { "<leader>mP", "<cmd>MarkdownPreview<cr>", desc = "Open markdown preview (browser)" },
    -- Stop preview server
    { "<leader>mS", "<cmd>MarkdownPreviewStop<cr>", desc = "Stop markdown preview" },
    -- Toggle preview
    { "<leader>mT", "<cmd>MarkdownPreviewToggle<cr>", desc = "Toggle markdown preview" },
  },
}
