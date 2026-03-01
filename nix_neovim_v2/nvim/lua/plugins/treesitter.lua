-- nvim/lua/plugins/treesitter.lua
-- Treesitter configuration for Nix-managed environment
-- Parsers are provided by nvim-treesitter.withPlugins in devenv.nix / hm-module.nix
-- No ensure_installed or auto_install needed

-- Enable treesitter-based highlighting for all supported buffers
vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    local ok = pcall(vim.treesitter.start, args.buf)
    if not ok then return end
  end,
})

-- Enable treesitter-based indentation
vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    if pcall(vim.treesitter.get_parser) then
      vim.bo.indentexpr = "v:lua.require'nvim-treesitter.indent'.get_indent(v:lnum)"
    end
  end,
})

-- Treesitter context (sticky function headers)
require("treesitter-context").setup({
  max_lines = 3,
  trim_scope = "outer",
})
