-- nvim/lua/plugins/test.lua

require("neotest").setup({
  adapters = {
    require("neotest-python")({
      dap = { justMyCode = false },
    }),
    require("neotest-vitest"),
    require("neotest-rust"),
  },
  summary = {
    animated = true,
    follow = true,
    jumps = true,
    markers = true,
    opened = true,
  },
  output = {
    enabled = true,
    open_on_run = true,
  },
  running = {
    enabled = true,
  },
  quickfix = {
    enabled = true,
    open = function()
      vim.cmd("copen")
    end,
  },
})

local neotest = require("neotest")

vim.api.nvim_create_autocmd("FileType", {
  pattern = "*test*.lua",
  callback = function(args)
    local filename = vim.api.nvim_buf_get_name(args.buf)
    if filename:match("spec%.lua$") or filename:match("test_.*%.lua$") then
      vim.keymap.set("n", "<leader>tt", function() neotest.run.run(vim.fn.expand("%")) end, { buffer = args.buf, desc = "Run file tests" })
      vim.keymap.set("n", "<leader>tr", function() neotest.run.run() end, { buffer = args.buf, desc = "Run nearest test" })
    end
  end,
})
