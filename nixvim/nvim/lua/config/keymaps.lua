local map = vim.keymap.set

-- Core
map("n", "<leader>w", "<cmd>write<cr>", { desc = "Write" })
map("n", "<leader>q", "<cmd>quit<cr>", { desc = "Quit" })
map("n", "<leader>h", "<cmd>nohlsearch<cr>", { desc = "Clear search" })

-- Quick open file picker (mini.pick)
map("n", "<leader>ff", function() require("mini.pick").builtin.files() end, { desc = "Find files" })
map("n", "<leader>fg", function() require("mini.pick").builtin.grep_live() end, { desc = "Live grep" })
map("n", "<leader>fb", function() require("mini.pick").builtin.buffers() end, { desc = "Buffers" })

-- Diagnostics (builtin)
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Line diagnostic" })
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
