-- nvim/lua/config/autocmds.lua

-- LSP Progress notifications (mini.notify)
vim.api.nvim_create_autocmd("LspProgress", {
  callback = function(ev)
    local data = ev.data
    if data and data.params then
      local val = data.params.value
      if val and val.message then
        local status = ""
        if val.kind == "begin" then
          status = "⏳ "
        elseif val.kind == "end" then
          status = "✓ "
        else
          status = ""
        end
        vim.notify(status .. val.message, vim.log.levels.INFO)
      end
    end
  end,
})

-- Auto-save sessions
vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    if vim.fn.exists("b:miniSessionsActive") == 0 then
      pcall(function() require("mini.sessions").write() end)
    end
  end,
})

-- File type specific settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "qf", "help", "man" },
  callback = function(args)
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = args.buf, desc = "Close" })
  end,
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
})

-- Auto-close certain buffers (but not for plugins)
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*",
  callback = function()
    local filetype = vim.bo.filetype
    local exclude_ft = { ["starter"] = true, ["dapui"] = true, ["dap-repl"] = true, ["help"] = true }
    if exclude_ft[filetype] then
      return
    end
    if vim.fn.winnr("$") == 1 and vim.fn.bufname("%") == "" and vim.fn.bufnr("%") > 1 then
      vim.cmd("bdelete!")
    end
  end,
})

-- Set filetype for .mcpt files
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.mcpt",
  callback = function()
    vim.opt.filetype = "python"
  end,
})

-- Trim trailing whitespace on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    local pos = vim.fn.getpos(".")
    vim.cmd([[keeppatterns %s/\s\+$//e]])
    vim.fn.setpos(".", pos)
  end,
})
