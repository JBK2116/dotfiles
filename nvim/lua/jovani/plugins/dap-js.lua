-- JavaScript / TypeScript debug adapter for nvim-dap.
-- Uses microsoft/vscode-js-debug via Mason (js-debug-adapter) — the same
-- debugger that powers VS Code's JS/TS debugging.  nvim-dap-vscode-js
-- bridges it into nvim-dap, registering the pwa-node adapter (Node.js),
-- pwa-chrome (browser), node-terminal, plus default launch/attach
-- configurations for both javascript and typescript filetypes.
-- Your generic DAP keymaps (<leader>dc, <leader>do, …) work immediately.
return {
  {
    "mxsdev/nvim-dap-vscode-js",
    ft = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      local dap = require("dap")

      require("dap-vscode-js").setup({
        -- Point at Mason's pre-built js-debug-adapter installation
        debugger_path = vim.fn.resolve(vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter"),
        adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal" },
      })

      -- Register per-filetype debug configurations
      for _, lang in ipairs({ "typescript", "javascript" }) do
        dap.configurations[lang] = {
          {
            type = "pwa-node",
            request = "launch",
            name = "Launch file",
            program = "${file}",
            cwd = "${workspaceFolder}",
          },
          {
            type = "pwa-node",
            request = "launch",
            name = "SvelteKit dev",
            program = "${workspaceFolder}/node_modules/.bin/vite",
            args = { "dev" },
            cwd = "${workspaceFolder}",
          },
          {
            type = "pwa-node",
            request = "attach",
            name = "Attach to process",
            processId = require("dap.utils").pick_process,
            cwd = "${workspaceFolder}",
          },
        }
      end
    end,
  },
}
