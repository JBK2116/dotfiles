-- Bootstraps the lazy.nvim plugin manager: clones it on first run, prepends
-- it to the runtimepath, and loads all plugin specs from the jovani.plugins
-- and jovani.plugins.lsp modules. Enables the background update checker and
-- silent change detection.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({ { import = "jovani.plugins" }, { import = "jovani.plugins.lsp" } }, {
  checker = {
    enabled = true,
    notify = false,
  },
  change_detection = {
    notify = false,
  },
})
