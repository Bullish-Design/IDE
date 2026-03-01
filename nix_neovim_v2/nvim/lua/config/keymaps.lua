-- nvim/lua/config/keymaps.lua

local map = vim.keymap.set

-- Save/Quit (core)
map("n", "<C-s>", "<cmd>write<cr>", { desc = "Save" })
map("n", "<leader>q", "<cmd>quit<cr>", { desc = "Quit all" })
map("n", "<leader>h", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

-- Navigation: Find (mini.pick)
map("n", "<leader>ff", function() require("mini.pick").builtin.files() end, { desc = "Find files" })
map("n", "<leader>fg", function() require("mini.pick").builtin.grep_live() end, { desc = "Live grep" })
map("n", "<leader>fb", function() require("mini.pick").builtin.buffers() end, { desc = "Find buffers" })
map("n", "<leader>fr", function() require("mini.pick").builtin.recent() end, { desc = "Recent files" })

-- Navigation: File explorer (mini.files)
map("n", "<leader>e", function() require("mini.files").toggle() end, { desc = "Toggle file explorer" })

-- LSP: Builtin (native) - these are core muscle memory
map("n", "gd", vim.lsp.buf.definition, "Go to definition")
map("n", "gr", vim.lsp.buf.references, "References")
map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
map("n", "K", vim.lsp.buf.hover, "Hover documentation")

-- LSP: Code actions (leader c)
map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
map("n", "<leader>cr", vim.lsp.buf.rename, "Rename symbol")
map("n", "<leader>cf", function() vim.lsp.buf.format({ async = true }) end, "Format")
map("n", "<leader>cd", vim.diagnostic.open_float, "Line diagnostic")

-- Diagnostics: Jump (builtin)
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "<leader>x", function() vim.diagnostic.setqflist() end, { desc = "Diagnostics to quickfix" })

-- Git: Gitsigns (leader g)
map("n", "<leader>gs", function() require("gitsigns").stage_hunk() end, { desc = "Stage hunk" })
map("n", "<leader>gr", function() require("gitsigns").reset_hunk() end, { desc = "Reset hunk" })
map("n", "<leader>gp", function() require("gitsigns").preview_hunk() end, { desc = "Preview hunk" })
map("n", "<leader>gb", function() require("gitsigns").blame_line() end, { desc = "Blame line" })
map("n", "<leader>gg", function() require("neogit").open() end, { desc = "Open Neogit" })
map("n", "<leader>gd", function() require("diffview").open() end, { desc = "Open Diffview" })

-- Git: Hunk navigation
map("n", "[h", function() require("gitsigns").prev_hunk() end, { desc = "Previous git hunk" })
map("n", "]h", function() require("gitsigns").next_hunk() end, { desc = "Next git hunk" })

-- Terminal: Toggle (10 lines of Lua, no plugin)
local term_buf = nil
map("n", "<A-i>", function()
  if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
    local wins = vim.fn.win_findbuf(term_buf)
    if #wins > 0 then
      vim.api.nvim_win_close(wins[1], true)
    else
      vim.cmd("botright split | buffer " .. term_buf)
      vim.cmd("resize 15")
    end
  else
    vim.cmd("botright split | terminal")
    term_buf = vim.api.nvim_get_current_buf()
    vim.cmd("resize 15")
  end
end, { desc = "Toggle terminal" })

-- UI toggles (leader u)
map("n", "<leader>ul", function() vim.opt.number = not vim.opt.number end, { desc = "Toggle line numbers" })
map("n", "<leader>ur", function() vim.opt.relativenumber = not vim.opt.relativenumber end, { desc = "Toggle relative numbers" })
map("n", "<leader>uw", function() vim.opt.wrap = not vim.opt.wrap end, { desc = "Toggle wrap" })
map("n", "<leader>uh", function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end, { desc = "Toggle inlay hints" })
map("n", "<leader>uf", function()
  vim.g.format_on_save = not vim.g.format_on_save
  vim.notify(vim.g.format_on_save and "Format on save enabled" or "Format on save disabled")
end, { desc = "Toggle format on save" })

-- Session (leader q)
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })
map("n", "<leader>qs", function() require("mini.sessions").select("write") end, { desc = "Save session" })
map("n", "<leader>qr", function() require("mini.sessions").select("read") end, { desc = "Restore session" })

-- Debug (leader d) - DAP
map("n", "<leader>db", function() require("dap").toggle_breakpoint() end, { desc = "Toggle breakpoint" })
map("n", "<leader>dc", function() require("dap").continue() end, { desc = "Continue" })
map("n", "<leader>di", function() require("dap").step_into() end, { desc = "Step into" })
map("n", "<leader>do", function() require("dap").step_out() end, { desc = "Step out" })
map("n", "<leader>dO", function() require("dap").step_over() end, { desc = "Step over" })
map("n", "<leader>dt", function() require("dap").terminate() end, { desc = "Terminate" })
map("n", "<leader>du", function() require("dapui").toggle() end, { desc = "Toggle DAP UI" })

-- Test (leader t) - Neotest
map("n", "<leader>tt", function() require("neotest").run.run(vim.fn.expand("%")) end, { desc = "Run file tests" })
map("n", "<leader>tr", function() require("neotest").run.run() end, { desc = "Run nearest test" })
map("n", "<leader>ts", function() require("neotest").summary.toggle() end, { desc = "Toggle test summary" })
map("n", "<leader>to", function() require("neotest").output_panel.toggle() end, { desc = "Toggle test output" })

-- Visual: Stay in indent mode
map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })

-- Visual: Move lines (mini.move)
map("v", "J", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })

-- Half-page scrolling with centering
map("n", "<C-d>", "zz<C-d>zz", { desc = "Half-page down" })
map("n", "<C-u>", "zz<C-u>zz", { desc = "Half-page up" })
