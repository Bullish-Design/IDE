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
require("mini.pick").setup({
  ui_select = true,
})

-- Statusline and tabline
require("mini.statusline").setup()
require("mini.tabline").setup()

-- Visual polish
require("mini.indentscope").setup({ symbol = "│" })
require("mini.cursorword").setup()
require("mini.trailspace").setup()

-- Sessions
require("mini.sessions").setup({
  directory = vim.fn.stdpath("data") .. "/sessions",
  autoread = true,
  autowrite = true,
})

-- Starter (dashboard)
require("mini.starter").setup({
  header = table.concat(require("ui.header"), "\n"),
  items = vim.list_extend(
    require("mini.starter").sections.recent_files(8, true),
    require("mini.starter").sections.builtin_actions()
  ),
  content_hooks = {
    require("mini.starter").gen_hook.adding_bullet("• "),
    require("mini.starter").gen_hook.aligning("center", "center"),
  },
})

-- Clue (keymap hints - shows available keys after leader)
require("mini.clue").setup({
  triggers = {
    { mode = "n", keys = "<leader>" },
    { mode = "i", keys = "<C-x>" },
  },
  clues = {
    require("mini.clue").gen_clue.zsh(),
    require("mini.clue").gen_clue.builtin_keys(),
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
    if vim.fn.argc() == 0 and vim.v.this_session == "" then
      require("mini.starter").open()
    end
  end,
})
