-- nvim/lua/plugins/codecompanion.lua
require("codecompanion").setup({
  adapters = {
    anthropic = function()
      return require("codecompanion.adapters").extend("anthropic", {
        env = {
          api_key = "cmd:cat ~/.anthropic_api_key",
        },
      })
    end,
  },
  strategies = {
    chat = { adapter = "anthropic" },
    inline = { adapter = "anthropic" },
  },
})

local map = vim.keymap.set
map({"n", "v"}, "<leader>a", "<cmd>CodeCompanionActions<cr>")
map({"n", "v"}, "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>")
map("v", "<leader>aa", "<cmd>CodeCompanionChat Add<cr>")