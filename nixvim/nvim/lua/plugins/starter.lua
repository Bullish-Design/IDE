-- nvim/lua/plugins/starter.lua

local starter = require("mini.starter")
-- local header = require("ui.header")

-- Normalize: some versions return a table, others return a function that returns a table
local function as_items(x)
  if type(x) == "function" then x = x() end
  if type(x) ~= "table" then return {} end
  return x
end

local items = {}

-- Sessions section (works with mini.sessions)
table.insert(items, {
  name = "Open session",
  action = function() if _G.MiniSessions then MiniSessions.select("read") end end,
  section = "Sessions",
})
table.insert(items, {
  name = "Save session",
  action = function() if _G.MiniSessions then MiniSessions.select("write") end end,
  section = "Sessions",
})
table.insert(items, {
  name = "Delete session",
  action = function() if _G.MiniSessions then MiniSessions.select("delete") end end,
  section = "Sessions",
})

-- Recent + builtins (normalize in case they are functions)
vim.list_extend(items, as_items(starter.sections.recent_files(8, true)))
vim.list_extend(items, as_items(starter.sections.builtin_actions()))

starter.setup({
  header = table.concat(require("ui.header"), "\n"),
  items = items, -- MUST be a table in this version
  content_hooks = {
    starter.gen_hook.adding_bullet("• "),
    starter.gen_hook.aligning("center", "center"),
  },
})

-- Only show Starter when launching with no args AND no active session.
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argc() == 0 and vim.v.this_session == "" then
      starter.open()
    end
  end,
})
