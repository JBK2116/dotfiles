-- Configures nvim-treesitter and nvim-treesitter-textobjects together.
-- Uses the new nvim-treesitter API for parser installation, highlighting,
-- indentation, and folding. Textobjects (select, swap, move) are wired via
-- nvim-treesitter-textobjects directly, with repeatable moves via ; and ,.
return {
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPre", "BufNewFile" },
    build = ":TSUpdate",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
      require("nvim-treesitter").setup({
        ensure_installed = {
          "lua",
          "python",
          "javascript",
          "typescript",
          "tsx",
          "rust",
          "go",
          "zig",
          "svelte",
          "vim",
          "vimdoc",
          "query",
          "bash",
          "json",
          "yaml",
          "toml",
          "markdown",
          "java",
          "html",
          "xml",
          "css",
        },
        auto_install = true,
      })

      -- Setup config (move set_jumps here)
      require("nvim-treesitter-textobjects").setup({
        move = { set_jumps = true },
        select = { lookahead = true },
      })

      local select = require("nvim-treesitter-textobjects.select")
      local swap = require("nvim-treesitter-textobjects.swap")
      local move = require("nvim-treesitter-textobjects.move")

      -- Select
      local function sel(query, group)
        group = group or "textobjects"
        return function()
          select.select_textobject(query, group)
        end
      end

      vim.keymap.set({ "x", "o" }, "a=", sel("@assignment.outer"), { desc = "Select outer part of an assignment" })
      vim.keymap.set({ "x", "o" }, "i=", sel("@assignment.inner"), { desc = "Select inner part of an assignment" })
      vim.keymap.set({ "x", "o" }, "l=", sel("@assignment.lhs"), { desc = "Select left hand side of an assignment" })
      vim.keymap.set({ "x", "o" }, "r=", sel("@assignment.rhs"), { desc = "Select right hand side of an assignment" })

      vim.keymap.set({ "x", "o" }, "a:", sel("@property.outer"), { desc = "Select outer part of an object property" })
      vim.keymap.set({ "x", "o" }, "i:", sel("@property.inner"), { desc = "Select inner part of an object property" })
      vim.keymap.set({ "x", "o" }, "l:", sel("@property.lhs"), { desc = "Select left part of an object property" })
      vim.keymap.set({ "x", "o" }, "r:", sel("@property.rhs"), { desc = "Select right part of an object property" })

      vim.keymap.set(
        { "x", "o" },
        "aa",
        sel("@parameter.outer"),
        { desc = "Select outer part of a parameter/argument" }
      )
      vim.keymap.set(
        { "x", "o" },
        "ia",
        sel("@parameter.inner"),
        { desc = "Select inner part of a parameter/argument" }
      )

      vim.keymap.set({ "x", "o" }, "ai", sel("@conditional.outer"), { desc = "Select outer part of a conditional" })
      vim.keymap.set({ "x", "o" }, "ii", sel("@conditional.inner"), { desc = "Select inner part of a conditional" })

      vim.keymap.set({ "x", "o" }, "al", sel("@loop.outer"), { desc = "Select outer part of a loop" })
      vim.keymap.set({ "x", "o" }, "il", sel("@loop.inner"), { desc = "Select inner part of a loop" })

      vim.keymap.set({ "x", "o" }, "af", sel("@call.outer"), { desc = "Select outer part of a function call" })
      vim.keymap.set({ "x", "o" }, "if", sel("@call.inner"), { desc = "Select inner part of a function call" })

      vim.keymap.set(
        { "x", "o" },
        "am",
        sel("@function.outer"),
        { desc = "Select outer part of a method/function definition" }
      )
      vim.keymap.set(
        { "x", "o" },
        "im",
        sel("@function.inner"),
        { desc = "Select inner part of a method/function definition" }
      )

      vim.keymap.set({ "x", "o" }, "ac", sel("@class.outer"), { desc = "Select outer part of a class" })
      vim.keymap.set({ "x", "o" }, "ic", sel("@class.inner"), { desc = "Select inner part of a class" })

      -- Swap
      vim.keymap.set("n", "<leader>na", function()
        swap.swap_next("@parameter.inner")
      end, { desc = "Swap parameter/argument with next" })
      vim.keymap.set("n", "<leader>n:", function()
        swap.swap_next("@property.outer")
      end, { desc = "Swap object property with next" })
      vim.keymap.set("n", "<leader>nm", function()
        swap.swap_next("@function.outer")
      end, { desc = "Swap function with next" })

      vim.keymap.set("n", "<leader>pa", function()
        swap.swap_previous("@parameter.inner")
      end, { desc = "Swap parameter/argument with previous" })
      vim.keymap.set("n", "<leader>p:", function()
        swap.swap_previous("@property.outer")
      end, { desc = "Swap object property with previous" })
      vim.keymap.set("n", "<leader>pm", function()
        swap.swap_previous("@function.outer")
      end, { desc = "Swap function with previous" })

      -- Move
      vim.keymap.set({ "n", "x", "o" }, "]f", function()
        move.goto_next_start("@call.outer", "textobjects")
      end, { desc = "Next function call start" })
      vim.keymap.set({ "n", "x", "o" }, "]m", function()
        move.goto_next_start("@function.outer", "textobjects")
      end, { desc = "Next method/function def start" })
      vim.keymap.set({ "n", "x", "o" }, "]c", function()
        move.goto_next_start("@class.outer", "textobjects")
      end, { desc = "Next class start" })
      vim.keymap.set({ "n", "x", "o" }, "]i", function()
        move.goto_next_start("@conditional.outer", "textobjects")
      end, { desc = "Next conditional start" })
      vim.keymap.set({ "n", "x", "o" }, "]l", function()
        move.goto_next_start("@loop.outer", "textobjects")
      end, { desc = "Next loop start" })
      vim.keymap.set({ "n", "x", "o" }, "]s", function()
        move.goto_next_start("@local.scope", "locals")
      end, { desc = "Next scope" })
      vim.keymap.set({ "n", "x", "o" }, "]z", function()
        move.goto_next_start("@fold", "folds")
      end, { desc = "Next fold" })

      vim.keymap.set({ "n", "x", "o" }, "]F", function()
        move.goto_next_end("@call.outer", "textobjects")
      end, { desc = "Next function call end" })
      vim.keymap.set({ "n", "x", "o" }, "]M", function()
        move.goto_next_end("@function.outer", "textobjects")
      end, { desc = "Next method/function def end" })
      vim.keymap.set({ "n", "x", "o" }, "]C", function()
        move.goto_next_end("@class.outer", "textobjects")
      end, { desc = "Next class end" })
      vim.keymap.set({ "n", "x", "o" }, "]I", function()
        move.goto_next_end("@conditional.outer", "textobjects")
      end, { desc = "Next conditional end" })
      vim.keymap.set({ "n", "x", "o" }, "]L", function()
        move.goto_next_end("@loop.outer", "textobjects")
      end, { desc = "Next loop end" })

      vim.keymap.set({ "n", "x", "o" }, "[f", function()
        move.goto_previous_start("@call.outer", "textobjects")
      end, { desc = "Prev function call start" })
      vim.keymap.set({ "n", "x", "o" }, "[m", function()
        move.goto_previous_start("@function.outer", "textobjects")
      end, { desc = "Prev method/function def start" })
      vim.keymap.set({ "n", "x", "o" }, "[c", function()
        move.goto_previous_start("@class.outer", "textobjects")
      end, { desc = "Prev class start" })
      vim.keymap.set({ "n", "x", "o" }, "[i", function()
        move.goto_previous_start("@conditional.outer", "textobjects")
      end, { desc = "Prev conditional start" })
      vim.keymap.set({ "n", "x", "o" }, "[l", function()
        move.goto_previous_start("@loop.outer", "textobjects")
      end, { desc = "Prev loop start" })

      vim.keymap.set({ "n", "x", "o" }, "[F", function()
        move.goto_previous_end("@call.outer", "textobjects")
      end, { desc = "Prev function call end" })
      vim.keymap.set({ "n", "x", "o" }, "[M", function()
        move.goto_previous_end("@function.outer", "textobjects")
      end, { desc = "Prev method/function def end" })
      vim.keymap.set({ "n", "x", "o" }, "[C", function()
        move.goto_previous_end("@class.outer", "textobjects")
      end, { desc = "Prev class end" })
      vim.keymap.set({ "n", "x", "o" }, "[I", function()
        move.goto_previous_end("@conditional.outer", "textobjects")
      end, { desc = "Prev conditional end" })
      vim.keymap.set({ "n", "x", "o" }, "[L", function()
        move.goto_previous_end("@loop.outer", "textobjects")
      end, { desc = "Prev loop end" })

      -- Repeatable moves
      local ts_repeat_move = require("nvim-treesitter-textobjects.repeatable_move")
      vim.keymap.set(
        { "n", "x", "o" },
        ";",
        ts_repeat_move.repeat_last_move_next,
        { desc = "Repeat last move (same direction)" }
      )
      vim.keymap.set(
        { "n", "x", "o" },
        ",",
        ts_repeat_move.repeat_last_move_previous,
        { desc = "Repeat last move (opposite direction)" }
      )
      vim.keymap.set(
        { "n", "x", "o" },
        "f",
        ts_repeat_move.builtin_f_expr,
        { expr = true, desc = "Repeatable f (forward to char)" }
      )
      vim.keymap.set(
        { "n", "x", "o" },
        "F",
        ts_repeat_move.builtin_F_expr,
        { expr = true, desc = "Repeatable F (backward to char)" }
      )
      vim.keymap.set(
        { "n", "x", "o" },
        "t",
        ts_repeat_move.builtin_t_expr,
        { expr = true, desc = "Repeatable t (forward until char)" }
      )
      vim.keymap.set(
        { "n", "x", "o" },
        "T",
        ts_repeat_move.builtin_T_expr,
        { expr = true, desc = "Repeatable T (backward until char)" }
      )

      -- Treesitter-based indentation per filetype
      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "lua",
          "python",
          "javascript",
          "typescript",
          "tsx",
          "rust",
          "go",
          "zig",
          "vim",
          "bash",
          "json",
          "yaml",
          "toml",
          "markdown",
          "svelte",
          "java",
          "html",
          "xml",
          "css",
        },
        callback = function()
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          vim.wo.foldmethod = "expr"
          vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
          vim.wo.foldenable = false
        end,
      })
    end,
  },
}
