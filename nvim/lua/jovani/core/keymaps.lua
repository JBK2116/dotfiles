vim.g.mapleader = " "
local keymap = vim.keymap

-- Search and Replace
vim.keymap.set("n", "<leader>r", 'viw"-y:%s/<C-r>-/<C-r>-/g<Left><Left>')
vim.keymap.set("v", "<leader>r", '"-y:%s/<C-r>-/<C-r>-/g<Left><Left>')
-- Yank
vim.keymap.set("n", "yY", ":%y+<CR>", { desc = "Copy whole buffer to clipboard" })

-- Exit insert mode
keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })

-- Clear search highlights
keymap.set("n", "hn", ":nohl<CR>", { desc = "Clear search highlights" })

-- Increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" })
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" })

-- Window splits
keymap.set("n", "<leader>wv", "<C-w>v", { desc = "Split window vertically" })
keymap.set("n", "<leader>we", "<C-w>=", { desc = "Make splits equal size" })
keymap.set("n", "<leader>wu", "<cmd>close<CR>", { desc = "Close current split" })

-- Pane navigation
keymap.set("n", "<A-h>", "<C-w>h", { desc = "Navigate to left pane" })
keymap.set("n", "<A-l>", "<C-w>l", { desc = "Navigate to right pane" })
keymap.set("n", "<A-k>", "<C-w>k", { desc = "Navigate to upper pane" })
keymap.set("n", "<A-j>", "<C-w>j", { desc = "Navigate to lower pane" })

-- Tab management
keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" })
keymap.set("n", "<leader>q", "<cmd>tabclose<CR>", { desc = "Close current tab" })
keymap.set("n", "<A-n>", "<cmd>tabn<CR>", { desc = "Go to next tab" })
keymap.set("n", "<A-p>", "<cmd>tabp<CR>", { desc = "Go to previous tab" })
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" })
keymap.set("n", "<A-S-n>", ":tabmove +1<CR>", { desc = "Move tab right" })
keymap.set("n", "<A-S-p>", ":tabmove -1<CR>", { desc = "Move tab left" })

-- Better line navigation
keymap.set("n", "H", "^", { desc = "Go to first non-blank character" })
keymap.set("n", "L", "$", { desc = "Go to last character" })

-- Easy visual indentation
keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })

-- Center screen is handled by scrolloff=999 (see options.lua)

-- Execute macro in q register
keymap.set("n", "qj", "@q", { desc = "Execute macro in q register" })

-- Diagnostic navigation
keymap.set("n", "<leader>en", vim.diagnostic.goto_next, { desc = "Go to next diagnostic" })
keymap.set("n", "<leader>ep", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic" })

-- Quickfix navigation
keymap.set("n", "]q", ":cnext<CR>", { desc = "Go to next quickfix item", silent = true })
keymap.set("n", "[q", ":cprev<CR>", { desc = "Go to previous quickfix item", silent = true })

-- Jump between functions (scrolloff handles centering)
vim.keymap.set("n", "]]", "]]w", { noremap = true, desc = "Next function" })
vim.keymap.set("n", "[[", "[[w", { noremap = true, desc = "Previous function" })
-- Special LSP Information Command
vim.api.nvim_create_user_command("LspInfo", "checkhealth vim.lsp", { desc = "Show LSP Info" })
