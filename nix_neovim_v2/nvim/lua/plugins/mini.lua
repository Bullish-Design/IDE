-- nvim/lua/plugins/mini.lua

-- Theme: mini.hues (no external colorscheme needed)
require("mini.hues").setup({
  background = "#0f1115",
  foreground = "#d0d0d0",
  saturation = "medium",
  accent = "azure",
})

-- Core editing ergonomics
require("mini.ai").setup()
require("mini.surround").setup()
require("mini.pairs").setup()

-- File navigation
require("mini.files").setup()
require("mini.pick").setup()
vim.ui.select = require("mini.pick").ui_select

-- Statusline and tabline
require("mini.statusline").setup()
require("mini.tabline").setup()

-- Visual polish
require("mini.indentscope").setup({ symbol = "│" })
require("mini.cursorword").setup()

-- Sessions
require("mini.sessions").setup({
  directory = vim.fn.stdpath("data") .. "/sessions",
  autoread = true,
  autowrite = true,
})

-- Starter (dashboard)
local starter = require("mini.starter")
local recent = starter.sections.recent_files(8, true)
local builtin = starter.sections.builtin_actions()

-- Ensure both are tables
recent = (type(recent) == "table") and recent or {}
builtin = (type(builtin) == "table") and builtin or {}

starter.setup({
  header = table.concat(require("ui.header"), "\n"),
  items = vim.list_extend(recent, builtin),
  content_hooks = {
    starter.gen_hook.adding_bullet("• "),
    starter.gen_hook.aligning("center", "center"),
  },
})

-- Clue (keymap hints - shows available keys after leader)
require("mini.clue").setup({
  triggers = {
    { mode = "n", keys = "<leader>" },
    { mode = "v", keys = "<leader>" },
    { mode = "n", keys = "[" },
    { mode = "n", keys = "]" },
    { mode = "n", keys = "g" },
    { mode = "n", keys = "s" },
    { mode = "i", keys = "<C-x>" },
  },
  clues = {
    require("mini.clue").gen_clues.builtin_completion(),
    require("mini.clue").gen_clues.g(),
    require("mini.clue").gen_clues.z(),
    require("mini.clue").gen_clues.windows(),
    require("mini.clue").gen_clues.marks(),
    require("mini.clue").gen_clues.registers(),
  },
})

-- Move (move lines/blocks)
require("mini.move").setup()

-- Completion (lightweight)
require("mini.completion").setup()

-- Notifications (replaces nvim-notify + fidget + noice notifications)
require("mini.notify").setup()
vim.notify = require("mini.notify").make_notify()

-- Open starter on empty launch
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- Only show starter if no file is being edited and no session is being restored
    if vim.fn.argc() == 0 then
      require("mini.starter").open()
    end
  end,
})
