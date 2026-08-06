-- Configures nvim-tree.lua, the file explorer sidebar. Provides <leader>e
-- keymaps to toggle/focus the tree, with git and diagnostic indicators,
-- a filesystem watcher for auto-refresh, and Vim-intuitive navigation
-- mappings (K=parent, J/K=siblings, H/L=depth, a=create, d=delete, r=rename).
--
-- Defaults are preserved via api.config.mappings.default_on_attach; custom
-- mappings are layered on top. Press g? inside the tree to see all keymaps.
return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = true,
  cmd = { "NvimTreeToggle", "NvimTreeFocus", "NvimTreeFindFile", "NvimTreeCollapse", "NvimTreeRefresh" },
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  keys = {
    { "<leader>ee", "<cmd>NvimTreeToggle<cr>", desc = "Toggle Explorer" },
    { "<leader>ef", "<cmd>NvimTreeFocus<cr>", desc = "Focus Explorer" },
    {
      "<leader>eF",
      "<cmd>NvimTreeFindFile<cr>",
      desc = "Find current file in tree",
    },
    { "<leader>er", "<cmd>NvimTreeRefresh<cr>", desc = "Refresh Explorer" },
  },
  ---@type NvimTreeConfig
  opts = {
    -- Sorting 
    sort = {
      sorter = "case_sensitive",
      folders_first = true,
      files_first = false,
    },

    -- View
    view = {
      width = 35,
      side = "left",
      number = false,
      relativenumber = false,
      signcolumn = "yes",
      float = {
        enable = false,
      },
    },

    -- Renderer
    renderer = {
      group_empty = false, -- compact: skip empty folder labels
      full_name = false, -- hide user home folder prefix
      root_folder_label = ":~:s?$?/..?", -- show ~/... instead of full path
      highlight_git = true,
      highlight_opened_files = "name", -- dim already-open files
      indent_width = 2,
      indent_markers = {
        enable = true,
        inline_arrows = false,
        icons = {
          corner = "└",
          edge = "│",
          item = "│",
          bottom = "─",
          none = " ",
        },
      },
      icons = {
        webdev_colors = true, -- use nvim-web-devicons colors
        git_placement = "after",
        padding = " ",
        symlink_arrow = " ➜ ",
        show = {
          file = true,
          folder = true,
          folder_arrow = true,
          git = true,
          modified = true,
          diagnostics = true,
          bookmarks = true,
        },
        glyphs = {
          default = "󰈚",
          symlink = "󰌹",
          bookmark = "󰸌",
          modified = "󰏫",
          hidden = "󰮉",
          folder = {
            arrow_closed = "",
            arrow_open = "",
            default = "",
            open = "",
            empty = "",
            empty_open = "",
            symlink = "󰌷",
            symlink_open = "󰌸",
          },
          git = {
            unstaged = "󰄱",
            staged = "󰄲",
            unmerged = "󱚱",
            renamed = "󰁕",
            untracked = "󰎔",
            deleted = "✖",
            ignored = "󰮉",
          },
        },
      },
      special_files = { "Cargo.toml", "Makefile", "README.md", "readme.md" },
      symlink_destination = true,
    },

    -- Filters
    filters = {
      dotfiles = false, -- show dotfiles
      git_ignored = true, -- hide .gitignored files
      custom = { "node_modules", ".git" }, -- always hide these
      exclude = {},
    },

    -- Git Integration
    git = {
      enable = true,
      ignore = false,
      show_on_dirs = true, -- show git status on directories
      show_on_open_dirs = true,
      disable_for_dirs = {},
      timeout = 400, -- ms; timeout git if slow
      cygwin_support = false,
    },

    -- Diagnostics
    diagnostics = {
      enable = true,
      show_on_dirs = true,
      show_on_open_dirs = true,
      debounce_delay = 50,
      severity = {
        min = vim.diagnostic.severity.HINT,
        max = vim.diagnostic.severity.ERROR,
      },
      icons = {
        hint = "󰌶",
        info = "󰋽",
        warning = "󰀪",
        error = "󰅚",
      },
    },

    -- Modified Buffer Indicator
    modified = {
      enable = true,
      show_on_dirs = true,
      show_on_open_dirs = true,
    },

    -- Actions
    actions = {
      use_system_clipboard = true, -- yank to system clipboard
      change_dir = {
        enable = true,
        global = false, -- only change nvim-tree's cwd, not editor's
        restrict_above_cwd = false,
      },
      expand_all = {
        max_folder_discovery = 100, -- don't blow up on massive dirs
        exclude = { "node_modules", ".git" },
      },
      file_popup = {
        open_win_config = {
          border = "rounded",
        },
      },
      open_file = {
        quit_on_open = false, -- keep tree open
        eject = true, -- move cursor to opened file
        resize_window = true, -- resize if needed
        window_picker = {
          enable = true,
          picker = "default", -- use Neovim's default window picker
          chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
          exclude = {
            filetype = { "notify", "packer", "qf", "diff", "fugitive", "fugitiveblame" },
            buftype = { "nofile", "terminal", "help" },
          },
        },
      },
      remove_file = {
        close_window = true, -- close tree if trash/delete empties root
      },
    },

    -- Filesystem Watchers
    filesystem_watchers = {
      enable = true,
      debounce_delay = 50,
      ignore_dirs = { "node_modules", ".git" },
    },

    -- Live Filter
    live_filter = {
      prefix = "[FILTER]: ",
      always_show_folders = true, -- show folders even when they don't match
    },

    -- Tab / Buffer
    tab = {
      sync = {
        open = false,
        close = false,
        ignore = {},
      },
    },

    -- Notifications
    notify = {
      threshold = vim.log.levels.WARN, -- only warn+ for fs ops
      absolute_path = false,
    },

    -- UI
    ui = {
      confirm = {
        remove = true, -- prompt before delete
        trash = true, -- prompt before trash
        default_yes = false, -- default to "no" in prompts
      },
    },

    -- Hijack Netrw
    hijack_netrw = true,
    hijack_directories = {
      enable = true,
      auto_open = true, -- open tree when entering a directory
    },
    hijack_unnamed_buffer_when_opening = false,

    -- Update Focused File
    update_focused_file = {
      enable = true,
      update_root = {
        enable = false,
        ignore_list = {},
      },
      ignore_list = { "help", "toggleterm", "Trouble", "trouble", "qf" },
    },

    -- Misc 
    sync_root_with_cwd = true,
    respect_buf_cwd = true,
    reload_on_bufenter = false,
    prefer_startup_root = false,
  },

  -- Keymaps
  -- IMPORTANT: on_attach must be set in opts BEFORE setup() is called
  -- so nvim-tree picks it up. We wrap the original on_attach (if any)
  -- and layer our Vim-intuitive keymaps on top of the defaults.
  config = function(_, opts)
    local api = require("nvim-tree.api")
    local original_on_attach = opts.on_attach

    opts.on_attach = function(bufnr)
      -- Apply nvim-tree's built-in default keymaps first
      api.config.mappings.default_on_attach(bufnr)

      -- Helper to define buffer-local mappings with descriptions
      local function map(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, {
          buffer = bufnr,
          noremap = true,
          silent = true,
          nowait = true,
          desc = "nvim-tree: " .. desc,
        })
      end

      -- Vim-intuitive navigation (K/J/L)
      -- These harmonize with vim's home-row philosophy:
      --   K = climb up (parent directory)
      --   J = jump down (next sibling)
      --   L = launch (open file / expand folder)
      --
      map("n", "K", api.node.navigate.parent, "Parent Directory")
      map("n", "J", api.node.navigate.sibling.next, "Next Sibling")
      map("n", "L", api.node.open.edit, "Open")

      -- Quick copy operations
      -- Y = yank absolute path (harmonizes with vim's Y)
      map("n", "Y", api.fs.copy.absolute_path, "Copy Absolute Path")
      -- leader+y = yank relative path
      map("n", "<leader>y", api.fs.copy.relative_path, "Copy Relative Path")
      -- leader+Y = yank filename only
      map("n", "<leader>Y", api.fs.copy.filename, "Copy Filename")

      -- Quick open without window picker
      map("n", "gf", api.node.open.no_window_picker, "Open (no picker)")

      -- Toggle preview
      map("n", "P", function()
        local node = api.tree.get_node_under_cursor()
        if node and node.type == "directory" then
          api.node.open.preview()
        end
      end, "Preview Toggle")

      -- Original on_attach (if user provided one)
      if original_on_attach then
        original_on_attach(bufnr)
      end
    end

    -- NOW call setup with the complete opts (including on_attach)
    require("nvim-tree").setup(opts)
  end,
}

