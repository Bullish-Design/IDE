-- nvim/lua/plugins/lsp.lua

-- Diagnostic config (builtin)
vim.diagnostic.config({
  virtual_text = false,
  float = { border = "rounded", source = true },
  severity_sort = true,
  signs = true,
})

-- LSP borders for hover, definition, etc.
local border = "rounded"

-- LSP on_attach function
local function on_attach(_, bufnr)
  local map = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
  end

  -- Core LSP features (muscle memory)
  map("n", "gd", vim.lsp.buf.definition, "Go to definition")
  map("n", "gr", vim.lsp.buf.references, "References")
  map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
  map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
  map("n", "K", function() vim.lsp.buf.hover({ border = border }) end, "Hover")
  map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
  map("n", "<leader>cr", vim.lsp.buf.rename, "Rename")
  map("n", "<leader>cf", function() vim.lsp.buf.format({ async = true }) end, "Format")
  map("n", "<leader>cd", vim.diagnostic.open_float, "Line diagnostic")

  -- Inlay hints
  vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
end

-- Configure each language server
vim.lsp.config("lua_ls", {
  on_attach = on_attach,
  settings = {
    Lua = {
      diagnostics = { globals = { "vim" } },
      workspace = { checkThirdParty = false },
      format = { enable = false },
    },
  },
})
vim.lsp.enable("lua_ls")

vim.lsp.config("nil_ls", {
  on_attach = on_attach,
  settings = {
    ["nil_ls"] = {
      formattingCommand = "alejandra",
    },
  },
})
vim.lsp.enable("nil_ls")

vim.lsp.config("pyright", {
  on_attach = on_attach,
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "basic",
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
      },
    },
  },
})
vim.lsp.enable("pyright")

vim.lsp.config("rust_analyzer", {
  on_attach = on_attach,
  settings = {
    ["rust-analyzer"] = {
      cargo = { allFeatures = true },
      checkOnSave = { command = "clippy" },
    },
  },
})
vim.lsp.enable("rust_analyzer")

vim.lsp.config("clangd", {
  on_attach = on_attach,
  settings = {
    clangd = {
      arguments = { "--background-index" },
    },
  },
})
vim.lsp.enable("clangd")

vim.lsp.config("bashls", {
  on_attach = on_attach,
})
vim.lsp.enable("bashls")

vim.lsp.config("eslint", {
  on_attach = on_attach,
})
vim.lsp.enable("eslint")

vim.lsp.config("ts_ls", {
  on_attach = on_attach,
})
vim.lsp.enable("ts_ls")

vim.lsp.config("html", {
  on_attach = on_attach,
})
vim.lsp.enable("html")

vim.lsp.config("cssls", {
  on_attach = on_attach,
})
vim.lsp.enable("cssls")

vim.lsp.config("jsonls", {
  on_attach = on_attach,
})
vim.lsp.enable("jsonls")

vim.lsp.config("yamlls", {
  on_attach = on_attach,
})
vim.lsp.enable("yamlls")

vim.lsp.config("gopls", {
  on_attach = on_attach,
  settings = {
    gopls = {
      analyses = { unusedparams = true },
      staticcheck = true,
    },
  },
})
vim.lsp.enable("gopls")

-- vim.lsp.config("ruff", {
--   on_attach = on_attach,
--   settings = {
--     ruff = {
--       lint = {
--         select = { "E", "F", "W", "I" },
--         ignore = { "E501" },
--       },
--     },
--   },
-- })
-- vim.lsp.enable("ruff")
