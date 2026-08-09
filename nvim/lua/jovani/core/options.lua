vim.cmd("let g:netrw_liststyle = 3")
local opt = vim.opt
opt.relativenumber = true
opt.number = true
-- tabs & indentation
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.autoindent = true
opt.wrap = false
-- search settings
opt.ignorecase = true
opt.smartcase = true
opt.cursorline = true
-- turn on termguicolors for colorscheme to work
opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"
-- keep cursor vertically centered at all times
opt.scrolloff = 999
-- backspace
opt.backspace = "indent,eol,start"
-- clipboard
opt.clipboard:append("unnamedplus")
-- split windows
opt.splitright = true
opt.splitbelow = true
-- turn off swapfile
opt.swapfile = false
-- obsidian nvim
opt.conceallevel = 0
-- faster CursorHold events (default 4000ms is too slow for LSP)
opt.updatetime = 250
-- faster key sequence completion
opt.timeoutlen = 300
-- keep undo history across sessions
opt.undofile = true
-- don't show mode in cmdline (lualine handles it)
opt.showmode = false
-- remove ~ in eob lines
vim.opt.fillchars = { eob = " " }
-- C/C++/C# specific indentation
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp", "cs" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
  end,
})
vim.lsp.set_log_level("ERROR")
-- Wipe all junk buffers (best used periodically in long coding sessions)
vim.api.nvim_create_user_command("BufWipeJunk", function()
  local junk = { "%[Scratch%]", "snacks://", "CodeCompanion" }
  local count = 0
  for _, b in ipairs(vim.fn.getbufinfo()) do
    for _, pat in ipairs(junk) do
      if b.name:match(pat) then
        if pcall(vim.api.nvim_buf_delete, b.bufnr, { force = true }) then
          count = count + 1
        end
        break
      end
    end
  end
  print(count .. " junk buffers wiped")
end, { desc = "Wipe scratch/plugin junk buffers" })
