-- nvim/lua/config/options.lua

local opt = vim.opt
local o = vim.o
local g = vim.g

-- Format on save toggle state
g.format_on_save = true

-- Clipboard
opt.clipboard = "unnamedplus"

-- Numbers
opt.number = true
opt.relativenumber = true

-- Tabs and indentation
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.smartindent = true
opt.breakindent = true
opt.showtabline = 2

-- Search
opt.hlsearch = true
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true
opt.grepprg = "rg --vimgrep"
opt.grepformat = "%f:%l:%c:%m"

-- Text wrapping
opt.wrap = true

-- Split behavior
opt.splitbelow = true
opt.splitright = true

-- Mouse
opt.mouse = "a"

-- Performance
opt.updatetime = 50

-- Completion (for mini.completion)
opt.completeopt = { "menuone", "noselect", "noinsert" }

-- Files
opt.swapfile = false
opt.backup = false
opt.undofile = true

-- Colors
opt.termguicolors = true

-- UI
opt.signcolumn = "yes"
opt.cursorline = true
opt.cmdheight = 1
opt.showmode = true
opt.pumheight = 15
opt.laststatus = 3

-- Folding
opt.foldcolumn = "0"
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = true

-- Scrolling
opt.scrolloff = 8
opt.sidescrolloff = 8

-- Column
opt.colorcolumn = "120"

-- Timeout
opt.timeoutlen = 400

-- Encoding
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"

-- Cursor
opt.guicursor = {
  "n-v-c:block",
  "i-ci-ve:block",
  "r-cr:hor20",
  "o:hor50",
  "a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor",
  "sm:block-blinkwait175-blinkoff150-blinkon175",
}

-- Listchars (invisible characters)
opt.list = true
opt.listchars = {
  space = " ",
  trail = "•",
  extends = "→",
  precedes = "←",
  nbsp = "␣",
}

-- Neovide settings
if g.neovide then
  g.neovide_fullscreen = false
  g.neovide_hide_mouse_when_typing = false
  g.neovide_refresh_rate = 165
  g.neovide_cursor_vfx_mode = "ripple"
  g.neovide_cursor_animate_command_line = true
  g.neovide_cursor_animate_in_insert_mode = true
  g.neovide_cursor_vfx_particle_lifetime = 5.0
  g.neovide_cursor_vfx_particle_density = 14.0
  g.neovide_cursor_vfx_particle_speed = 12.0
  g.neovide_transparency = 0.8
  o.guifont = "MonoLisa Trial:Medium:h15"
end
