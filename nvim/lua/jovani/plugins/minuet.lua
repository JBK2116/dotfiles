-- AI autocomplete via minuet-ai.nvim using DeepSeek (FIM completion).
-- Set env var: export DEEPSEEK_API_KEY=sk-xxxx
return {
  "milanglacier/minuet-ai.nvim",
  event = "VeryLazy",
  config = function()
    vim.keymap.set("i", "<Tab>", function()
      if require("minuet.virtualtext").action.is_visible() then
        require("minuet.virtualtext").action.accept()
        return ""
      end
      return vim.api.nvim_replace_termcodes("<Tab>", true, false, true)
    end, { expr = true, desc = "Minuet accept / Tab" })

    require("minuet").setup({
      provider = "openai_fim_compatible",

      virtualtext = {
        auto_trigger_ft = { "*" },
        auto_trigger_ignore_ft = { "help", "TelescopePrompt", "snacks_picker" },
        keymap = {
          accept = "<A-A>",
          accept_line = "<A-a>",
          accept_n_lines = "<A-z>",
          prev = "<A-[>",
          next = "<A-]>",
          dismiss = "<A-e>",
        },
      },

      provider_options = {
        openai_fim_compatible = {
          api_key = "DEEPSEEK_API_KEY",
          name = "DeepSeek",
          end_point = "https://api.deepseek.com/beta/completions",
          model = "deepseek-chat",
          optional = {
            max_tokens = 256,
            top_p = 0.9,
          },
        },
      },

      -- FIM models want a small, tight context window for speed.
      context_window = 16000,
      throttle = 1000,
      debounce = 400,
      request_timeout = 3,
      notify = "warn",
    })
  end,
}
