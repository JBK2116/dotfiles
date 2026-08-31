-- fzf-lua: the primary fuzzy picker for the editor. Takes over all
-- file finding, grep, LSP goto/references/symbols, buffers, oldfiles,
-- and colorscheme switching. Configured with smartcase, bat preview,
-- and fd/rg integration for fast results.
--
return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    -- File / Buffer Discovery
    { "<leader>ff", "<cmd>FzfLua files<CR>", desc = "Find Files" },
    { "<leader>fr", "<cmd>FzfLua oldfiles<CR>", desc = "Recent Files" },
    { "<leader>,", "<cmd>FzfLua buffers<CR>", desc = "Buffers" },
    -- Search
    { "<leader>fc", "<cmd>FzfLua live_grep<CR>", desc = "Find Content" },
    { "<leader>fw", "<cmd>FzfLua grep_cword<CR>", desc = "Grep Word Under Cursor" },
    { "<leader>fR", "<cmd>FzfLua live_grep_resume<CR>", desc = "Resume Last Grep" },
    -- LSP
    { "gd", "<cmd>FzfLua lsp_definitions<CR>", desc = "Goto Definition" },
    { "gD", "<cmd>FzfLua lsp_declarations<CR>", desc = "Goto Declaration" },
    { "gr", "<cmd>FzfLua lsp_references<CR>", nowait = true, desc = "References" },
    { "gI", "<cmd>FzfLua lsp_implementations<CR>", desc = "Goto Implementation" },
    { "gy", "<cmd>FzfLua lsp_typedefs<CR>", desc = "Goto Type Definition" },
    { "<leader>fs", "<cmd>FzfLua lsp_document_symbols<CR>", desc = "Document Symbols" },
    { "<leader>fS", "<cmd>FzfLua lsp_live_workspace_symbols<CR>", desc = "Workspace Symbols" },
    -- Commands
    { "<leader>fa", "<cmd>FzfLua commands<CR>", desc = "Commands" },
    -- Colorschemes
    { "<leader>uC", "<cmd>FzfLua colorschemes<CR>", desc = "Colorschemes" },
  },
  opts = function()
    local actions = require("fzf-lua").actions
    return {
      -- Default fzf behavior
      fzf_opts = {
        ["--layout"] = "reverse",
        ["--info"] = "inline",
        ["--history"] = vim.fn.stdpath("data") .. "/fzf-lua-history",
      },
      winopts = {
        width = 0.85,
        height = 0.85,
        row = 0.35,
        col = 0.5,
        preview = {
          default = "bat",
          border = "rounded",
          layout = "flex",
          flip_columns = 120,
        },
      },
      keymap = {
        builtin = {
          ["<C-c>"] = "abort",
        },
        fzf = {
          ["ctrl-c"] = "abort",
        },
      },
      -- File finder: hidden files, follow symlinks, respect .gitignore, skip noise dirs
      files = {
        fd_opts = [[--color=never --type f --hidden --follow --exclude .git --exclude node_modules --exclude .cache]],
        actions = {
          ["ctrl-q"] = actions.file_edit_or_qf,
        },
      },
      -- Live grep: hidden files, follow symlinks, exclude .git
      grep = {
        rg_opts = [[--color=never --hidden --follow --no-heading --column --line-number --glob '!.git/*' --glob '!node_modules/*']],
        actions = {
          ["ctrl-q"] = actions.file_edit_or_qf,
        },
      },
      -- Smart-case matching (mirrors vim.o.smartcase / vim.o.ignorecase)
      defaults = {
        git_icons = false,
        file_icons = true,
        color_icons = true,
      },
    }
  end,
  config = function(_, opts)
    require("fzf-lua").setup(opts)
  end,
}
