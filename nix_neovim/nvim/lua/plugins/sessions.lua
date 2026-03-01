-- nvim/lua/plugins/sessions.lua

require("mini.sessions").setup({
  directory = vim.fn.stdpath("data") .. "/sessions",
  autoread = true,
  autowrite = true,
})

-- Optional: convenient commands (mini already provides :lua MiniSessions.*)
-- You can also add keymaps elsewhere if you want.
