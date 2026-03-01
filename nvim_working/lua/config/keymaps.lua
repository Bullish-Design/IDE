-- nvim/lua/config/keymaps.lua

-- Basic keymaps
local map = vim.keymap.set

map("n", "<leader>w", "<cmd>w<cr>", { desc = "Write" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })
-- map("n", "<leader>e", ":edit ", { desc = "Edit file" })
-- map("n", "<leader>h", "<cmd>nohlsearch<cr>", { desc = "Clear search" })

-- Sensible UI
-- vim.opt.scrolloff = 4

-- Diagnostics quick toggles (no plugins)
-- map("n", "<leader>d", "<cmd>lua vim.diagnostic.open_float()<cr>", { desc = "Line diagnostics" })
-- map("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<cr>", { desc = "Prev diagnostic" })
-- map("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<cr>", { desc = "Next diagnostic" })
