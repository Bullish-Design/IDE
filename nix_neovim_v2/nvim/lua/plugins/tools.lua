-- nvim/lua/plugins/tools.lua

-- Obsidian (if vault exists)
local obsidian_path = vim.fn.expand("~/Documents/Notes")
if vim.fn.isdirectory(obsidian_path) == 1 then
  require("obsidian").setup({
    workspaces = {
      {
        name = "notes",
        path = obsidian_path,
      },
    },
    completion = {
      nvim_cmp = false,
      min_chars = 2,
    },
    templates = {
      date_format = "%Y-%m-%d",
      time_format = "%H:%M",
    },
  })
end

-- Markdown preview
vim.g.mkdp_command_for_global = 0
vim.g.mkdp_auto_close = 1
vim.g.mkdp_echo_preview_url = 1
vim.g.mkdp_browser = "firefox"
vim.g.mkdp_markdown_css = ""
vim.g.mkdp_highlight_css = ""
vim.g.mkdp_port = "8000"
vim.g.mkdp_theme = "dark"

vim.keymap.set("n", "<leader>mp", "<cmd>MarkdownPreview<cr>", { desc = "Markdown preview" })
vim.keymap.set("n", "<leader>ms", "<cmd>MarkdownPreviewStop<cr>", { desc = "Markdown stop" })
