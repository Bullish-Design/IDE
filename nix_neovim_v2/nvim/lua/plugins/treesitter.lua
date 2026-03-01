-- nvim/lua/plugins/treesitter.lua

require("nvim-treesitter.configs").setup({
  ensure_installed = {
    "lua",
    "vim",
    "vimdoc",
    "python",
    "nix",
    "rust",
    "go",
    "javascript",
    "typescript",
    "tsx",
    "json",
    "yaml",
    "html",
    "css",
    "markdown",
    "markdown_inline",
    "bash",
    "c",
    "cpp",
  },
  sync_install = false,
  auto_install = true,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true,
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "<CR>",
      node_incremental = "<CR>",
      scope_incremental = false,
      node_decremental = "<BS>",
    },
  },
})

require("treesitter-context").setup({
  max_lines = 3,
  trim_scope = "outer",
})
