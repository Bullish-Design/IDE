# NIX_NEOVIM_CODE_REVIEW.md

## Executive Summary

**Status:** NEEDS WORK BEFORE INTEGRATION

The `nix_neovim_v2` configuration makes strong progress toward the streamlined architecture outlined in NIXVIM_REWRITE_OVERVIEW.md. The directory structure is clean, mini.nvim is correctly positioned as the primary framework, and the overall direction is right. However, the implementation has a significant number of bugs, architectural contradictions, and gaps that would cause real problems in daily use. This review catalogs every issue found by reading every line of every file in the project.

**What's genuinely good:**
- Directory structure is clean and modular
- mini.nvim is correctly used as the framework layer
- Plugin count is dramatically reduced
- The mental model of "one answer per task" is mostly achieved
- Colorscheme handled via mini.hues (zero external dependency)

**What's wrong:**
- The config will not build as-is (Nix issues)
- Multiple formatting/linting ownership conflicts remain (the exact problem the rewrite was supposed to fix)
- Keybinding conflicts between keymaps.lua and plugin on_attach handlers
- Deprecated/incorrect Neovim API usage throughout
- Several plugins referenced in Lua but missing from plugins.nix
- Options that will make the editor unusable (10ms timeoutlen, cmdheight=3)

**Issue count:** 5 Critical, 11 High, 9 Medium, 6 Minor

---

## Part 1: Architecture Review

### Directory Structure

```
nix_neovim_v2/
├── nvim/
│   ├── init.lua                   # Entry point (correct)
│   ├── lua/
│   │   ├── config/
│   │   │   ├── init.lua           # Loads options, keymaps, autocmds
│   │   │   ├── options.lua        # vim.opt settings (117 lines)
│   │   │   ├── keymaps.lua        # ~50 keybindings
│   │   │   └── autocmds.lua       # Autocommands (89 lines)
│   │   ├── plugins/
│   │   │   ├── init.lua           # Plugin loader (10 modules)
│   │   │   ├── mini.lua           # 16 mini.nvim modules
│   │   │   ├── lsp.lua            # 14 language servers
│   │   │   ├── format.lua         # conform.nvim
│   │   │   ├── lint.lua           # nvim-lint
│   │   │   ├── treesitter.lua     # treesitter + context
│   │   │   ├── git.lua            # gitsigns + neogit + diffview
│   │   │   ├── dap.lua            # nvim-dap + dap-ui
│   │   │   ├── test.lua           # neotest
│   │   │   ├── tools.lua          # obsidian, markdown-preview
│   │   │   └── codecompanion.lua  # AI assistant
│   │   └── ui/
│   │       └── header.lua         # ASCII art dashboard header
│   └── plugins/
│       └── codecompanion.nix      # CodeCompanion plugin build
├── plugins.nix                    # Plugin list
├── default.nix                    # Standalone wrapper
├── hm-module.nix                  # Home Manager module
├── flake.nix                      # Flake inputs
├── .tmuxp.yaml                    # Tmux layout
└── README.md                      # (3 lines, essentially empty)
```

**Assessment:** The structure is sound and follows the rewrite overview's design. Each file has a clear responsibility. The separation of config/ and plugins/ is correct.

### Plugin Architecture

The three-tier model from the rewrite overview is implemented:

**Tier 1 (Builtins):** LSP, diagnostics, comments, terminal - all correctly leveraged.

**Tier 2 (mini.nvim):** 16 modules loaded. The rewrite overview specified 15; the config adds mini.hues as the colorscheme, which is a good decision since it eliminates an external colorscheme dependency.

**Tier 3 (External):** plugins.nix lists 13 packages (nvim-lspconfig, conform, nvim-lint, treesitter, gitsigns, neogit, diffview, nvim-dap, nvim-dap-ui, neotest, neotest-python, neotest-vitest, codecompanion). However, several plugins referenced in Lua code are missing from this list (see Critical Issues).

---

## Part 2: Critical Issues (Will Break or Fail)

### CRITICAL #1: Duplicate format-on-save creates double-formatting

**Files:** `autocmds.lua:4-13`, `format.lua:18-28`

```lua
-- autocmds.lua: Calls vim.lsp.buf.format() on BufWritePre
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function(args)
    if vim.g.format_on_save ~= false then
      vim.lsp.buf.format({ bufnr = args.buf, async = false, timeout_ms = 500 })
    end
  end,
})

-- format.lua: conform.nvim ALSO has format_on_save configured
require("conform").setup({
  format_on_save = function(bufnr)
    if vim.g.format_on_save == false then return false end
    return { timeout_ms = 500, lsp_fallback = true }
  end,
})
```

**Problem:** Every save triggers TWO formatters: the autocmd calls `vim.lsp.buf.format()` directly, then conform's `format_on_save` hook fires separately. This is exactly the kind of "plugins fighting each other" redundancy the rewrite was supposed to eliminate. Depending on timing, you get double formatting, race conditions, or the LSP formatter undoing conform's work.

**Fix:** Remove the BufWritePre autocmd from autocmds.lua entirely. Let conform own format-on-save. That's why conform exists.

### CRITICAL #2: Ruff configured three ways (LSP + lint + format)

**Files:** `lsp.lua:157-170`, `format.lua:7`, `lint.lua:4`

```lua
-- lsp.lua: ruff as LSP server (provides linting AND formatting)
vim.lsp.config("ruff", { ... })
vim.lsp.enable("ruff")

-- format.lua: ruff_format via conform
python = { "ruff_format" },

-- lint.lua: ruff via nvim-lint
python = { "ruff" },
```

