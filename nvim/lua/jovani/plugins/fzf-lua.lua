-- fzf-lua: the primary fuzzy picker for the editor. Takes over all
-- file finding, grep, LSP goto/references/symbols, buffers, oldfiles,
-- and colorscheme switching. Configured with smartcase, builtin preview,
-- and fd/rg integration for fast results. Also registered as vim.ui.select
-- (code actions, rename prompts, etc. open in fzf).

-- Shared exclude list for fd (files) and rg (grep)
local excludes = {
  ".git",
  "node_modules",
  ".venv",
  "__pycache__",
  ".mypy_cache",
  ".ruff_cache",
  ".pytest_cache",
  ".svelte-kit",
  ".gradle",
  "target",
  "build",
  "dist",
  ".cache",
}

local function fd_excludes()
  return table.concat(
    vim.tbl_map(function(d)
      return "--exclude " .. d
    end, excludes),
    " "
  )
end

local function rg_excludes()
  return table.concat(
    vim.tbl_map(function(d)
      return "--glob '!" .. d .. "'"
    end, excludes),
    " "
  )
end

return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    -- File / Buffer Discovery
    { "<leader>ff", "<cmd>FzfLua files<CR>", desc = "Find Files" },
    { "<leader>fr", "<cmd>FzfLua oldfiles<CR>", desc = "Recent Files" },
    { "<leader>,", "<cmd>FzfLua buffers<CR>", desc = "Buffers" },
    { "<leader>f.", "<cmd>FzfLua resume<CR>", desc = "Resume Last Picker" },
    -- Search
    { "<leader>fc", "<cmd>FzfLua live_grep<CR>", desc = "Find Content" },
    { "<leader>fw", "<cmd>FzfLua grep_cword<CR>", desc = "Grep Word Under Cursor" },
    { "<leader>fw", "<cmd>FzfLua grep_visual<CR>", mode = "x", desc = "Grep Selection" },
    { "<leader>f/", "<cmd>FzfLua blines<CR>", desc = "Search Current Buffer" },
    -- LSP
    { "gd", "<cmd>FzfLua lsp_definitions<CR>", desc = "Goto Definition" },
    { "gD", "<cmd>FzfLua lsp_declarations<CR>", desc = "Goto Declaration" },
    { "gr", "<cmd>FzfLua lsp_references<CR>", nowait = true, desc = "References" },
    { "gI", "<cmd>FzfLua lsp_implementations<CR>", desc = "Goto Implementation" },
    { "gy", "<cmd>FzfLua lsp_typedefs<CR>", desc = "Goto Type Definition" },
    { "<leader>fs", "<cmd>FzfLua lsp_document_symbols<CR>", desc = "Document Symbols" },
    { "<leader>fS", "<cmd>FzfLua lsp_live_workspace_symbols<CR>", desc = "Workspace Symbols" },
    { "<leader>fd", "<cmd>FzfLua diagnostics_document<CR>", desc = "Document Diagnostics" },
    -- Git
    -- Misc
    { "<leader>fa", "<cmd>FzfLua commands<CR>", desc = "Commands" },
    { "<leader>fk", "<cmd>FzfLua keymaps<CR>", desc = "Keymaps" },
    { "<leader>uC", "<cmd>FzfLua colorschemes<CR>", desc = "Colorschemes" },
  },
  opts = function()
    local actions = require("fzf-lua").actions
    return {
      fzf_opts = {
        ["--info"] = "inline",
        ["--history"] = vim.fn.stdpath("data") .. "/fzf-lua-history",
      },
      winopts = {
        width = 0.85,
        height = 0.85,
        row = 0.35,
        col = 0.5,
        preview = {
          border = "rounded",
          layout = "flex",
          flip_columns = 120,
        },
      },
      -- Hidden files, follow symlinks, respect .gitignore, skip noise dirs
      -- ctrl-q selects every result and sends it to the quickfix list
      -- (set per picker: a global actions.files table would replace the default Enter/split actions)
      files = {
        fd_opts = "--color=never --type f --hidden --follow " .. fd_excludes(),
        actions = {
          ["ctrl-q"] = { fn = actions.file_sel_to_qf, prefix = "select-all" },
        },
      },
      -- --smart-case and --color=always are required for smartcase matching and match highlighting
      grep = {
        rg_glob = true, -- `pattern -- *.ts` filters live_grep by glob
        rg_opts = "--color=always --smart-case --column --line-number --no-heading --hidden --follow --max-columns=4096 "
          .. rg_excludes(),
        actions = {
          ["ctrl-q"] = { fn = actions.file_sel_to_qf, prefix = "select-all" },
        },
      },
      oldfiles = {
        cwd_only = true,
        include_current_session = true,
      },
      defaults = {
        git_icons = false,
        file_icons = true,
        color_icons = true,
      },
    }
  end,
  config = function(_, opts)
    local fzf = require("fzf-lua")
    fzf.setup(opts)
    fzf.register_ui_select()
  end,
}
