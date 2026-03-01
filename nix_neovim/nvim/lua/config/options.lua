-- nvim/lua/config/options.lua

-- UI
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.opt.showmode = false
vim.opt.laststatus = 3 -- global statusline
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.scrolloff = 4
vim.opt.sidescrolloff = 8

-- Editing
vim.opt.mouse = "a"
vim.opt.wrap = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.updatetime = 200
vim.opt.timeoutlen = 400

-- Listchars (subtle whitespace visibility)
vim.opt.list = true
vim.opt.listchars = {
  tab = "→ ",
  trail = "·",
  nbsp = "␣",
}

-- Floating windows
vim.opt.pumheight = 12
vim.opt.pumblend = 0
vim.opt.winblend = 0

