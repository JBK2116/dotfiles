-- diffview.nvim — single-tabpage git diff & file history viewer.
-- All git execution (commit, push, rebase, etc.) is done via lazygit in tmux.
-- This plugin is purely for viewing: current worktree diff, file history,
-- repo history, and arbitrary rev comparisons.
--
-- Inside a diffview, press g? for all available keymaps.

local function toggle(cmd)
  if next(require("diffview.lib").views) == nil then
    vim.cmd(cmd)
  else
    vim.cmd("DiffviewClose")
  end
end

return {
  "sindrets/diffview.nvim",
  lazy = true,
  cmd = {
    "DiffviewOpen",
    "DiffviewFileHistory",
    "DiffviewClose",
    "DiffviewToggleFiles",
    "DiffviewFocusFiles",
    "DiffviewRefresh",
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  keys = {
    {
      "<leader>gd",
      function()
        toggle("DiffviewOpen")
      end,
      desc = "Git: Toggle worktree diff",
    },
    {
      "<leader>gD",
      function()
        toggle("DiffviewOpen HEAD~1")
      end,
      desc = "Git: Toggle diff against HEAD~1",
    },
    {
      "<leader>gf",
      function()
        toggle("DiffviewFileHistory %")
      end,
      desc = "Git: Toggle file history",
    },
    {
      "<leader>gF",
      function()
        toggle("DiffviewFileHistory")
      end,
      desc = "Git: Toggle repo history",
    },
  },
  opts = {
    -- Better syntax highlighting in diff buffers
    enhanced_diff_hl = true,

    -- File icons in the file panel (nvim-web-devicons)
    use_icons = true,

    -- Show keymap hints until you learn them
    show_help_hints = true,

    -- Signs in the sign column
    signs = {
      fold_closed = "",
      fold_open = "",
      done = "✓",
    },

    -- Default view layout: side-by-side diff
    view = {
      default = {
        layout = "diff2_horizontal",
      },
      merge_tool = {
        layout = "diff3_horizontal",
        disable_diagnostics = true,
      },
      file_history = {
        layout = "diff2_horizontal",
      },
    },

    -- File panel: tree-style listing on the left
    file_panel = {
      listing_style = "tree",
      win_config = {
        position = "left",
        width = 35,
      },
    },

    -- File history panel
    file_history_panel = {
      listing_style = "tree",
      win_config = {
        position = "bottom",
        height = 16,
      },
    },

    -- Hooks for per-buffer customization
    hooks = {
      diff_buf_read = function(bufnr)
        vim.opt_local.wrap = false
        vim.opt_local.list = false
        vim.opt_local.colorcolumn = ""
        local bufname = vim.api.nvim_buf_get_name(bufnr)
        -- skip detaching if this is a normal file buffer, not a git-blob scratch buffer
        if bufname:match("^diffview://") then
          for _, client in pairs(vim.lsp.get_clients({ bufnr = bufnr })) do
            vim.lsp.buf_detach_client(bufnr, client.id)
          end
        end
      end,
    },

    -- Consistent close behavior: q closes the whole diffview
    keymaps = {
      view = {
        { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
      },
      file_panel = {
        { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
        { "n", "<esc>", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
      },
      file_history_panel = {
        { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
        { "n", "<esc>", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
      },
    },
  },
}
