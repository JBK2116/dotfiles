-- Snacks.nvim now acts as a utility/helper layer only. Provides the
-- dashboard, scope, bigfile handling, dim, git browse, LSP rename,
-- statuscolumn, and <leader>u toggles.  All fuzzy-picking (files,
-- grep, LSP, buffers, colorschemes) lives in fzf-lua.
--
return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    bigfile = { enabled = true },
    dashboard = {
      enabled = false,
      sections = {
        { section = "header" },
        { section = "keys", gap = 1, padding = 1 },
      },
    },
    dim = {
      enabled = true,
      scope = {
        min_size = 5,
        max_size = 20,
        siblings = true,
      },
    },
    explorer = { enabled = false },
    gh = { enabled = false },
    gitbrowse = { enabled = true, what = "permalink" },
    picker = {
      enabled = true,
      ---@type snacks.picker.matcher.Config
      matcher = {
        fuzzy = true,
        smartcase = true,
        ignorecase = true,
        filename_bonus = true, -- matches in the filename get scored higher
        cwd_bonus = true, -- files inside the current working directory rank higher
        frecency = true, -- files you open often or recently bubble up
        sort_empty = true, -- sort results even when search is empty
        file_pos = true,
      },
      layout = {
        preset = "default",
      },
      win = {
        input = {
          keys = {
            ["<C-c>"] = { "close", mode = { "i", "n" } },
          },
        },
      },
      formatters = {
        file = {
          filename_first = true,
        },
      },
    },
    quickfile = { enabled = true },
    rename = { enabled = true },
    scratch = { enabled = false },
    scope = { enabled = true },
    scroll = { enabled = false },
    statuscolumn = {
      enabled = true,
      left = { "sign" },
      right = { "fold", "git" },
      folds = {
        open = false,
        git_hl = true,
      },
    },
    styles = {
      notification = {
        -- wo = { wrap = true } -- Wrap notifications
      },
    },
  },
  keys = {
    -- Buffer management (uses bufdelete.nvim, not snacks.bufdelete)
    {
      "<leader>bd",
      function()
        local ok, bd = pcall(require, "bufdelete")
        if ok then
          bd.bufdelete(vim.fn.bufnr("%"), false)
        else
          vim.cmd.bdelete()
        end
      end,
      desc = "Delete Buffer (keeps undo)",
    },
    {
      "<leader>bD",
      function()
        local ok, bd = pcall(require, "bufdelete")
        if ok then
          bd.bufdelete(vim.fn.bufnr("%"), true)
        else
          vim.cmd.bwipeout()
        end
      end,
      desc = "Wipe Buffer (nuke undo too)",
    },
    {
      "<leader>bj",
      function()
        vim.cmd("BufWipeJunk")
      end,
      desc = "Wipe Junk Buffers",
    },
    -- Git Browse
    {
      "<leader>gB",
      function()
        Snacks.gitbrowse()
      end,
      desc = "Git Browse (open in browser)",
    },
    -- Rename
    {
      "<leader>cr",
      function()
        Snacks.rename.rename_file()
      end,
      desc = "Rename File (LSP)",
    },
  },
  init = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        -- Setup some globals for debugging (lazy-loaded)
        _G.dd = function(...)
          Snacks.debug.inspect(...)
        end
        _G.bt = function()
          Snacks.debug.backtrace()
        end

        -- Override print to use snacks for `:=` command
        if vim.fn.has("nvim-0.11") == 1 then
          vim._print = function(_, ...)
            dd(...)
          end
        else
          vim.print = _G.dd
        end

        -- Create some toggle mappings
        Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
        Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
        Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
        Snacks.toggle.diagnostics():map("<leader>ud")
        Snacks.toggle.line_number():map("<leader>ul")
        Snacks.toggle
          .option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
          :map("<leader>uc")
        Snacks.toggle.treesitter():map("<leader>uT")
        Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
        Snacks.toggle.inlay_hints():map("<leader>uh")
        Snacks.toggle.dim():map("<leader>uD")

        -- Indent guide toggle uses blink.indent (not snacks.indent)
        vim.keymap.set("n", "<leader>ug", function()
          local ok, indent = pcall(require, "blink.indent")
          if ok then
            indent.enable(not indent.is_enabled())
            vim.notify("Indent Guides: " .. (indent.is_enabled() and "on" or "off"))
          end
        end, { desc = "Toggle Indent Guides" })
      end,
    })
  end,
}
