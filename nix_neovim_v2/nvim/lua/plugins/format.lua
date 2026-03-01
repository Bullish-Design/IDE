-- nvim/lua/plugins/format.lua

require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    nix = { "alejandra" },
    python = { "ruff_format" },
    rust = { "rustfmt" },
    javascript = { "prettierd", "prettier" },
    typescript = { "prettierd", "prettier" },
    javascriptreact = { "prettierd", "prettier" },
    typescriptreact = { "prettierd", "prettier" },
    json = { "prettierd", "prettier" },
    html = { "prettierd", "prettier" },
    css = { "prettierd", "prettier" },
    yaml = { "prettierd", "prettier" },
    markdown = { "prettierd", "prettier" },
    go = { "gofmt", "goimports" },
    c = { "clangformat" },
    cpp = { "clangformat" },
  },
  format_on_save = function(bufnr)
    if vim.g.format_on_save == false then
      return false
    end
    local fname = vim.api.nvim_buf_get_name(bufnr)
    local ext = vim.fn.fnamemodify(fname, ":e")
    if ext == "py" then
      return { timeout_ms = 500, lsp_fallback = true }
    end
    return { timeout_ms = 500, lsp_fallback = true }
  end,
})

vim.formatexpr = function()
  if vim.g.format_on_save == false then
    return vim.fn["conform#formatexpr"]()
  end
  return vim.fn["conform#formatexpr"]()
end