**Problem:** The rewrite overview explicitly says (Section 1.4): "ruff-lsp provides linting AND formatting for Python. nvim-lint also runs ruff as a standalone linter. conform.nvim also runs ruff_format. Triple coverage on the same tool for the same language." And then in Section 3 (Linting & Formatting): "Drop ruff-lsp entirely. Pyright handles type checking. Conform runs ruff for formatting. nvim-lint runs ruff for linting."

The implementation does the exact opposite of what the spec requires. Ruff LSP is still enabled, creating triple coverage.

**Fix:** Remove ruff from lsp.lua entirely. Keep pyright for type-checking LSP, ruff in lint.lua for linting, and ruff_format in format.lua for formatting. Three tools, zero overlap - exactly as the spec says.

### CRITICAL #3: Missing plugins in plugins.nix

**Files:** `plugins.nix`, `lsp.lua`, `treesitter.lua`, `test.lua`, `tools.lua`, `dap.lua`

The Lua code requires several plugins that are not in plugins.nix:

| Required in Lua | Present in plugins.nix? |
|----------------|------------------------|
| `treesitter-context` | No |
| `neotest-rust` | No |
| `obsidian.nvim` | No |
| `markdown-preview.nvim` | No |
| `nvim-dap-python` | No |
| `nvim-nio` (neotest dependency) | No |
| `plenary.nvim` (neogit/neotest dependency) | No |

These are all declared as flake inputs, but the flake only outputs `homeManagerModules.default` which calls hm-module.nix. The hm-module.nix uses `import ./plugins.nix { inherit pkgs; }` for the plugin list, so the flake inputs for these plugins are never actually used.

**Problem:** The config will fail at runtime. `require("treesitter-context")` will error because the plugin isn't installed. Same for neotest-rust, obsidian, etc. Additionally, neotest requires nvim-nio and plenary.nvim as dependencies - neither is listed.

**Fix:** Either:
1. Add all missing plugins to plugins.nix using `pkgs.vimPlugins.*`
2. Or build them from flake inputs in hm-module.nix

Option 1 is simpler and what the project architecture intends. Add:
```nix
vp.nvim-treesitter-context
vp.obsidian-nvim
vp.markdown-preview-nvim
vp.neotest-rust
vp.nvim-dap-python
vp.nvim-nio
vp.plenary-nvim
```

### CRITICAL #4: `vim.lsp.config()` / `vim.lsp.enable()` used incorrectly

**File:** `lsp.lua` (entire file)

```lua
vim.lsp.config("lua_ls", { on_attach = on_attach, settings = { ... } })
vim.lsp.enable("lua_ls")
```

**Problem:** `vim.lsp.config()` and `vim.lsp.enable()` are Neovim 0.11+ APIs that work with the native LSP configuration system. However, the config also lists `nvim-lspconfig` in plugins.nix and loads it. When nvim-lspconfig is present, it registers its own configurations. The native `vim.lsp.config()` API expects server configurations to include `cmd` and `filetypes` fields - without nvim-lspconfig providing defaults, these calls would fail.

The interaction between `vim.lsp.config()`/`vim.lsp.enable()` and nvim-lspconfig is not straightforward. In Neovim 0.11+, nvim-lspconfig registers its configs via `vim.lsp.config()` when you require it, but the user's call to `vim.lsp.config()` then *merges* with lspconfig's defaults. This works - but only if nvim-lspconfig is loaded first and the server name matches what lspconfig expects.

**Specific issues:**
- `nil_ls` - lspconfig calls this `nil_ls`, the binary is `nil`. This should work.
- `ts_ls` - lspconfig historically called this `tsserver`, though recent versions use `ts_ls`. Verify against the installed lspconfig version.
- `bashls` - lspconfig calls this `bashls`. The binary is `bash-language-server`. Should work.

**Additional issue with on_attach:** The `on_attach` function calls `vim.lsp.inlay_hint.enable(bufnr, true)`. In Neovim 0.10+, the signature is `vim.lsp.inlay_hint.enable(enable, filter)` where filter is optional. Passing `(bufnr, true)` treats the buffer number as the boolean enable flag (truthy), and `true` as the filter. This is a silent bug - it enables inlay hints globally instead of per-buffer. In 0.11, the correct call is:
```lua
vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
```

**Fix:** Either commit fully to native `vim.lsp.config()`/`vim.lsp.enable()` (and remove nvim-lspconfig from plugins.nix, adding `cmd` and `filetypes` to each server config), or use lspconfig's API (`require("lspconfig").lua_ls.setup({...})`). Mixing both is fragile. Also fix the inlay_hint.enable call signature.

### CRITICAL #5: `vim.diagnostic.goto_prev` / `goto_next` are deprecated in 0.11

**File:** `keymaps.lua:32-33`

```lua
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
```

**Problem:** In Neovim 0.11+, `vim.diagnostic.goto_prev()` and `vim.diagnostic.goto_next()` are deprecated in favor of `vim.diagnostic.jump()`. The rewrite overview explicitly calls this out in Appendix A: `vim.diagnostic.jump({count=1})`. Since this config targets Neovim 0.11+ (it uses `vim.lsp.config()`), it should use the current API.

**Fix:**
```lua
map("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, { desc = "Previous diagnostic" })
map("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, { desc = "Next diagnostic" })
```

---

## Part 3: High Priority Issues (Daily Use Impact)

