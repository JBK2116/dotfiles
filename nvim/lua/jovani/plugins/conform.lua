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
    local uv = vim.uv or vim.loop

    local DEBOUNCE_MS = 1000

    -- List the filetypes you want to EXCLUDE from automatic idle formatting
    local excluded_filetypes = {
      svelte = true,
    }

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
    })

    vim.keymap.set({ "n", "v" }, "<leader>cf", function()
      conform.format({
        lsp_format = "fallback",
        async = false,
        timeout_ms = 1000,
      })
    end, { desc = "Format file or range (in visual mode)" })

    -- Debounced autoformat (one timer per buffer)
    local timers = {} -- bufnr -> uv timer
    local last_tick = {} -- bufnr -> changedtick after last successful format

    local function format_buf(buf)
      if not vim.api.nvim_buf_is_valid(buf) or not vim.api.nvim_buf_is_loaded(buf) then
        return
      end
      if vim.bo[buf].buftype ~= "" or not vim.bo[buf].modifiable then
        return
      end
      if excluded_filetypes[vim.bo[buf].filetype] then
        return
      end
      -- Never reformat under the user's cursor while they're typing
      if vim.api.nvim_get_mode().mode:match("^[iR]") then
        return
      end
      -- Skip if nothing changed since the last format (prevents format loops)
      local tick = vim.api.nvim_buf_get_changedtick(buf)
      if last_tick[buf] == tick then
        return
      end

      conform.format({
        bufnr = buf,
        lsp_format = "fallback",
        async = true,
        quiet = true,
      }, function(err)
        if not err and vim.api.nvim_buf_is_valid(buf) then
          last_tick[buf] = vim.api.nvim_buf_get_changedtick(buf)
        end
      end)
    end

    local group = vim.api.nvim_create_augroup("ConformDebouncedFormat", { clear = true })

    vim.api.nvim_create_autocmd({ "TextChanged", "InsertLeave" }, {
      group = group,
      pattern = "*",
      callback = function(args)
        local buf = args.buf
        local timer = timers[buf]
        if not timer then
          timer = uv.new_timer()
          timers[buf] = timer
        end
        timer:stop()
        timer:start(
          DEBOUNCE_MS,
          0,
          vim.schedule_wrap(function()
            format_buf(buf)
          end)
        )
      end,
    })

    vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
      group = group,
      pattern = "*",
      callback = function(args)
        local timer = timers[args.buf]
        if timer then
          timer:stop()
          if not timer:is_closing() then
            timer:close()
          end
          timers[args.buf] = nil
        end
        last_tick[args.buf] = nil
      end,
    })
  end,
}
