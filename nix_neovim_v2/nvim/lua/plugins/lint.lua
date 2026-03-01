-- nvim/lua/plugins/lint.lua

require("lint").linters_by_ft = {
  python = { "ruff" },
  lua = { "selene" },
  nix = { "statix" },
  json = { "jsonlint" },
  yaml = { "yamllint" },
  sh = { "shellcheck" },
  bash = { "shellcheck" },
  go = { "golangcilint" },
}

vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter", "TextChanged", "InsertLeave" }, {
  callback = function()
    require("lint").try_lint()
  end,
})