### HIGH #1: `timeoutlen = 10` makes leader keys unusable

**File:** `options.lua:79`

```lua
opt.timeoutlen = 10
```

**Problem:** `timeoutlen` controls how many milliseconds Neovim waits for a mapped sequence to complete. With 10ms, you have 10 milliseconds to press the next key after `<leader>`. This is physically impossible for a human. Any multi-key mapping (`<leader>ff`, `<leader>gs`, etc.) will fail because Neovim times out before you can press the second key.

The entire keybinding design (50 leader-prefixed mappings) is broken by this single setting.

**Fix:** A reasonable value is 300-500ms:
```lua
opt.timeoutlen = 400
```

### HIGH #2: `cmdheight = 3` wastes screen space

**File:** `options.lua:62`

```lua
opt.cmdheight = 3
```

**Problem:** This reserves 3 lines at the bottom of the screen for the command line. The standard is 1. Even 2 is generous. 3 lines of dead space at all times is a significant waste of vertical real estate, especially on laptops.

**Fix:**
```lua
opt.cmdheight = 1
```

### HIGH #3: `pumheight = 0` means unlimited popup menu

**File:** `options.lua:64`

```lua
opt.pumheight = 0
```

**Problem:** `pumheight = 0` means no limit on the completion popup menu height. A long completion list will fill the entire screen. Combined with mini.completion, this creates a poor experience.

**Fix:**
```lua
opt.pumheight = 15
```

### HIGH #4: Keybinding duplication between keymaps.lua and plugin on_attach

**Files:** `keymaps.lua:18-29,35-44`, `lsp.lua:34-43`, `git.lua:33-44`

The following keybindings are defined in multiple places:

| Key | keymaps.lua | lsp.lua on_attach | git.lua on_attach |
|-----|-------------|-------------------|-------------------|
| `gd` | Yes | Yes | - |
| `gr` | Yes | Yes | - |
| `gD` | Yes | Yes | - |
| `gi` | Yes | Yes | - |
| `K` | Yes | Yes | - |
| `<leader>ca` | Yes | Yes | - |
| `<leader>cr` | Yes | Yes | - |
| `<leader>cf` | Yes | Yes | - |
| `<leader>cd` | Yes | Yes | - |
| `<leader>gs` | Yes | - | Yes |
| `<leader>gr` | Yes | - | Yes |
| `<leader>gp` | Yes | - | Yes |
| `<leader>gb` | Yes | - | Yes |
| `[h` / `]h` | Yes | - | Yes |

**Problem:** Every LSP keybinding is defined globally in keymaps.lua AND buffer-locally in lsp.lua's on_attach. The buffer-local ones override the global ones when LSP attaches, so it "works" - but the global ones fire in non-LSP buffers where `vim.lsp.buf.definition()` etc. will error or do nothing. Similarly, git keybindings are global in keymaps.lua but buffer-local in git.lua's on_attach, and the git.lua versions use different call styles (`:Gitsigns stage_hunk<CR>` vs `require("gitsigns").stage_hunk()`).

Additionally, git.lua on_attach defines `<leader>gD` twice:
```lua
map("n", "<leader>gD", gs.diffthis, "Diff this")
map("n", "<leader>gD", function() gs.diffthis("~") end, "Diff this (cached)")
```
The second definition silently overwrites the first.

**Fix:** Pick one canonical location for each keybinding:
- LSP keybindings: Keep ONLY in lsp.lua on_attach (they should only be active when LSP is attached)
- Git keybindings: Keep ONLY in git.lua on_attach (they should only be active in git-tracked buffers)
- Remove all LSP and git bindings from keymaps.lua
- Fix the duplicate `<leader>gD` - use `<leader>gd` for diffthis and `<leader>gD` for cached diff

### HIGH #5: keymaps.lua LSP maps missing `opts` table

**File:** `keymaps.lua:18-29`

```lua
map("n", "gd", vim.lsp.buf.definition, "Go to definition")
map("n", "gr", vim.lsp.buf.references, "References")
```

**Problem:** `vim.keymap.set` expects the 4th argument to be an options table, not a string. The correct form is `{ desc = "Go to definition" }`. Passing a bare string as the 4th argument is not valid and will error.

Compare to the correctly-written lines just above:
```lua
map("n", "<C-s>", "<cmd>write<cr>", { desc = "Save" })  -- Correct
map("n", "gd", vim.lsp.buf.definition, "Go to definition")  -- Wrong
```

**Fix:** Wrap all desc strings in options tables:
```lua
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
```

This affects lines 18-29 of keymaps.lua (all LSP/code maps).

### HIGH #6: EslintFixAll command may not exist

**File:** `lsp.lua:119-124`

```lua
vim.lsp.config("eslint", {
  on_attach = function(_, bufnr)
    on_attach(_, bufnr)
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      command = "EslintFixAll",
    })
  end,
})
```

**Problem:** `EslintFixAll` is a command registered by nvim-lspconfig's eslint config, not by the eslint LSP server itself. If using native `vim.lsp.config()` without lspconfig's eslint module loaded, this command won't exist. Even with lspconfig, it's only registered after the eslint server attaches, and the timing of this autocmd registration vs. the command registration is fragile.

More importantly, this contradicts the rewrite overview's clean ownership model. The overview says: "eslint LSP handles linting. Prettier handles formatting." Having eslint auto-fix on save means eslint is doing formatting work (rewriting code), which overlaps with prettierd via conform.

