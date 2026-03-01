-- nvim/lua/plugins/mini.lua

-- Theme: generated colorscheme (no external theme plugin)
require("mini.hues").setup({
  background = "#0f1115", 
  foreground = "#d0d0d0",
  saturation = "medium",
  accent = "azure",
})

-- Core ergonomics
require("mini.files").setup()
require("mini.ai").setup()
require("mini.comment").setup()
require("mini.surround").setup()
require("mini.pairs").setup()

-- Visual polish
require("mini.statusline").setup()
require("mini.tabline").setup()
require("mini.indentscope").setup({ symbol = "│" })
require("mini.cursorword").setup()

-- Picker (uses rg/fd nicely)
require("mini.pick").setup()

-- Completion (small + builtin-friendly)
require("mini.completion").setup()

-- Better notifications
require("mini.notify").setup()
vim.notify = require("mini.notify").make_notify()



