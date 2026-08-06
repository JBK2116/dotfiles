-- Python debug adapter for nvim-dap.
-- Uses debugpy (Microsoft) under the hood — the same debugger VS Code uses.
-- The setup() call registers the adapter and default launch/attach
-- configurations, so your generic DAP keymaps (<leader>dc, <leader>do, …)
-- work out of the box.  debugpy itself is auto-installed by Mason (see
-- lsp/mason.lua).
return {
  {
    "mfussenegger/nvim-dap-python",
    ft = "python",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      -- Mason installs debugpy into its own virtualenv, so use that Python
      -- binary so debugpy is always importable regardless of the active
      -- project venv.
      local debugpy_python = vim.fn.expand("~/.local/share/nvim/mason/packages/debugpy/venv/bin/python")
      require("dap-python").setup(debugpy_python)

      -- Framework launch configs (appended to defaults from nvim-dap-python).
      -- Each uses a runtime-resolved Python path so framework packages
      -- (uvicorn, django, flask) are found in the project's venv, not Mason's.
      local dap = require("dap")
      local function project_python()
        local venv = vim.fn.getcwd() .. "/.venv/bin/python"
        if vim.fn.executable(venv) == 1 then
          return venv
        end
        return vim.fn.exepath("python3") or vim.fn.exepath("python")
      end

      table.insert(dap.configurations.python, {
        type = "python",
        request = "launch",
        name = "Django (runserver)",
        program = "${workspaceFolder}/manage.py",
        args = { "runserver" },
        django = true,
        python = project_python,
      })
      table.insert(dap.configurations.python, {
        type = "python",
        request = "launch",
        name = "FastAPI (uvicorn)",
        module = "uvicorn",
        args = { "main:app" },
        python = project_python,
      })
      table.insert(dap.configurations.python, {
        type = "python",
        request = "launch",
        name = "Flask",
        module = "flask",
        args = { "run" },
        python = project_python,
      })
    end,
  },
}
