-- diffview.nvim: view-only git diff / history. Commits etc. happen in lazygit.
-- Inside a diffview, press g? for keymaps.

local function toggle(cmd)
  if next(require("diffview.lib").views) == nil then
    vim.cmd(cmd)
  else
    vim.cmd("DiffviewClose")
  end
end

-- Theme-derived diff colors: blend semantic colors into the Normal background
-- so they work on any colorscheme instead of hardcoded hex.
local function hl_color(group, attr)
  return vim.api.nvim_get_hl(0, { name = group, link = false })[attr]
end

local function mix(a, b, t) -- t = share of `a`
  local function ch(n, shift)
    return bit.band(bit.rshift(n, shift), 0xff)
  end
  local function m(shift)
    return math.floor(ch(a, shift) * t + ch(b, shift) * (1 - t) + 0.5)
  end
  return string.format("#%02x%02x%02x", m(16), m(8), m(0))
end

local function set_diff_hl()
  local base = hl_color("Normal", "bg")
  if not base then
    return -- transparent theme: keep diffview's defaults
  end
  local add = hl_color("DiagnosticOk", "fg") or 0x98c379
  local del = hl_color("DiagnosticError", "fg") or 0xe06c75
  local info = hl_color("DiagnosticInfo", "fg") or 0x61afef
  local text = hl_color("Normal", "fg") or 0x888888

  local set = vim.api.nvim_set_hl
  set(0, "DiffviewDiffAdd", { bg = mix(add, base, 0.18) }) -- added lines
  set(0, "DiffviewDiffAddAsDelete", { bg = mix(del, base, 0.18) }) -- removed lines (old side)
  set(0, "DiffviewDiffChange", { bg = mix(info, base, 0.12) }) -- modified lines
  set(0, "DiffviewDiffText", { bg = mix(info, base, 0.38) }) -- changed words
  set(0, "DiffviewDiffDelete", { fg = mix(text, base, 0.2) }) -- filler rows
end

return {
  "sindrets/diffview.nvim",
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
  config = function(_, opts)
    require("diffview").setup(opts)

    -- Better alignment inside changed hunks, cleaner hunk boundaries.
    vim.opt.diffopt:append({ "linematch:60", "algorithm:histogram", "indent-heuristic" })

    set_diff_hl()
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = vim.api.nvim_create_augroup("DiffviewHighlights", { clear = true }),
      -- schedule so we run after diffview re-links its own groups
      callback = function()
        vim.schedule(set_diff_hl)
      end,
    })
  end,
  opts = {
    enhanced_diff_hl = true, -- enables the DiffviewDiff* groups above

    view = {
      default = { disable_diagnostics = true },
      merge_tool = { layout = "diff3_horizontal", disable_diagnostics = true },
      file_history = { disable_diagnostics = true },
    },

    file_history_panel = {
      log_options = {
        git = {
          single_file = { diff_merges = "combined" },
          multi_file = { diff_merges = "first-parent" },
        },
      },
    },

    hooks = {
      diff_buf_read = function()
        vim.opt_local.wrap = false
        vim.opt_local.list = false
        vim.opt_local.colorcolumn = ""
      end,
      diff_buf_win_enter = function()
        vim.opt_local.fillchars:append({ diff = "╱" }) -- soft hatch for filler rows
      end,
    },

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
