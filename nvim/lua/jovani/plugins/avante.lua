-- Avante: Cursor-style AI sidebar for Neovim, running on DeepSeek V4.
-- V4-Pro for chat/edits, V4-Flash for cheap background work (summaries).
-- Needs DEEPSEEK_API_KEY (and BRAVE_API_KEY for web search) in your env.
return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  version = false, -- always track latest; avante moves fast
  build = "make",

  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-treesitter/nvim-treesitter",
    "folke/snacks.nvim",
  },

  opts = {
    provider = "deepseek",
    memory_summary_provider = "deepseek-flash",
    instructions_file = "AGENTS.md", -- reuse your existing project rules

    providers = {
      deepseek = {
        __inherited_from = "openai",
        api_key_name = "DEEPSEEK_API_KEY",
        endpoint = "https://api.deepseek.com",
        model = "deepseek-v4-pro",
        timeout = 60000, -- reasoning model, give it room
        extra_request_body = {
          max_tokens = 8192, -- use max_tokens, DeepSeek rejects max_completion_tokens
        },
      },
      ["deepseek-flash"] = {
        __inherited_from = "openai",
        api_key_name = "DEEPSEEK_API_KEY",
        endpoint = "https://api.deepseek.com",
        model = "deepseek-v4-flash",
        timeout = 30000,
        extra_request_body = {
          max_tokens = 8192,
        },
      },
    },

    web_search_engine = {
      provider = "brave",
    },

    behaviour = {
      auto_suggestions = false, -- ghost-text completions burn tokens; off
      auto_apply_diff_after_generation = false,
      auto_set_keymaps = true,
      minimize_diff = true,
    },

    selector = { provider = "snacks" },
    input = { provider = "snacks" },

    windows = {
      position = "right",
      width = 35,
      sidebar_header = { rounded = false },
    },

    -- Your old prompt library. Type #name in the Avante input to use one.
    shortcuts = {
      {
        name = "explain",
        description = "Explain code",
        prompt = "Explain what this code does, how it works, and any notable patterns, risks, or non-obvious behavior. Skip restating the obvious.",
      },
      {
        name = "review",
        description = "Code review",
        prompt = "Review this code like a senior engineer. Flag real bugs, security issues, and violations of this codebase's conventions. No praise, no generic trivia. Reference specific lines.",
      },
      {
        name = "tests",
        description = "Write tests",
        prompt = "Write unit tests matching this project's existing test framework, assertion style, and naming conventions. Cover normal, edge, and error cases. No trivial tests, no TODO stubs.",
      },
      {
        name = "optimize",
        description = "Optimize code",
        prompt = "Optimize this code for performance and readability. Preserve existing style exactly and add no new dependencies.",
      },
      {
        name = "docs",
        description = "Add docstrings",
        prompt = "Add docstrings matching this file's existing docstring convention. Skip anything already well documented. No boilerplate.",
      },
      {
        name = "fix",
        description = "Fix diagnostics",
        prompt = "Fix all LSP diagnostics in this file with the minimal correct change. Don't refactor unrelated code.",
      },
    },
  },
}
