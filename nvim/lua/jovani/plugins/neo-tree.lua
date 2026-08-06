-- Configures neo-tree.nvim, the file explorer sidebar. Provides <leader>e
-- keymaps to toggle/focus the tree, with git and diagnostic indicators,
-- a filesystem watcher for auto-refresh, and Vim-intuitive navigation
-- mappings (K=parent, J=next sibling, L=open, a=create, d=delete, r=rename).
--
-- neo-tree ships with excellent defaults for all file operations:
--   a=add file, A=add directory, d=delete, r=rename, y=copy, x=cut,
--   p=paste, c=copy-to, m=move, T=trash, u=undo trash.
-- Press ? inside the tree to see all keymaps.
return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  lazy = true,
  cmd = { "Neotree" },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  keys = {
    { "<leader>ee", "<cmd>Neotree toggle<cr>", desc = "Toggle Explorer" },
    { "<leader>ef", "<cmd>Neotree focus<cr>", desc = "Focus Explorer" },
    {
      "<leader>eF",
      "<cmd>Neotree reveal<cr>",
      desc = "Find current file in tree",
    },
    {
      "<leader>er",
      function()
        local ok, manager = pcall(require, "neo-tree.sources.manager")
        if ok then
          manager.refresh()
        end
      end,
      desc = "Refresh Explorer",
    },
  },
  ---@type neotree.Config
  opts = {
    -- Which sources appear in the source selector tabs
    sources = { "filesystem", "buffers", "git_status" },

    -- Feature toggles
    enable_diagnostics = true,
    enable_git_status = true,
    enable_modified_markers = true, -- show [+] when buffer has unsaved changes
    enable_opened_markers = true, -- required for highlight_opened_files
    close_if_last_window = false, -- keep tree open
    sort_case_insensitive = false,

    -- Window layout
    window = {
      position = "left",
      width = 35,
      mapping_options = {
        noremap = true,
        nowait = true,
      },
      mappings = {
        -- Vim-intuitive navigation (harmonize with home-row philosophy)
        -- K = climb up (parent directory)
        ["K"] = "navigate_up",
        -- J = jump down (next item / sibling)
        ["J"] = function()
          vim.api.nvim_feedkeys("j", "n", false)
        end,
        -- L = launch (open file / expand folder)
        ["L"] = "open",

        -- Quick copy operations
        -- Y = yank absolute path (harmonizes with vim's Y)
        ["Y"] = {
          function(state)
            local node = state.tree:get_node()
            vim.fn.setreg("+", node:get_id(), "c")
          end,
          desc = "Copy Absolute Path",
        },
        -- <leader>y = yank relative path
        ["<leader>y"] = {
          function(state)
            local node = state.tree:get_node()
            vim.fn.setreg("+", vim.fn.fnamemodify(node:get_id(), ":."), "c")
          end,
          desc = "Copy Relative Path",
        },
        -- <leader>Y = yank filename only
        ["<leader>Y"] = {
          function(state)
            local node = state.tree:get_node()
            vim.fn.setreg("+", vim.fn.fnamemodify(node:get_id(), ":t"), "c")
          end,
          desc = "Copy Filename",
        },

        -- Quick open without window picker (same as <cr>)
        ["gf"] = "open",
      },
    },

    -- Filesystem source configuration
    filesystem = {
      -- 2-way binding between vim's cwd and tree root
      bind_to_cwd = true,
      -- Auto-reveal the current buffer's file in the tree
      follow_current_file = { enabled = true },
      -- OS-level file watcher for instant auto-refresh
      use_libuv_file_watcher = true,
      -- Replace netrw: opening a directory opens neo-tree
      hijack_netrw_behavior = "open_default",

      -- Filtering (matching old nvim-tree setup)
      filtered_items = {
        visible = false, -- hidden items stay hidden
        hide_dotfiles = false, -- show dotfiles
        hide_gitignored = true, -- hide .gitignored files
        hide_by_name = { "node_modules", ".git" }, -- always hide these
      },

      -- Don't compact empty folders into "empty folder" labels
      group_empty_dirs = false,
    },

    -- Customise component renderers to match nvim-tree aesthetics
    default_component_configs = {
      indent = {
        indent_size = 2,
        padding = 1,
        with_markers = true,
        indent_marker = "│",
        last_indent_marker = "└",
      },
      git_status = {
        symbols = {
          added = "✚",
          deleted = "✖",
          modified = "",
          renamed = "󰁕",
          untracked = "",
          ignored = "",
          unstaged = "",
          staged = "",
          conflict = "",
        },
      },
      icon = {
        folder_closed = "",
        folder_open = "",
        folder_empty = "",
        folder_empty_open = "",
      },
      modified = {
        symbol = "󰏫 ",
      },
      name = {
        highlight_opened_files = true,
      },
    },
  },
}
