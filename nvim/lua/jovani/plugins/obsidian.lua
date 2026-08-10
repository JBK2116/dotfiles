-- obsidian.nvim: Obsidian vault integration for Neovim.
-- Provides note creation, wiki-link navigation, backlinks, tags,
-- ripgrep-powered full-text search, template insertion, and renaming
-- with automatic backlink updates. Uses fzf-lua for all pickers and
-- blink.cmp for note/tag/link completions.
--
return {
  "epwalsh/obsidian.nvim",
  version = "*", -- latest stable release
  lazy = true,
  ft = "markdown",
  dependencies = {
    "nvim-lua/plenary.nvim", -- required
    "ibhagwan/fzf-lua", -- picker backend
  },
  ---@module "obsidian"
  ---@type obsidian.config.ClientOpts
  opts = {
    workspaces = {
      {
        name = "notes",
        path = "~/Obsidian/notes/", -- NOTE: This must match the system path
      },
    },

    -- Pickers use fzf-lua
    picker = {
      name = "fzf-lua",
      -- Optional: configure fzf-lua-specific picker mappings
      mappings = {
        new = "<C-x>",
        insert_link = "<C-l>",
      },
    },

    -- Completion via blink.cmp
    completion = {
      blink = true,
      nvim_cmp = false,
      min_chars = 2,
    },

    -- Templates: stored in a "templates" subdirectory of the vault
    templates = {
      subdir = "TEMPLATES",
      date_format = "%Y-%m-%d",
      time_format = "%H:%M",
    },

    -- New notes go into the vault root (or "notes" subdir if configured per workspace)
    new_notes_location = "current_dir",

    -- Use Obsidian-style wiki links: [[note]]
    preferred_link_style = "wiki",

    -- Disable built-in UI: render-markdown.nvim handles all markdown rendering
    ui = {
      enable = false,
    },

    -- Disable frontmatter management (keep YAML untouched)
    disable_frontmatter = true,
  },

  -- Lazy-load via these commands (available immediately after any markdown buffer opens)
  keys = {
    { "<leader>on", "<cmd>ObsidianNew<cr>", desc = "New note" },
    { "<leader>ot", "<cmd>ObsidianTemplate<cr>", desc = "Insert template" },
    { "<leader>os", "<cmd>ObsidianSearch<cr>", desc = "Search vault" },
    { "<leader>oq", "<cmd>ObsidianQuickSwitch<cr>", desc = "Quick switch" },
    { "<leader>ob", "<cmd>ObsidianBacklinks<cr>", desc = "Backlinks" },
    { "<leader>ol", "<cmd>ObsidianLinks<cr>", desc = "Outgoing links" },
    { "<leader>of", "<cmd>ObsidianFollowLink<cr>", desc = "Follow link" },
    { "<leader>og", "<cmd>ObsidianTags<cr>", desc = "Browse tags" },
    { "<leader>or", "<cmd>ObsidianRename<cr>", desc = "Rename note" },
  },
}
