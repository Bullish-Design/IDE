-- nvim/lua/plugins/codecompanion.lua

require("codecompanion").setup({
  adapters = {
    anthropic = function()
      return require("codecompanion.adapters").extend("anthropic", {
        env = {
          api_key = os.getenv("ANTHROPIC_API_KEY") or "",
        },
      })
    end,
    openai = function()
      return require("codecompanion.adapters").extend("openai", {
        env = {
          api_key = os.getenv("OPENAI_API_KEY") or "",
        },
      })
    end,
  },
  display = {
    action_palette = {
      width = 95,
      height = 10,
    },
    chat = {
      window = {
        layout = "vertical",
        border = "single",
        height = 0.8,
        width = 0.45,
        relative = "editor",
      },
    },
  },
  strategies = {
    chat = "anthropic",
    inline = "openai",
  },
  opts = {
    log_level = "ERROR",
  },
})

-- Keybindings
local map = vim.keymap.set

map("n", "<leader>ai", "<cmd>CodeCompanionActions<cr>", { desc = "CodeCompanion actions" })
map("n", "<leader>aa", "<cmd>CodeCompanionChat<cr>", { desc = "CodeCompanion chat" })
map("v", "<leader>aa", "<cmd>CodeCompanionChat<cr>", { desc = "CodeCompanion chat" })
map("n", "<leader>at", "<cmd>CodeCompanionToggle<cr>", { desc = "CodeCompanion toggle" })
