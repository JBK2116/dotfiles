-- AI inline code completion via minuet-ai.nvim.
-- Uses DeepSeek V4-Flash via the FIM (Fill-in-the-Middle) endpoint for
-- minimal latency. Renders completions as virtual text (ghost text) —
-- no cmp/blink overhead, line-by-line accept, instant display.
--
-- Speed optimisations:
--   • FIM endpoint (no prompt template, no few-shots, no system prompt)
--   • debounce = 0 (fire immediately on pause)
--   • throttle = 0 (no artificial gap between requests)
--   • context_window = 1024 (small payload = fast tokenisation + inference)
--   • n_completions = 1 (model stops sooner)
--   • stream = true (tokens appear incrementally)
--   • max_tokens = 64 (short completions only)

return {
  "milanglacier/minuet-ai.nvim",

  event = "InsertEnter",

  dependencies = {
    "nvim-lua/plenary.nvim", -- already installed, shared with code-companion
  },

  opts = {
    provider = "openai_fim_compatible",

    -- Speed
    debounce = 0,
    throttle = 0,
    context_window = 1024,
    n_completions = 1,
    request_timeout = 2,
    stream = true,
    notify = "error", -- only show errors, not status spam
    add_single_line_entry = false, -- irrelevant for virtual text

    -- Provider
    provider_options = {
      openai_fim_compatible = {
        model = "deepseek-v4-flash",
        end_point = "https://api.deepseek.com/beta/completions",
        api_key = "DEEPSEEK_API_KEY",
        name = "Deepseek",
        optional = {
          max_tokens = 64,
          stop = nil,
        },
      },
    },

    -- Virtual text frontend
    virtualtext = {
      auto_trigger_ft = { "*" },
      show_on_completion_menu = false,

      keymap = {
        -- Accept the full completion
        accept = "<A-a>",
        -- Accept only the first line of a multi-line completion
        accept_line = "<A-l>",
        -- Accept N lines (prompts for a number)
        accept_n_lines = "<A-z>",
        -- Cycle to next / previous completion, or manually invoke
        next = "<A-]>",
        prev = "<A-[>",
        -- Dismiss the current suggestion
        dismiss = "<A-e>",
      },
    },
  },

  -- The FileType autocmd won't fire for already-open buffers, so we must
  -- manually enable auto-trigger for the current buffer after setup.
  config = function(plugin, opts)
    require("minuet").setup(opts)

    -- Enable auto-trigger for the buffer that triggered the InsertEnter event.
    local ft = vim.bo.filetype
    if ft ~= "" then
      local auto_ft = opts.virtualtext.auto_trigger_ft
      local ignore_ft = opts.virtualtext.auto_trigger_ignore_ft or {}
      if vim.tbl_contains(auto_ft, "*") or vim.tbl_contains(auto_ft, ft) then
        if not vim.tbl_contains(ignore_ft, ft) then
          vim.b.minuet_virtual_text_auto_trigger = true
        end
      end
    end
  end,
}
