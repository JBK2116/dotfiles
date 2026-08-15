-- Configures conform.nvim, the code formatter. Maps each filetype to its
-- formatter (prettier, stylua, ruff, clang-format, gofmt, ...), formats
-- automatically when the user stops typing (debounced, since init.lua
-- autosaves on InsertLeave/TextChanged), and exposes <leader>cf for manual
-- formatting.
return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local conform = require("conform")

    conform.setup({
      formatters_by_ft = {
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        svelte = { "prettier" },
        css = { "prettier" },
        html = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        graphql = { "prettier" },
        liquid = { "prettier" },
        lua = { "stylua" },
        python = { "ruff_format" },
        c = { "clang-format" },
        cpp = { "clang-format" },
        go = { "gofmt" },
      },
      -- NOTE: format_on_save is intentionally NOT set. init.lua autosaves on
      -- InsertLeave/TextChanged, so format_on_save would spawn a formatter on
      -- every one of those writes. Debounced idle formatting is set up below
      -- instead.
    })

    vim.keymap.set({ "n", "v" }, "<leader>cf", function()
      conform.format({
        lsp_format = "fallback",
        async = false,
        timeout_ms = 1000,
      })
    end, { desc = "Format file or range (in visual mode)" })

    -- Debounced auto-format: only run the formatters after the user has been
    -- idle for a while (i.e. stopped typing), instead of on every autosave.
    -- Idle means no TextChanged/InsertLeave for `debounce_ms`, and the buffer
    -- must already be saved (not modified) so we never race the autosave.
    local debounce_ms = 1500
    local pending = {} -- bufnr -> uv timer waiting to fire

    local function schedule_format(bufnr)
      local timer = pending[bufnr]
      if not timer or timer:is_closing() then
        timer = vim.uv.new_timer()
        if not timer then
          return
        end
        pending[bufnr] = timer
      end
      timer:start(debounce_ms, 0, function()
        timer:close()
        vim.schedule(function()
          -- A newer edit already re-armed a fresh timer; bail out.
          if pending[bufnr] ~= timer then
            return
          end
          pending[bufnr] = nil
          if not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_buf_is_loaded(bufnr) then
            return
          end
          -- Autosave hasn't caught up yet; the next TextChanged/InsertLeave
          -- restarts the timer, so wait another round.
          if vim.bo[bufnr].modified then
            schedule_format(bufnr)
            return
          end
          conform.format({
            bufnr = bufnr,
            lsp_format = "fallback",
            async = true,
            timeout_ms = 3000,
            quiet = true, -- no error spam during background formatting
          })
        end)
      end)
    end

    -- Same events as the autosave in init.lua: every edit restarts the
    -- debounce timer, so formatting only happens once typing pauses.
    vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
      desc = "Schedule debounced format with conform.nvim",
      callback = function(args)
        -- Skip buffers that conform has no formatter (or LSP) for.
        local formatters, use_lsp = conform.list_formatters_to_run(args.buf)
        if #formatters == 0 and not use_lsp then
          return
        end
        schedule_format(args.buf)
      end,
    })

    -- Cancel pending formats so a stale timer can never touch a buffer
    -- whose number got recycled.
    vim.api.nvim_create_autocmd("BufDelete", {
      desc = "Cancel pending conform.nvim format",
      callback = function(args)
        local timer = pending[args.buf]
        if timer and not timer:is_closing() then
          timer:stop()
          timer:close()
        end
        pending[args.buf] = nil
      end,
    })
  end,
}
