return {
  "nickjvandyke/opencode.nvim",
  dependencies = { "folke/snacks.nvim" },
  config = function()
    vim.g.opencode_opts = {
      provider = { enabled = "snacks" },
    }
    vim.o.autoread = true -- reload buffers opencode edits

    local oc = function()
      return require("opencode")
    end
    local map = vim.keymap.set

    map({ "n", "x" }, "<leader>ao", function()
      oc().ask("@this: ", { submit = true })
    end, { desc = "Ask OpenCode" })

    map({ "n", "x" }, "<leader>aa", function()
      oc().select()
    end, { desc = "OpenCode actions" })

    map({ "n", "t" }, "<leader>at", function()
      oc().toggle()
    end, { desc = "Toggle OpenCode" })

    map({ "n", "x" }, "<leader>ar", function()
      return oc().operator("@this ")
    end, { desc = "Send range to OpenCode", expr = true })

    map("n", "<leader>al", function()
      return oc().operator("@this ") .. "_"
    end, { desc = "Send line to OpenCode", expr = true })
  end,
}