**Fix:** Remove the EslintFixAll autocmd. Let eslint LSP provide diagnostics only. Let conform + prettierd handle formatting for JS/TS files. If you want eslint's auto-fixable rules applied, add `eslint_d` to conform's formatters_by_ft for JS/TS (run after prettier).

### HIGH #7: mini.completion empty setup is insufficient

**File:** `mini.lua:67`

```lua
require("mini.completion").setup()
```

**Problem:** mini.completion with empty setup() will use its defaults, which actually do work for basic LSP completion. However, `vim.g.format_on_save` is never initialized (see Medium #1), and the interaction between mini.completion and the manual keymaps.lua `<leader>cf` format binding needs thought.

The bigger concern: mini.completion with default config relies on `omnifunc` being set, which LSP servers do set. But it has no snippet support. The rewrite overview says "try vim.snippet first" but no snippet configuration exists. LSP servers will send snippet completions, and mini.completion will insert them as literal text (e.g., `functionName(${1:param})` instead of `functionName(param)` with the cursor on `param`).

**Fix:** Either:
1. Configure vim.snippet as the snippet handler (Neovim 0.11+ supports this natively through `vim.lsp.completion`)
2. Or document that snippets won't expand and this is intentional
3. Or add actual mini.completion configuration with snippet handling disabled

### HIGH #8: LSP hover handler override uses wrong API

**File:** `lsp.lua:12-23`

```lua
local orig_hover = vim.lsp.handlers.hover
vim.lsp.handlers.hover = function(_, result, ctx, config)
  config = config or {}
  config.border = border
  orig_hover(_, result, ctx, config)
end
```

**Problem:** In Neovim 0.11+, `vim.lsp.handlers` is deprecated. The `vim.lsp.buf.hover()` function now accepts a config table directly. The correct way to add borders:

```lua
vim.lsp.buf.hover({ border = "rounded" })
```

Or set it globally via:
```lua
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
```

The current approach of monkey-patching `vim.lsp.handlers.hover` works in 0.10 but is fragile and deprecated in 0.11. Since this config uses 0.11+ APIs elsewhere, it should be consistent.

**Fix:**
```lua
-- Remove the handler overrides. Instead, configure borders globally:
vim.diagnostic.config({
  float = { border = "rounded", source = true },
})

-- For hover, pass border in keybinding:
map("n", "K", function() vim.lsp.buf.hover({ border = "rounded" }) end, { desc = "Hover" })
```

### HIGH #9: `format_on_save` in format.lua has dead conditional

**File:** `format.lua:18-28`

```lua
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
```

**Problem:** The Python-specific branch returns the exact same config as the default branch. The `ext == "py"` check does nothing.

**Fix:** Either remove the dead conditional, or if Python needs different settings, actually differentiate:
```lua
format_on_save = function(bufnr)
  if vim.g.format_on_save == false then return false end
  return { timeout_ms = 500, lsp_fallback = true }
end,
```

### HIGH #10: formatexpr override is broken

**File:** `format.lua:32-37`

```lua
vim.formatexpr = function()
  if vim.g.format_on_save == false then
    return vim.fn["conform#formatexpr"]()
  end
  return vim.fn["conform#formatexpr"]()
end
```

**Problem:** Both branches return the same thing (the intern caught this). But additionally, `vim.formatexpr` is not a valid Neovim setting. The correct way to set formatexpr is:
```lua
vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
```
Or simply:
```lua
-- Not needed - conform sets this automatically when configured
```

The current code assigns a function to a non-existent global, so it has zero effect.

**Fix:** Remove entirely. Conform handles `gq` formatting via its own `formatexpr` option if needed:
```lua
require("conform").setup({
  formatters_by_ft = { ... },
  format_on_save = { ... },
  -- formatexpr is handled automatically by conform
})
```

### HIGH #11: `<C-d>` / `<C-u>` mapping order is wrong

**File:** `keymaps.lua:106-107`

```lua
map("n", "<C-d>", "zz<C-d>zz", { desc = "Half-page down" })
map("n", "<C-u>", "zz<C-u>zz", { desc = "Half-page up" })
```

**Problem:** `zz<C-d>zz` centers the screen, THEN scrolls down, THEN centers again. The first `zz` is wasted motion. What you want is scroll then center:
```lua
map("n", "<C-d>", "<C-d>zz", { desc = "Half-page down" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half-page up" })
```

---

## Part 4: Medium Priority Issues (Suboptimal but Functional)

### MEDIUM #1: `vim.g.format_on_save` never initialized

**File:** `options.lua` (missing), `keymaps.lua:68-71`

```lua
map("n", "<leader>uf", function()
  vim.g.format_on_save = not vim.g.format_on_save
  vim.notify(vim.g.format_on_save and "Format on save enabled" or "Format on save disabled")
end, { desc = "Toggle format on save" })
```

**Problem:** `vim.g.format_on_save` starts as `nil`. `not nil` is `true`, so the first toggle sets it to `true` and reports "Format on save enabled" - but it was already enabled (the autocmds/conform check `~= false`). So the first press appears to do nothing. The second press sets it to `false` and actually disables formatting. The toggle is off-by-one in user perception.

**Fix:** Add to options.lua:
```lua
vim.g.format_on_save = true
```

### MEDIUM #2: mini.clue triggers are incomplete

**File:** `mini.lua:55-58`

```lua
require("mini.clue").setup({
  triggers = {
    { mode = "n", keys = "<leader>" },
    { mode = "i", keys = "<C-x>" },
  },
```

**Problem:** Only shows hints for `<leader>` in normal mode and `<C-x>` in insert mode. The keymap design includes `[`/`]` navigation (diagnostics, hunks), `g` prefixed commands (gd, gr, etc.), and visual mode `<leader>` mappings. None of these will show hints.

**Fix:**
```lua
triggers = {
  { mode = "n", keys = "<leader>" },
  { mode = "v", keys = "<leader>" },
  { mode = "n", keys = "[" },
  { mode = "n", keys = "]" },
  { mode = "n", keys = "g" },
  { mode = "n", keys = "s" },  -- mini.surround
  { mode = "i", keys = "<C-x>" },
},
```

### MEDIUM #3: mini.clue references non-existent function

**File:** `mini.lua:60`

```lua
clues = {
  require("mini.clue").gen_clue.zsh(),
  require("mini.clue").gen_clue.builtin_keys(),
},
```

**Problem:** There is no `gen_clue.zsh()` in mini.clue. The actual generators are:
- `gen_clues.builtin_completion()`
- `gen_clues.g()`
- `gen_clues.marks()`
- `gen_clues.registers()`
- `gen_clues.windows()`
- `gen_clues.z()`

Note: it's `gen_clues` (plural), not `gen_clue`. And `z()` not `zsh()`.

**Fix:**
```lua
clues = {
  require("mini.clue").gen_clues.builtin_completion(),
  require("mini.clue").gen_clues.g(),
  require("mini.clue").gen_clues.z(),
  require("mini.clue").gen_clues.windows(),
  require("mini.clue").gen_clues.marks(),
  require("mini.clue").gen_clues.registers(),
},
```

### MEDIUM #4: mini.pick `ui_select` configuration is wrong

**File:** `mini.lua:19`

```lua
require("mini.pick").setup({
  ui_select = true,
})
```

**Problem:** mini.pick does not accept `ui_select` as a setup option. To use mini.pick as the `vim.ui.select` handler, you need to set it explicitly:
```lua
require("mini.pick").setup()
vim.ui.select = require("mini.pick").ui_select
```

The current config silently ignores the `ui_select = true` field and falls back to Neovim's default `vim.ui.select`.

### MEDIUM #5: mini.files `toggle()` does not exist

**File:** `keymaps.lua:16`

```lua
map("n", "<leader>e", function() require("mini.files").toggle() end, { desc = "Toggle file explorer" })
```

**Problem:** mini.files does not have a `toggle()` method. The correct API is:
```lua
-- Open at current file:
require("mini.files").open(vim.api.nvim_buf_get_name(0))
-- Or open at cwd:
require("mini.files").open()
-- Close:
require("mini.files").close()
```

**Fix:**
```lua
map("n", "<leader>e", function()
  local mf = require("mini.files")
  if not mf.close() then
    mf.open(vim.api.nvim_buf_get_name(0), false)
  end
end, { desc = "Toggle file explorer" })
```

### MEDIUM #6: mini.pick `builtin.recent()` does not exist

**File:** `keymaps.lua:14`

```lua
map("n", "<leader>fr", function() require("mini.pick").builtin.recent() end, { desc = "Recent files" })
```

**Problem:** mini.pick does not have a `recent()` builtin. The available builtins are:
- `files()`
- `grep()`
- `grep_live()`
- `buffers()`
- `help()`
- `resume()`
- `cli()`

For recent files, you'd use mini.extra's `pickers.oldfiles()` or mini.visits.

**Fix:** Either remove the binding, use `vim.cmd("browse oldfiles")`, or install mini.extra and use:
```lua
map("n", "<leader>fr", function() require("mini.extra").pickers.oldfiles() end, { desc = "Recent files" })
```

### MEDIUM #7: mini.sessions `select()` API is wrong

**File:** `keymaps.lua:76-77`

```lua
map("n", "<leader>qs", function() require("mini.sessions").select("write") end, { desc = "Save session" })
map("n", "<leader>qr", function() require("mini.sessions").select("read") end, { desc = "Restore session" })
```

**Problem:** `MiniSessions.select()` takes an optional `action` parameter, but the valid values are `"read"`, `"write"`, and `"delete"`. However, `select("write")` presents a picker to choose which session to overwrite - it doesn't save the current session. For saving the current session, use `write()` directly.

**Fix:**
```lua
map("n", "<leader>qs", function() require("mini.sessions").write() end, { desc = "Save session" })
map("n", "<leader>qr", function() require("mini.sessions").select("read") end, { desc = "Restore session" })
```

### MEDIUM #8: Obsidian plugin references nvim-cmp

**File:** `tools.lua:11`

```lua
completion = {
  nvim_cmp = true,
  min_chars = 2,
},
```

**Problem:** This config tells obsidian.nvim to use nvim-cmp for completions, but nvim-cmp is not installed. The config uses mini.completion instead. This will silently fail - obsidian completions won't work.

**Fix:**
```lua
completion = {
  nvim_cmp = false,
  min_chars = 2,
},
```

### MEDIUM #9: Lint file references linters not in hm-module.nix packages

**File:** `lint.lua:5,10`

```lua
lua = { "selene" },
go = { "golangcilint" },
```

**Problem:** Neither `selene` nor `golangci-lint` are listed in the `home.packages` section of hm-module.nix. These linters won't be available at runtime and will fail silently (nvim-lint suppresses errors for missing linters).

**Fix:** Add to hm-module.nix packages, or remove from lint config:
```nix
# In hm-module.nix home.packages:
selene
golangci-lint
```

---

## Part 5: Minor Issues (Polish)

### MINOR #1: `hm-module.nix` lists `ruff` twice

**File:** `hm-module.nix:42,48`

```nix
# Formatters
ruff

# Linters
ruff
```

**Problem:** Nix won't error on this, but it's sloppy. Ruff appears in both the Formatters and Linters sections.

**Fix:** List ruff once, in whichever section makes more sense (or create a "Multi-purpose" section).

### MINOR #2: Flake inputs are unused

**File:** `flake.nix`

The flake declares 18 inputs (mini-nvim-src, nvim-lspconfig, conform-nvim, etc.) but the only output is:
```nix
outputs = inputs@{ self, ... }: {
  homeManagerModules.default = import ./hm-module.nix { inherit inputs; };
};
```

And hm-module.nix only uses `inputs.mini-nvim-src`. The other 17 inputs are declared, pinned, and tracked in flake.lock, but never referenced. This adds maintenance burden (flake updates) for no benefit.

**Fix:** Remove all inputs except nixpkgs and mini-nvim-src. Everything else comes from pkgs.vimPlugins.

### MINOR #3: Auto-close buffer autocmd is aggressive

**File:** `autocmds.lua:68-74`

```lua
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*",
  callback = function()
    if vim.fn.winnr("$") == 1 and vim.fn.bufname("%") == "" and vim.fn.bufnr("%") > 1 then
      vim.cmd("bdelete!")
    end
  end,
})
```

**Problem:** This auto-deletes empty buffers when they're the last window. This can interfere with plugin behavior (e.g., mini.starter creates empty buffers, DAP UI creates unnamed buffers). It may also surprise users who intentionally have an empty scratch buffer.

**Fix:** Either remove, or add exceptions for known plugin buffer types.

### MINOR #4: Trailing whitespace trimmed twice

**Files:** `autocmds.lua:82-87`, `mini.lua:27`

```lua
-- autocmds.lua: Trim on save via regex
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    local pos = vim.fn.getpos(".")
    vim.cmd([[keeppatterns %s/\s\+$//e]])
    vim.fn.setpos(".", pos)
  end,
})

-- mini.lua: mini.trailspace also handles trailing whitespace
require("mini.trailspace").setup()
```

mini.trailspace highlights trailing whitespace and provides `MiniTrailspace.trim()`. The autocmd also trims on save via regex. These don't technically conflict (the autocmd trims, mini.trailspace highlights), but it's redundant to have both. Use `MiniTrailspace.trim()` in the autocmd instead of raw regex, or just keep the autocmd and use mini.trailspace only for highlighting.

### MINOR #5: CodeCompanion API key validation missing

**File:** `codecompanion.lua:5-7`

```lua
env = {
  api_key = os.getenv("ANTHROPIC_API_KEY") or "",
},
```

If the env var is missing, an empty string is sent as the API key, producing a confusing authentication error from the API. A startup warning would be more helpful.

### MINOR #6: Visual mode J/K mappings conflict with mini.move

**File:** `keymaps.lua:102-103`

```lua
map("v", "J", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })
```

**File:** `mini.lua:65`

```lua
require("mini.move").setup()
```

mini.move's default mappings for visual mode are Alt+h/j/k/l. These custom J/K visual maps don't technically conflict with mini.move's defaults, but the rewrite overview says to use mini.move for this: "J / K (visual): Move selection up/down -> mini.move." Either use mini.move's defaults (Alt+j/k) or configure mini.move to use J/K in visual mode. Don't have both a manual implementation and the plugin.

---

## Part 6: Nix Configuration Review

### default.nix

```nix
(pkgs.writeShellScriptBin cmdName ''
  exec ${pkgs.neovim}/bin/nvim -u "${srcDir}/nvim/init.lua" \
    --cmd "set rtp^=${srcDir}/nvim" \
    ${builtins.concatStringsSep " " (map (p: "--cmd \"set rtp+=${p}\"") allPlugins)} \
    "$@"
'')
```

**Problem:** `allPlugins` is a list of derivations. `"set rtp+=${p}"` will interpolate each derivation as its store path (e.g., `/nix/store/xxx-nvim-lspconfig`). However, Vim plugins need to be on the rtp at their actual plugin directory, which may be nested. For vimPlugins from nixpkgs, the derivation output IS the plugin directory, so this works. But it's fragile and depends on all plugins having the right structure at their top-level output.

Also, this approach doesn't run plugin `after/` directories or `plugin/` init scripts in the standard way. Neovim's package loading expects plugins in `packpath`, not individual rtp entries. Consider using `pkgs.neovimUtils.makeNeovimConfig` or `wrapNeovim` instead for more robust plugin loading.

**Assessment:** Works for simple plugins but will break for plugins with complex directory structures or those that rely on packpath loading.

### hm-module.nix

**Assessment:** Mostly correct. Uses `programs.neovim.plugins` which handles rtp correctly. The main issue is the incomplete plugin list (Critical #3) and duplicate ruff (Minor #1).

### flake.nix

**Assessment:** Overly complex for what it does. 18 inputs, only 1 used. See Minor #2.

### plugins.nix

**Assessment:** Clean but incomplete. See Critical #3 for missing plugins.

---

## Part 7: Assessment of the Intern's Review

The intern's code review identified some real issues but missed many critical ones and made several incorrect assessments. Here's a scorecard:

### What the intern got right:
- Identified the ruff triple-coverage problem (their Issue #I)
- Spotted the formatexpr dead conditional (their Issue #J)
- Noticed gitsigns keybinding duplication (their Issue #B)
- Flagged the EslintFixAll concern (their Issue #H)
- Correctly identified mini.completion needs more config (their Issue #F)
- Good catch on neotest-rust availability (their Issue #M)

### What the intern got wrong:

**1. Declared status "COMPLETE AND READY FOR INTEGRATION"** - This is incorrect. The config has 5 critical issues that would prevent it from building or running correctly.

**2. Gave it 85/100** - This score is unjustified. A config that won't build (missing plugins in plugins.nix) and has unusable keybindings (10ms timeoutlen) should not score above 50.

**3. Missed the timeoutlen=10 problem** - This is the single most impactful bug in the entire config. It makes every leader-key mapping physically impossible to use. The intern's review of options.lua said "Issues Found: NONE" which means they didn't test the config or think through the implications of each setting.

**4. Missed the missing plugins in plugins.nix** - treesitter-context, neotest-rust, obsidian, markdown-preview, nvim-dap-python, nvim-nio, and plenary.nvim are all required by Lua code but absent from plugins.nix. This is a build failure.

**5. Missed keymaps.lua bare string desc arguments** - The intern reproduced the code but didn't notice that half the keymap definitions pass a bare string instead of an opts table as the 4th argument to vim.keymap.set.

**6. Missed the deprecated diagnostic API** - `vim.diagnostic.goto_prev/next` are deprecated in Neovim 0.11+, which this config targets.

**7. Missed mini.pick API errors** - `builtin.recent()` doesn't exist, `ui_select = true` in setup doesn't work, `mini.files.toggle()` doesn't exist. These would cause immediate runtime errors.

**8. Missed mini.clue `gen_clue.zsh()` doesn't exist** - The function is `gen_clues.z()` (plural, no "sh").

**9. Incorrect LspProgress event assessment** - The intern's Issue #D claimed the LspProgress event parsing was "fragile" and suggested using `ev.data.message`. But the actual Neovim LspProgress event structure IS `ev.data.params.value` - the original code was closer to correct than the intern's "fix." However, the exact structure depends on the Neovim version. In 0.10+, it's `ev.data.result` not `ev.data.params`.

**10. Terminal scope issue overstated** - The intern flagged `term_buf` scope as a problem because "keymaps are ever reloaded." In practice, keymaps.lua is loaded once via `require()` which is cached by Lua's module system. The variable persists for the entire Neovim session. This is not a real issue unless someone calls `package.loaded["config.keymaps"] = nil` and re-requires it, which would be unusual.

**11. Didn't verify mini.nvim API calls** - Multiple mini.nvim API calls are incorrect (mini.files.toggle, mini.pick.builtin.recent, mini.clue.gen_clue.zsh, mini.pick ui_select config). The intern marked mini.lua as having only two issues (completion and clue triggers) when there are at least four.

**12. Missed the double format-on-save** - The intern identified Issue #E (format-on-save redundancy) but misdiagnosed it. They said the autocmd calls `vim.lsp.buf.format()` while conform also handles it, and suggested either removing the autocmd OR calling conform instead. The correct answer is always "remove the autocmd" - that's what conform is FOR. But more importantly, they didn't elevate this to Critical severity despite it being the exact class of "plugins fighting each other" bug the rewrite was designed to eliminate.

### Summary of intern review quality:
- Identified ~40% of actual issues
- Severity classifications were too generous
- Several recommended fixes were themselves incorrect
- Did not verify any mini.nvim API calls against documentation
- Did not test or mentally execute the configuration
- Top-level assessment ("Ready for integration") was dangerously wrong

---

## Part 8: Complete Issue Summary

### Critical (Will not work)

| # | Issue | File | Fix |
|---|-------|------|-----|
| C1 | Double format-on-save (autocmd + conform) | autocmds.lua, format.lua | Remove BufWritePre format autocmd |
| C2 | Ruff triple-coverage (LSP + lint + format) | lsp.lua, lint.lua, format.lua | Remove ruff from lsp.lua |
| C3 | Missing plugins in plugins.nix | plugins.nix | Add treesitter-context, plenary, nvim-nio, etc. |
| C4 | vim.lsp.config/enable + lspconfig interaction, wrong inlay_hint API | lsp.lua | Fix inlay_hint call, decide on lspconfig vs native |
| C5 | Deprecated diagnostic.goto_prev/next | keymaps.lua | Use vim.diagnostic.jump() |

### High (Broken daily use)

| # | Issue | File | Fix |
|---|-------|------|-----|
| H1 | timeoutlen=10 makes leader keys unusable | options.lua | Set to 400 |
| H2 | cmdheight=3 wastes space | options.lua | Set to 1 |
| H3 | pumheight=0 unlimited popup | options.lua | Set to 15 |
| H4 | Keybinding duplication (keymaps + on_attach) | keymaps.lua, lsp.lua, git.lua | Single canonical location per binding |
| H5 | Bare string desc in keymap.set (missing opts table) | keymaps.lua | Wrap in { desc = "..." } |
| H6 | EslintFixAll may not exist, contradicts ownership model | lsp.lua | Remove, let conform handle |
| H7 | mini.completion has no snippet support configured | mini.lua | Configure or document limitation |
| H8 | LSP hover handler uses deprecated API | lsp.lua | Use 0.11+ border config |
| H9 | format.lua dead Python conditional | format.lua | Remove dead branch |
| H10 | formatexpr assignment is a no-op | format.lua | Remove entirely |
| H11 | C-d/C-u centering order wrong | keymaps.lua | Scroll then center |

### Medium (Suboptimal)

| # | Issue | File | Fix |
|---|-------|------|-----|
| M1 | format_on_save not initialized | options.lua | Add vim.g.format_on_save = true |
| M2 | mini.clue triggers incomplete | mini.lua | Add [, ], g, v triggers |
| M3 | mini.clue gen_clue.zsh() doesn't exist | mini.lua | Use gen_clues.z() (plural) |
| M4 | mini.pick ui_select config wrong | mini.lua | Set vim.ui.select explicitly |
| M5 | mini.files.toggle() doesn't exist | keymaps.lua | Use open()/close() pattern |
| M6 | mini.pick.builtin.recent() doesn't exist | keymaps.lua | Use oldfiles or mini.extra |
| M7 | mini.sessions.select("write") wrong for save | keymaps.lua | Use write() directly |
| M8 | Obsidian references nvim_cmp | tools.lua | Set nvim_cmp = false |
| M9 | Linters not in hm-module packages | lint.lua, hm-module.nix | Add selene, golangci-lint |

### Minor (Polish)

| # | Issue | File | Fix |
|---|-------|------|-----|
| m1 | ruff listed twice in hm-module | hm-module.nix | Deduplicate |
| m2 | 17 unused flake inputs | flake.nix | Remove unused inputs |
| m3 | Auto-close buffer autocmd too aggressive | autocmds.lua | Add exceptions or remove |
| m4 | Trailing whitespace trimmed by autocmd AND mini.trailspace | autocmds.lua, mini.lua | Use one approach |
| m5 | CodeCompanion missing API key validation | codecompanion.lua | Add startup warning |
| m6 | Visual J/K conflicts with mini.move purpose | keymaps.lua, mini.lua | Use one approach |

---

## Part 9: Recommended Fix Order

**Phase 1: Make it build and run (1-2 hours)**
1. Fix plugins.nix - add all missing plugins (C3)
2. Fix timeoutlen (H1), cmdheight (H2), pumheight (H3)
3. Fix bare string desc in keymaps (H5)
4. Fix deprecated diagnostic API (C5)

**Phase 2: Fix ownership conflicts (1-2 hours)**
5. Remove BufWritePre format autocmd (C1)
6. Remove ruff from lsp.lua (C2)
7. Remove EslintFixAll autocmd (H6)
8. Consolidate keybindings to one location (H4)
9. Remove formatexpr override (H10)

**Phase 3: Fix mini.nvim API calls (1 hour)**
10. Fix mini.files toggle (M5)
11. Fix mini.pick recent (M6)
12. Fix mini.pick ui_select (M4)
13. Fix mini.clue gen_clues (M3) and triggers (M2)
14. Fix mini.sessions save binding (M7)

**Phase 4: Fix LSP layer (1 hour)**
15. Decide on lspconfig vs native vim.lsp.config (C4)
16. Fix inlay_hint.enable signature (C4)
17. Fix hover handler to use 0.11+ API (H8)

**Phase 5: Polish (30 min)**
18. Remove dead format.lua conditional (H9)
19. Fix C-d/C-u order (H11)
20. Clean up flake inputs (m2)
21. Fix remaining minor issues

**Total estimated effort: 5-7 hours**

---

## Part 10: Testing Checklist

After fixes, verify each of these works:

- [ ] `nvim +'q'` - loads without errors
- [ ] `<leader>ff` - opens file picker (verify mini.pick works)
- [ ] `<leader>e` - opens file explorer (verify mini.files toggle works)
- [ ] `<leader>fr` - opens recent files (verify replacement for builtin.recent)
- [ ] Open a Python file - pyright starts, diagnostics appear
- [ ] Save a Python file - ruff formats via conform (not LSP, not autocmd)
- [ ] `[d` / `]d` - jumps between diagnostics (verify vim.diagnostic.jump)
- [ ] `K` - shows hover with rounded borders
- [ ] `<leader>gs` - stages git hunk (only one binding, no conflict)
- [ ] `<A-i>` - toggles terminal
- [ ] `<leader>` then wait - mini.clue shows available keys (with all groups)
- [ ] `:map <leader>gs` - shows exactly ONE mapping, not two
- [ ] `<leader>uf` - toggles format on save (first press disables, second enables)
- [ ] Open JS file - eslint provides diagnostics, prettier formats on save
- [ ] No duplicate diagnostics in any language
- [ ] No double formatting on save

---

## Conclusion

**Revised Assessment: 45/100 - STRONG FOUNDATION, NOT YET FUNCTIONAL**

The architecture is right. The mental model is right. The plugin selection is right. But the implementation has too many bugs - incorrect API calls, deprecated functions, missing plugins, unusable settings, and the exact class of ownership conflicts the rewrite was designed to eliminate. None of these are hard to fix, but they need to be fixed before this config can be used as a daily driver.

The good news: the issues are all in the details, not the design. The design is solid. Fix the 31 issues cataloged above (5-7 hours of work) and this will be a genuinely excellent, minimal, coherent Neovim configuration.

---

**Document Generated:** 2026-03-01
**Review Method:** Line-by-line reading of all 24 files, cross-referenced against NIXVIM_REWRITE_OVERVIEW.md spec and Neovim 0.11+ / mini.nvim API documentation
**Config Version:** nix_neovim_v2
**Status:** Needs fixes before deployment
