-- Declares the available colorschemes (everforest, rose-pine, kanagawa,
-- onedark, github-theme, onedarkpro) and their per-theme settings. The
-- everforest spec also persists the active colorscheme to disk and restores
-- it on startup, so theme changes survive across sessions.
return {
  {
    "sainnhe/everforest",
    lazy = true,
    priority = 1000,
    init = function()
      local save_enabled = false

      -- Save colorscheme to disk whenever it changes (only after startup)
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
          if not save_enabled then
            return
          end
          local f = io.open(vim.fn.stdpath("data") .. "/colorscheme.txt", "w")
          if f then
            f:write(vim.g.colors_name)
            f:close()
          end
        end,
      })

      -- Restore saved colorscheme on startup, then enable saving
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          local f = io.open(vim.fn.stdpath("data") .. "/colorscheme.txt", "r")
          if f then
            local cs = f:read("*l")
            f:close()
            if cs and cs ~= "" then
              -- Defer so lazy.nvim has time to wire up lazy-loading
              -- for the colorscheme plugin before we try to set it.
              vim.schedule(function()
                vim.cmd("colorscheme " .. cs)
              end)
            end
          end
          -- Enable saving only after restore is done, so the default
          -- colorscheme set during startup doesn't overwrite the user's pick.
          save_enabled = true
        end,
      })
    end,
    config = function()
      vim.g.everforest_background = "hard"
      vim.g.everforest_enable_italic = 1
      vim.g.everforest_better_performance = 1
      vim.g.everforest_dim_inactive_windows = 1
      vim.o.background = "dark"
    end,
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = true,
    config = function()
      require("rose-pine").setup({
        variant = "moon",
        dark_variant = "moon",
        dim_inactive_windows = false,
        extend_background_behind_borders = true,
        enable = {
          terminal = true,
          legacy_highlights = true,
          migrations = true,
        },
        styles = {
          bold = true,
          italic = true,
          transparency = false,
        },
        groups = {
          border = "muted",
          link = "iris",
          panel = "surface",
          error = "love",
          hint = "iris",
          info = "foam",
          note = "pine",
          todo = "rose",
          warn = "gold",
          git_add = "foam",
          git_change = "rose",
          git_delete = "love",
          git_dirty = "rose",
          git_ignore = "muted",
          git_merge = "iris",
          git_rename = "pine",
          git_stage = "iris",
          git_text = "rose",
          git_untracked = "subtle",
          h1 = "iris",
          h2 = "foam",
          h3 = "rose",
          h4 = "gold",
          h5 = "pine",
          h6 = "foam",
        },
      })
    end,
  },
  {
    "rebelot/kanagawa.nvim",
    lazy = true,
    priority = 1000,
    config = function()
      require("kanagawa").setup({
        compile = false,
        undercurl = true,
        commentStyle = { italic = true },
        functionStyle = {},
        keywordStyle = { italic = true },
        statementStyle = { bold = true },
        typeStyle = {},
        transparent = false,
        dimInactive = true,
        terminalColors = true,

        theme = "wave",

        background = {
          dark = "wave",
          light = "lotus",
        },

        colors = {
          theme = {
            all = {
              ui = {
                bg_gutter = "none",
              },
            },
          },
        },

        overrides = function(colors)
          local theme = colors.theme

          return {
            NormalFloat = { bg = "none" },
            FloatBorder = { bg = "none" },
            FloatTitle = { bg = "none" },

            NormalDark = {
              fg = theme.ui.fg_dim,
              bg = theme.ui.bg_m3,
            },

            LazyNormal = {
              bg = theme.ui.bg_m3,
              fg = theme.ui.fg_dim,
            },

            MasonNormal = {
              bg = theme.ui.bg_m3,
              fg = theme.ui.fg_dim,
            },

            TelescopeTitle = {
              fg = theme.ui.special,
              bold = true,
            },

            TelescopePromptNormal = {
              bg = theme.ui.bg_p1,
            },

            TelescopePromptBorder = {
              fg = theme.ui.bg_p1,
              bg = theme.ui.bg_p1,
            },

            TelescopeResultsNormal = {
              fg = theme.ui.fg_dim,
              bg = theme.ui.bg_m1,
            },

            TelescopeResultsBorder = {
              fg = theme.ui.bg_m1,
              bg = theme.ui.bg_m1,
            },

            TelescopePreviewNormal = {
              bg = theme.ui.bg_dim,
            },

            TelescopePreviewBorder = {
              bg = theme.ui.bg_dim,
              fg = theme.ui.bg_dim,
            },

            Pmenu = {
              fg = theme.ui.shade0,
              bg = theme.ui.bg_p1,
            },

            PmenuSel = {
              fg = "NONE",
              bg = theme.ui.bg_p2,
            },

            PmenuSbar = {
              bg = theme.ui.bg_m1,
            },

            PmenuThumb = {
              bg = theme.ui.bg_p2,
            },
          }
        end,
      })
    end,
  },
  {
    "navarasu/onedark.nvim",
    lazy = true,
    priority = 1000,
    config = function()
      require("onedark").setup({
        style = "darker",
        transparent = false,
        term_colors = true,
        code_style = {
          comments = "italic",
          keywords = "none",
          functions = "none",
          strings = "none",
          variables = "none",
        },
        diagnostics = {
          darker = true,
          undercurl = true,
          background = true,
        },
      })
    end,
  },
  {
    "projekt0n/github-nvim-theme",
    name = "github-theme",
    lazy = false,
    priority = 1000,
    config = function()
      require("github-theme").setup({
        -- ...
      })

      vim.cmd("colorscheme github_dark_default")
    end,
  },
  {
    "EdenEast/nightfox.nvim",
    lazy = true,
    priority = 1000,
  },
  {
    "scottmckendry/cyberdream.nvim",
    lazy = true,
    priority = 1000,
  },
  {
    "sainnhe/sonokai",
    lazy = true,
    priority = 1000,
  },
  -- Add more colorscheme tables from below here. Snacks automatically picks it up
}
