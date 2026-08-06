-- Configures Neogit, a Magit-style git interface. Defines <leader>g keymaps
-- for common operations (commit, pull, push, branch, rebase, stash, merge,
-- reset, tag) and tunes the status buffer, commit/rebase editors, diff
-- integration (via diffview.nvim), and the full set of in-buffer keybindings.
return {
  "NeogitOrg/neogit",
  lazy = true,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "sindrets/diffview.nvim",
    "folke/snacks.nvim",
  },
  cmd = "Neogit",
  keys = {
    { "<leader>gg", "<cmd>Neogit<cr>", desc = "Git: Open Neogit" },
    { "<leader>gc", "<cmd>Neogit commit<cr>", desc = "Git: Commit" },
    { "<leader>gp", "<cmd>Neogit pull<cr>", desc = "Git: Pull" },
    { "<leader>gP", "<cmd>Neogit push<cr>", desc = "Git: Push" },
    { "<leader>gb", "<cmd>Neogit branch<cr>", desc = "Git: Branch" },
    { "<leader>gR", "<cmd>Neogit rebase<cr>", desc = "Git: Rebase" },
    { "<leader>gz", "<cmd>Neogit stash<cr>", desc = "Git: Stash" },
    { "<leader>gm", "<cmd>Neogit merge<cr>", desc = "Git: Merge" },
    { "<leader>gx", "<cmd>Neogit reset<cr>", desc = "Git: Reset" },
    { "<leader>gt", "<cmd>Neogit tag<cr>", desc = "Git: Tag" },
  },
  opts = {
    -- UI
    kind = "tab",
    disable_hint = false,
    disable_line_numbers = true,
    disable_relative_line_numbers = true,
    disable_context_highlighting = false,
    disable_signs = false,
    graph_style = "unicode",
    process_spinner = false,
    auto_refresh = true,

    -- Safety prompts
    prompt_force_push = true,
    prompt_amend_commit = true,

    -- Commit editor behavior
    disable_insert_on_commit = "auto",
    commit_editor = {
      kind = "tab",
      show_staged_diff = true,
      staged_diff_split_kind = "split",
      spell_check = true,
    },

    -- Git settings
    sort_branches = "-committerdate",
    commit_order = "topo",

    -- File watcher
    filewatcher = {
      interval = 1000,
      enabled = true,
    },

    -- Console
    console_timeout = 2000,
    auto_show_console = true,
    auto_close_console = true,

    -- Diff integration — uses diffview.nvim for the diff popup and as the
    -- primary diff viewer (nil = auto-detect, picks diffview if installed).
    integrations = {
      snacks = true,
      diffview = true,
    },
    diff_viewer = "diffview",

    -- Highlight
    highlight = {
      italic = true,
      bold = true,
      underline = true,
    },

    -- Status buffer
    status = {
      show_head_commit_hash = true,
      recent_commit_count = 15,
      HEAD_padding = 10,
      HEAD_folded = false,
      mode_padding = 3,
      mode_text = {
        M = "modified",
        N = "new file",
        A = "added",
        D = "deleted",
        C = "copied",
        U = "updated",
        R = "renamed",
        T = "changed",
        DD = "unmerged",
        AU = "unmerged",
        UD = "unmerged",
        UA = "unmerged",
        DU = "unmerged",
        AA = "unmerged",
        UU = "unmerged",
        ["?"] = "",
      },
    },

    -- Section fold state
    sections = {
      sequencer = { folded = false, hidden = false },
      untracked = { folded = false, hidden = false },
      unstaged = { folded = false, hidden = false },
      staged = { folded = false, hidden = false },
      stashes = { folded = true, hidden = false },
      unpulled_upstream = { folded = true, hidden = false },
      unmerged_upstream = { folded = false, hidden = false },
      unpulled_pushRemote = { folded = true, hidden = false },
      unmerged_pushRemote = { folded = false, hidden = false },
      recent = { folded = false, hidden = false },
      rebase = { folded = true, hidden = false },
    },

    -- View kinds
    commit_select_view = { kind = "tab" },
    commit_view = { kind = "vsplit", verify_commit = vim.fn.executable("gpg") == 1 },
    log_view = { kind = "tab" },
    rebase_editor = { kind = "auto" },
    reflog_view = { kind = "tab" },
    merge_editor = { kind = "auto" },
    preview_buffer = { kind = "floating_console" },
    popup = { kind = "split" },
    stash = { kind = "tab" },
    refs_view = { kind = "tab" },

    -- Floating window
    floating = {
      relative = "editor",
      width = 0.85,
      height = 0.75,
      style = "minimal",
      border = "rounded",
    },

    signs = {
      hunk = { "", "" },
      item = { ">", "v" },
      section = { ">", "v" },
    },

    -- Internal keymaps (inside Neogit buffers)
    use_default_keymaps = true,
    mappings = {
      commit_editor = {
        ["q"] = "Close",
        ["<c-c><c-c>"] = "Submit",
        ["<c-c><c-k>"] = "Abort",
        ["<m-p>"] = "PrevMessage",
        ["<m-n>"] = "NextMessage",
        ["<m-r>"] = "ResetMessage",
      },
      commit_editor_I = {
        ["<c-c><c-c>"] = "Submit",
        ["<c-c><c-k>"] = "Abort",
      },
      rebase_editor = {
        ["p"] = "Pick",
        ["r"] = "Reword",
        ["e"] = "Edit",
        ["s"] = "Squash",
        ["f"] = "Fixup",
        ["x"] = "Execute",
        ["d"] = "Drop",
        ["b"] = "Break",
        ["q"] = "Close",
        ["<cr>"] = "OpenCommit", -- Enter
        ["gk"] = "MoveUp",
        ["gj"] = "MoveDown",
        ["<c-c><c-c>"] = "Submit",
        ["<c-c><c-k>"] = "Abort",
        ["[c]"] = "OpenOrScrollUp",
        ["]c"] = "OpenOrScrollDown",
      },
      rebase_editor_I = {
        ["<c-c><c-c>"] = "Submit",
        ["<c-c><c-k>"] = "Abort",
      },
      finder = {
        ["<cr>"] = "Select", -- Enter
        ["<c-c>"] = "Close",
        ["<esc>"] = "Close",
        ["<c-n>"] = "Next",
        ["<c-p>"] = "Previous",
        ["<down>"] = "Next",
        ["<up>"] = "Previous",
        ["<tab>"] = "InsertCompletion",
        ["<c-y>"] = "CopySelection",
        ["<space>"] = "MultiselectToggleNext",
        ["<s-space>"] = "MultiselectTogglePrevious",
        ["<c-j>"] = "NOP",
        ["<ScrollWheelDown>"] = "ScrollWheelDown",
        ["<ScrollWheelUp>"] = "ScrollWheelUp",
        ["<LeftMouse>"] = "MouseClick",
      },
      popup = {
        ["?"] = "HelpPopup",
        ["A"] = "CherryPickPopup",
        ["d"] = "DiffPopup",
        ["M"] = "RemotePopup",
        ["P"] = "PushPopup",
        ["X"] = "ResetPopup",
        ["Z"] = "StashPopup",
        ["i"] = "IgnorePopup",
        ["t"] = "TagPopup",
        ["b"] = "BranchPopup",
        ["B"] = "BisectPopup",
        ["w"] = "WorktreePopup",
        ["c"] = "CommitPopup",
        ["f"] = "FetchPopup",
        ["l"] = "LogPopup",
        ["m"] = "MergePopup",
        ["p"] = "PullPopup",
        ["r"] = "RebasePopup",
        ["v"] = "RevertPopup",
      },
      status = {
        ["j"] = "MoveDown",
        ["k"] = "MoveUp",
        ["o"] = "OpenTree",
        ["q"] = "Close",
        ["I"] = "InitRepo",
        ["1"] = "Depth1",
        ["2"] = "Depth2",
        ["3"] = "Depth3",
        ["4"] = "Depth4",
        ["Q"] = "Command",
        ["<tab>"] = "Toggle", -- Tab
        ["za"] = "Toggle",
        ["zo"] = "OpenFold",
        ["x"] = "Discard",
        ["s"] = "Stage",
        ["S"] = "StageUnstaged",
        ["<c-s>"] = "StageAll", -- Ctrl+S
        ["u"] = "Unstage",
        ["K"] = "Untrack",
        ["U"] = "UnstageStaged",
        ["y"] = "ShowRefs",
        ["$"] = "CommandHistory",
        ["Y"] = "YankSelected",
        ["gp"] = "GoToParentRepo",
        ["<c-r>"] = "RefreshBuffer", -- Ctrl+R
        ["<cr>"] = "GoToFile", -- Enter
        ["<s-cr>"] = "PeekFile", -- Shift+Enter
        ["<c-v>"] = "VSplitOpen", -- Ctrl+V
        ["<c-x>"] = "SplitOpen", -- Ctrl+X
        ["<c-t>"] = "TabOpen", -- Ctrl+T
        ["{"] = "GoToPreviousHunkHeader",
        ["}"] = "GoToNextHunkHeader",
        ["[c"] = "OpenOrScrollUp",
        ["]c"] = "OpenOrScrollDown",
        ["<c-k>"] = "PeekUp", -- Ctrl+K
        ["<c-j>"] = "PeekDown", -- Ctrl+J
        ["<c-n>"] = "NextSection", -- Ctrl+N
        ["<c-p>"] = "PreviousSection", -- Ctrl+P
      },
    },
  },
}
