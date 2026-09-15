-- Disable netrw (nvim-tree replaces it)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("jovani.core.init")
require("jovani.lazy")
require("jovani.lsp")

-- Auto-save on insert leave or normal-mode text change
vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
  pattern = "*",
  command = "silent! write",
  nested = true,
})

-- Colortheme picker
if vim.fn.executable("recol") == 1 then
  local launch_interactive_mode = function()
    local width = math.floor(vim.o.columns * 0.75)
    local height = math.floor(vim.o.lines * 0.75)
    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(buf, true, {
      relative = "editor",
      width = width,
      height = height,
      row = math.floor((vim.o.lines - height - 3) / 2),
      col = math.floor((vim.o.columns - width) / 2),
      border = "rounded",
      title = " Recol ",
      title_pos = "center",
    })
    vim.bo[buf].bufhidden = "wipe"
    vim.fn.termopen({ "recol", "-i", "--quit-on-select" }, {
      on_exit = function()
        vim.schedule(function()
          if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
          end
          vim.cmd.source("~/.config/nvim/init.lua")
        end)
      end,
    })
    vim.cmd.startinsert()
  end
  vim.api.nvim_create_user_command("RecolOpen", function()
    launch_interactive_mode()
  end, { nargs = 0 })
end
