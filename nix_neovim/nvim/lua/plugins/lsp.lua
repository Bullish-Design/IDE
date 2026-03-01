-- ~/.config/nvim/lua/plugins/lsp.lua

-- Basic LSP UX (builtin)
vim.diagnostic.config({
  virtual_text = false,
  float = { border = "rounded" },
  severity_sort = true,
})

local function on_attach(_, bufnr)
  local map = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
  end

  map("n", "gd", vim.lsp.buf.definition, "Go to definition")
  map("n", "gr", vim.lsp.buf.references, "References")
  map("n", "K", vim.lsp.buf.hover, "Hover")
  map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
  map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
  map("n", "<leader>f", function() vim.lsp.buf.format({ async = true }) end, "Format")
end

-- Customize server configs (provided by nvim-lspconfig), then enable them.
-- Neovim 0.11+ API: vim.lsp.config + vim.lsp.enable

vim.lsp.config("lua_ls", {
  on_attach = on_attach,
  settings = {
    Lua = {
      diagnostics = { globals = { "vim" } },
      workspace = { checkThirdParty = false },
    },
  },
})
vim.lsp.enable("lua_ls")

vim.lsp.config("nil_ls", { on_attach = on_attach })
vim.lsp.enable("nil_ls")

vim.lsp.config("bashls", { on_attach = on_attach })
vim.lsp.enable("bashls")
