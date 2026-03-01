# NIXVIM to nix_neovim Rewrite Overview

## Executive Summary

This document outlines the complete feature set of your current nixvim-based daily driver configuration and provides a migration plan to a lua-based configuration built with `nix_neovim`, leveraging built-in Neovim v0.12+ functionality and the mini.nvim framework.

**Current Status**: nixvim provides 50+ plugins across 62 configuration modules
**Target Approach**: Consolidate into lua-based config using mini.nvim and builtin features

---

## Part 1: Current Daily Driver Configuration Inventory

### A. EDITOR FUNDAMENTALS (sets.nix)

#### Enabled Features
- **Line Numbers**: Absolute (relative disabled by default)
- **Indentation**: 2-space tabs, smart indent enabled, expandtab
- **Search**: Case-insensitive with smart case, ripgrep integration (`--vimgrep`)
- **Performance**: updatetime=50ms, signcolumn always visible
- **History**: Persistent undo enabled, no swapfiles/backups
- **Wrapping**: Enabled with breakindent
- **Scrolling**: 8-line scrolloff (center cursor), splitbelow/splitright
- **Display**: 24-bit colors, cursorline highlight, 120-column guide
- **Cursor Modes**: Block (normal/visual/cmd), vertical bar (insert), horizontal (replace)
- **Whitespace**: Visible list chars (space/trail/extends/precedes/nbsp)
- **Command**: 3-line height, showmode enabled
- **Encoding**: UTF-8
- **Fold**: foldenable with foldlevel=99 on start
- **GUI** (Neovide): MonoLisa Trial 15px, ripple cursor, 0.8 transparency, 165Hz refresh

**Complexity Score**: ⭐⭐ (well-organized, mostly standard settings)

---

### B. KEYBINDINGS & MAPPINGS (keymaps.nix)

#### Key Statistics
- **Total Mappings**: 80+ keybindings
- **Leader Key**: SPACE
- **Structure**: Categorical with group prefixes

#### Category Breakdown

| Category | Prefix | Function | Count |
|----------|--------|----------|-------|
| File/Find | `<leader>f` | Find files, grep, buffers | 6+ |
| Search | `<leader>s` | Search operations | ~3 |
| Quit/Session | `<leader>q` | Exit, session mgmt, restore | 4 |
| Git | `<leader>g` | Git operations | Various (via plugins) |
| UI | `<leader>u` | Toggles (lines, wrap, hints) | 4 |
| Windows | `<leader>w` | Split, navigate, close | 4 |
| Navigation | `<leader><Tab>` | Buffer & tmux navigation | ~8 |
| Debug | `<leader>d` | DAP operations | ~15 |
| Code | `<leader>c` | LSP, formatting, actions | Various (via plugins) |
| Test | `<leader>t` | Test execution | ~8 |
| Obsidian | `<leader>o` | Note management | 5 |

#### Core Navigation Mappings
- **Movement**: j/k (smart wrap), n/N (search centering), J (join), C-d/u (center)
- **Selection**: Visual J/K (move lines), </> (indent while selected)
- **Paste**: `<leader>p` (paste without clobbering register)
- **Copy**: C-c/C-C (system clipboard)

#### Custom Lua Functions
1. `ToggleLineNumber()` - Toggle absolute line numbers with notification
2. `ToggleRelativeLineNumber()` - Toggle relative line numbers with notification
3. `ToggleWrap()` - Toggle text wrapping with notification

**Complexity Score**: ⭐⭐⭐⭐ (extensive, well-organized, clear semantics)

---

### C. LANGUAGE SERVER PROTOCOL (LSP)

#### Enabled Servers (lsp.nix)
| Language | Server | Features |
|----------|--------|----------|
| C/C++ | clangd | Full IDE support |
| Lua | lua_ls | Hints, call snippets, telemetry=off |
| Nix | nil_ls | Complete Nix support |
| JavaScript/TypeScript | eslint | Linting (via lspsaga) |
| Python | pyright + ruff-lsp | Type checking + linting |
| Rust | rust-analyzer | Clippy, proc macros, inlay hints |

#### LSP UI Configuration (via LSPSaga)
- **Navigation**: gd (definition), gr (references), gI (implementation), gT (type)
- **Hover**: K (documentation with borders)
- **Rename**: `<leader>cr` (via LSPSaga)
- **Code Actions**: `<leader>ca` (with lightbulb)
- **Diagnostics**: `<leader>cd`, [d/]d (jump)
- **Breadcrumbs**: Symbol navigation in winbar
- **Beacon**: Cursor jump highlighting

**Complexity Score**: ⭐⭐⭐ (sophisticated, uses LSPSaga for advanced features)

---

### D. CODE FORMATTING & LINTING

#### Conform.nvim (Formatting)
| Languages | Tools |
|-----------|-------|
| HTML/CSS/Markdown | Prettierd/Prettier |
| JavaScript/TypeScript | Prettierd/Prettier |
| Java | Google Java Format |
| Python | Ruff Format |
| Lua | Stylua |
| Nix | Alejandra |
| Rust | Rustfmt |

**Features**: Auto-format on save (toggleable via `<leader>uf`)

#### Nvim-Lint (Linting)
| Languages | Tools |
|-----------|-------|
| Nix | Statix |
| Lua | Selene |
| Python | Ruff |
| JavaScript/TypeScript | ESLint_d |
| JSON | Jsonlint |
| Java | Checkstyle |

**Complexity Score**: ⭐⭐ (well-integrated, external tool management)

---

### E. COMPLETION SYSTEM

#### Nvim-CMP Engine
- **Sources** (priority order):
  1. LSP completions
  2. Emoji
  3. Buffer text (3+ chars)
  4. Copilot suggestions
  5. File paths (3+ chars)
  6. Luasnip snippets (3+ chars)

#### Configuration
- **Performance**: 60ms debounce, 200ms fetch timeout, max 30 visible
- **Keys**: C-j/k (select), Tab (confirm), C-Space (trigger), C-b/f (scroll docs)

#### Copilot Integration
- **Mode**: CMP-integrated (panel disabled)
- **Format**: Suggestion display with icon

#### Luasnip (Snippets)
- **Library**: friendly-snippets (VSCode-style)
- **Auto-snippets**: Enabled
- **Selection**: Tab key

**Complexity Score**: ⭐⭐⭐ (multiple sources, Copilot integration adds complexity)

---

### F. FUZZY FINDING & FILE NAVIGATION

#### Telescope (Primary Picker)
**File/Project Operations**:
- `<leader><space>/ff` - Find project files
- `<C-p>` - Search git files
- `<leader>/` - Live grep
- `<leader>fb` - List buffers
- `<leader>fr` - Recent files
- `<leader>fp` - Projects (via project.nvim)

**Git Integration**:
- `<leader>gc/gs` - Commits/Status

**Search**:
- `<leader>sa-sR` - Various (autocommands, buffer, commands, diag, help, highlights, keys, marks, options, resume)
- `<leader>sd` - Document diagnostics
- `<leader>st` - Search todos
- `<leader>uC` - Colorscheme preview

**Extensions**:
- fzf-native (sorting)
- ui-select (LSP code actions)
- undo (undo tree browser)

#### Mini.files
- `<leader>e` - File explorer (simple file tree)

#### Project.nvim
- Project detection and switching

**Complexity Score**: ⭐⭐⭐ (feature-rich, multiple extensions)

---

### G. DEBUGGING (DAP)

#### Configuration
- **Python**: dap-python
- **Java**: Remote debugging (port 5005)
- **UI Extensions**: DAP UI, Virtual Text

#### Keybindings
| Key | Action |
|-----|--------|
| `<leader>db` | Toggle breakpoint |
| `<leader>dB` | Conditional breakpoint |
| `<leader>dc` | Continue |
| `<leader>da` | Run with args |
| `<leader>dC` | Run to cursor |
| `<leader>di/O/o` | Step into/over/out |
| `<leader>dj/dk` | Stack up/down |
| `<leader>dr` | Toggle REPL |
| `<leader>du` | DAP UI toggle |
| `<leader>dt` | Terminate |

**Complexity Score**: ⭐⭐⭐ (complex feature, language-specific adapters)

---

### H. TESTING (Neotest)

#### Configuration
- **Adapters**: Python, Vitest, Plenary
- **Features**: Auto-open output, summary window

#### Keybindings
| Key | Action |
|-----|--------|
| `<leader>tt` | Run current test file |
| `<leader>tT` | Run all tests |
| `<leader>tr` | Run nearest test |
| `<leader>td` | Debug test (via DAP) |
| `<leader>ts` | Toggle summary |
| `<leader>to` | Show output |

**Complexity Score**: ⭐⭐⭐ (multiple adapters, DAP integration)

---

### I. GIT INTEGRATION

#### Gitsigns (Git decorations)
- **Hunks**: `<leader>ghp` (preview), `<leader>ghs/r` (stage/reset), `<leader>ghS/R` (buffer)
- **Blame**: `<leader>ghb` (current line)
- **Diff**: `<leader>ghd` (file diff)

#### Neogit (Status/Commit Interface)
- `<leader>gg` - Open Neogit buffer

#### Diffview.nvim
- Side-by-side diffs integrated with Neogit

#### Octo.nvim (GitHub)
- Issues, PRs, discussions directly in Neovim

**Complexity Score**: ⭐⭐⭐ (three complementary tools, rich workflow)

---

### J. UI/UX ENHANCEMENTS

#### Colorscheme: Catppuccin Mocha
- **Theme**: Dark mode, transparent background
- **Integrations**: LSP, Treesitter, Noice, Notify, Telescope, Mini, Gitsigns, Indent-blankline, Illuminate

#### Alpha (Dashboard)
- Splash screen with quick action buttons (find files, new file, recent, search, restore session, quit)

#### Noice (Command/Message UI)
- Popupmenu via NUI
- Filter/replace command preview
- LSP messages enabled

#### Nvim-notify (Notifications)
- FPS: 60, Timeout: 1s, Stacked top-down
- Dismiss via `<leader>un`

#### Dressing.nvim (Input/Select UI)
- Rounded borders
- Smart backend selection (Telescope > FZF > NUI > Builtin)

#### Bufferline
- **Style**: Slant separator, underline indicator
- **Navigation**: Tab/S-Tab (cycle), S-h/S-l (alt), `<leader><Tab><Space>h/l/d/p/P` (prev/next/delete/pin)

#### Indent-blankline
- Visual guides `│`, scope highlighting, buffer type exclusions

#### Lualine (Statusline)
- Theme: Auto, global status, FZF extension

**Complexity Score**: ⭐⭐⭐⭐ (5 complementary UI plugins, rich visual customization)

---

### K. UTILITIES & CONVENIENCES

#### Session Management: Persistence
- Auto-save/restore sessions
- Controls: `<leader>qs` (save), `<leader>ql` (last), `<leader>qd` (don't save)

#### Terminal: Toggleterm
- `<A-i>` - Toggle terminal (15-line horizontal, Zsh)
- Auto-scroll, persistent mode, close on exit

#### Window Navigation: Tmux Navigator
- Seamless Neovim ↔ Tmux pane navigation

#### Word Highlight: Illuminate
- Currently **disabled** (would highlight word occurrences)

#### Todo Comments
- Highlights TODO/FIXME/etc in code
- Integration with Telescope (`<leader>st`) and Trouble

#### Better-escape
- Smooth escape key handling

#### Undotree (`<leader>ut`)
- Undo history visualization

#### Vim-be-good
- Vim practice/training plugin

#### Markdown Preview
- Browser preview for Markdown files

#### NVim-colorizer
- Inline color preview in code

#### Wilder (Command Completion)
- Fuzzy command-line completion (Python-based)

#### Plenary
- Lua utility library (dependency)

#### Mini Suite Integrations
- **mini.ai**: Smart text objects
- **mini.basics**: Window management, buffer deletion
- **mini.comment**: Line comment toggle (`<leader>/`)
- **mini.diff**: Diff visualization
- **mini.pairs**: Auto pair handling
- **mini.clue**: Keymap helper/which-key

**Complexity Score**: ⭐⭐⭐ (broad ecosystem, many small conveniences)

---

### L. LANGUAGE-SPECIFIC FEATURES

#### Treesitter
- **Enabled**: indent, folding, nixvim injections
- Robust syntax highlighting and tree-based navigation

#### Treesitter Extensions
- **Context**: Scope display during scrolling
- **Textobjects**: Enhanced selection operators

#### Conjure (Fennel/Lisp)
- Interactive REPL support for Fennel development

#### Obsidian Integration
- **Vault**: `~/Documents/Notes`
- **Features**: Frontmatter disabled, conceallevel=2, checkbox toggle, search, paste images
- **Keys**: `<leader>o*`

**Complexity Score**: ⭐⭐ (good language support, Obsidian adds specialized integration)

---

## Part 2: Migration to nix_neovim (Lua-Based Architecture)

### Architecture Overview

Current nix_neovim structure:
```
nvim/
├── lua/
│   ├── config/
│   │   ├── init.lua          (entrypoint)
│   │   ├── keymaps.lua       (all keybindings)
│   │   └── options.lua       (editor settings)
│   └── plugins/
│       ├── init.lua          (plugin requires)
│       ├── mini.lua          (mini.nvim ecosystem)
│       ├── lsp.lua           (LSP configuration)
│       ├── sessions.lua      (session management)
│       └── starter.lua       (dashboard/startup)
├── init.lua                  (main entrypoint)
├── plugins.nix               (dependency declarations)
└── flake.nix                 (Nix flake)
```

### Design Principles for Migration

1. **Minimize External Plugins**: Prefer Neovim v0.12+ builtin functionality
2. **Maximize mini.nvim**: Use mini.nvim modules for common tasks
3. **Keep Nix Clean**: Use Nix only for dependency management, not configuration
4. **Preserve Functionality**: Every feature from daily driver must be implemented
5. **Simplify Where Possible**: Consolidate similar features and reduce plugin count

---

## Part 3: Feature Mapping & Migration Strategy

### Feature Tier System

**Tier 1 (Builtin)**: Use Neovim's native capabilities
**Tier 2 (mini.nvim)**: Use mini.nvim ecosystem modules
**Tier 3 (Specialized)**: Use minimal external plugins for unique features
**Tier 4 (Consider Removing)**: Low-value plugins with high maintenance burden

---

### A. EDITOR FUNDAMENTALS → Tier 1 (Builtin)

**Current**: sets.nix (nixvim)
**Target**: `lua/config/options.lua`

✅ **All editor options map directly to `vim.opt` calls**

```lua
-- From sets.nix → options.lua
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
-- ... etc (100% compatible)
```

**Status**: ✅ READY - Zero migration effort needed

---

### B. KEYBINDINGS → Tier 1 (Builtin) + Tier 2 (mini.clue)

**Current**: keymaps.nix (80+ mappings)
**Target**: `lua/config/keymaps.lua` + `lua/plugins/mini.lua`

**Strategy**:
1. Translate all `vim.keymap.set()` calls (Tier 1)
2. Use `mini.clue` for keymap grouping help (Tier 2)

**Migration Status**:
- ✅ Basic mappings (100% compatible with `vim.keymap.set()`)
- ✅ Functional calls (custom Lua functions)
- ⚠️ Which-key groups (convert to mini.clue annotations)

**Example**:
```lua
-- OLD: keymaps.nix
{
  mode = "n";
  key = "<leader>f";
  action = "+find/file";
  options.desc = "Find";
}

-- NEW: keymaps.lua
map("n", "<leader>f", "<nop>", { desc = "Find" })
-- mini.clue will auto-discover subkeys
```

---

### C. LANGUAGE SERVERS → Tier 1 (Builtin) + Tier 3 (nvim-lspconfig)

**Current**: lsp/lsp.nix (clangd, lua_ls, nil_ls, eslint, pyright, ruff-lsp, rust-analyzer)
**Target**: `lua/plugins/lsp.lua`

**Strategy**:
- Neovim 0.11+ has built-in `vim.lsp.config()` API
- nix_neovim already uses this approach ✅
- Minimal plugin dependency (just nvim-lspconfig for server configs)

**Status**: ✅ READY - Already demonstrated in nix_neovim/lua/plugins/lsp.lua

---

### D. CODE FORMATTING → Tier 3 (conform.nvim)

**Current**: conform.nix (7 language formatters)
**Target**: `lua/plugins/conform.lua` (new file)

**Challenge**: No built-in Neovim formatting UI
**Solution**: Keep conform.nvim but simplify configuration

```lua
-- lua/plugins/conform.lua
require("conform").setup({
  formatters_by_ft = {
    python = { "ruff_format" },
    lua = { "stylua" },
    -- ... etc
  },
  format_on_save = { timeout_ms = 500, lsp_format = "fallback" },
})
```

**Status**: ✅ STRAIGHTFORWARD - Simple translation

---

### E. CODE LINTING → Tier 3 (nvim-lint)

**Current**: nvim-lint.nix (6 language linters)
**Target**: `lua/plugins/lint.lua` (new file)

```lua
-- lua/plugins/lint.lua
require("lint").linters_by_ft = {
  python = { "ruff" },
  nix = { "statix" },
  -- ... etc
}
```

**Status**: ✅ STRAIGHTFORWARD - Simple translation

---

### F. COMPLETION → Tier 3 (Mini.completion alternative)

**Current**: cmp.nix + copilot-cmp.nix + luasnip.nix (complex multi-source)
**Target**: Option A or Option B

**Option A: Keep Nvim-CMP (Familiar, well-tested)**
```lua
-- lua/plugins/completion.lua
require("cmp").setup({
  sources = {
    { name = "nvim_lsp" },
    { name = "copilot" },
    { name = "buffer" },
    { name = "path" },
  },
})
```
- **Pros**: Feature parity, Copilot support
- **Cons**: Extra dependency, more configuration

**Option B: Switch to Mini.completion (Simpler, builtin-friendly)**
```lua
-- Already in nix_neovim!
require("mini.completion").setup()
```
- **Pros**: Built on builtin, simpler, fewer dependencies
- **Cons**: Less feature-rich, no Copilot integration

**Recommendation**: **Option A (Keep CMP) for now**
- Your workflow is proven with CMP
- Copilot integration is valuable
- Migration cost > value of simplification
- Revisit if completion becomes pain point

**Status**: ⚠️ MEDIUM EFFORT - Multi-file consolidation

---

### G. FUZZY FINDING → Tier 3 (Mini.pick + optional Telescope)

**Current**: telescope.nix + project.nvim (feature-rich, ~10 pickers)
**Target**: Hybrid approach

**Strategy A: Mini.pick (Simpler)**
```lua
-- lua/plugins/mini.lua
require("mini.pick").setup()
-- Already in nix_neovim, covers most needs
```

**Strategy B: Keep Telescope (Feature parity)**
```lua
-- lua/plugins/telescope.lua
require("telescope").setup({ ... })
```

**Recommendation**: **Gradual Migration**
1. Start with `mini.pick` for basic file/grep/buffer operations
2. Keep `telescope` as optional for advanced features (diagnostics, undo, etc.)
3. Provide both, deprecate Telescope in future version

**Current Status**: ✅ PARTIAL - mini.pick ready, Telescope config needed

---

### H. DEBUGGING → Tier 3 (nvim-dap)

**Current**: dap.nix + nvim-dap-ui (15+ keybindings)
**Target**: `lua/plugins/dap.lua`

**Challenge**: DAP is complex, requires adapter management
**Solution**: 
1. Keep nvim-dap + nvim-dap-ui (no good builtin alternative)
2. Translate configuration from Nix to Lua
3. Re-implement keybindings in keymaps.lua

```lua
-- lua/plugins/dap.lua
local dap = require("dap")
dap.adapters.python = { ... }
dap.configurations.python = { ... }
```

**Status**: ⚠️ MEDIUM EFFORT - Straightforward translation, moderate complexity

---

### I. TESTING → Tier 3 (neotest)

**Current**: neotest.nix (Python, Vitest, Plenary adapters)
**Target**: `lua/plugins/neotest.lua`

**Challenge**: Adapter management
**Solution**: Translate configuration

```lua
-- lua/plugins/neotest.lua
require("neotest").setup({
  adapters = {
    require("neotest-python"),
    require("neotest-vitest"),
  },
})
```

**Status**: ✅ STRAIGHTFORWARD - Simple translation

---

### J. GIT INTEGRATION → Tier 2/3 Hybrid

| Feature | Current | Target | Status |
|---------|---------|--------|--------|
| **Gitsigns** | gitsigns.nix | lua/plugins/gitsigns.lua | ✅ Straightforward |
| **Neogit** | neogit.nix | lua/plugins/neogit.lua | ✅ Straightforward |
| **Diffview** | diffview.nix | lua/plugins/diffview.lua | ✅ Straightforward |
| **Octo** | octo.nix | CONSIDER: Tier 4 | ⚠️ Niche feature |

**Recommendation for Octo**: 
- **Current Usage**: Not critical to daily workflow
- **Action**: Keep but deprioritize, consider removing if maintenance burden
- **Alternative**: Use GitHub CLI or GitHub web UI

---

### K. UI/UX ENHANCEMENTS → Mixed Tier

| Feature | Current | Target | Status |
|---------|---------|--------|--------|
| **Catppuccin** | base16/catppuccin.nix | lua/plugins/colorscheme.lua | ✅ Straightforward |
| **Alpha Dashboard** | alpha.nix | lua/plugins/starter.lua | ✅ Ready (nix_neovim) |
| **Noice** | noice.nix | lua/plugins/noice.lua | ⚠️ Consider Mini |
| **Notify** | nvim-notify.nix | mini.notify | ✅ Use Mini |
| **Dressing** | dressing-nvim.nix | lua/plugins/dressing.lua | ✅ Straightforward |
| **Bufferline** | bufferline.nix | lua/plugins/bufferline.lua | ✅ Straightforward |
| **Indent-blankline** | indent-blankline.nix | lua/plugins/indent-blankline.lua | ✅ Straightforward |
| **Lualine** | lualine.nix | lua/plugins/lualine.lua OR mini.statusline | ⚠️ Consider Mini |

**Recommendations**:
1. **Replace Notify with mini.notify**: Already in nix_neovim, simpler ✅
2. **Consider Noice vs builtin**: Noice adds complexity, evaluate if worth it
3. **Lualine vs mini.statusline**: 
   - Keep Lualine if you heavily customize it
   - Switch to mini.statusline if default is good enough
   - nix_neovim uses mini.statusline (works well)

---

### L. UTILITIES → Mixed Tier

| Feature | Current | Recommendation | Status |
|---------|---------|-----------------|--------|
| **Persistence** (Sessions) | persistence.nix | lua/plugins/sessions.lua | ✅ Ready (nix_neovim) |
| **Toggleterm** | toggleterm.nix | lua/plugins/toggleterm.lua | ✅ Straightforward |
| **Tmux Navigator** | tmux-navigator.nix | lua/plugins/tmux-navigator.lua | ✅ Straightforward |
| **Illuminate** | illuminate.nix | Keep but keep disabled | ⚠️ Disabled in current |
| **Todo Comments** | todo-comments.nix | lua/plugins/todo-comments.lua | ✅ Straightforward |
| **Better-escape** | better-escape.nix | Tier 4 (low value) | ❌ Consider removing |
| **Undotree** | undotree.nix | lua/plugins/undotree.lua | ✅ Straightforward |
| **Vim-be-good** | vim-be-good.nix | Tier 4 (learning only) | ❌ Consider removing |
| **Markdown Preview** | markdown-preview.nix | lua/plugins/markdown-preview.lua | ✅ Straightforward |
| **NVim-colorizer** | nvim-colorizer.nix | lua/plugins/colorizer.lua | ✅ Straightforward |
| **Wilder** | wilder.nix | Tier 4 (command completion overkill) | ❌ Consider removing |
| **Plenary** | plenary.nix | Implicit dependency | ✅ Keep (auto-pulled) |
| **Mini Suite** (ai, basics, comment, diff, pairs, clue) | mini/default.nix | lua/plugins/mini.lua | ✅ Ready |

**Removal Candidates** (Tier 4):
- `better-escape` - Neovim handles escaping fine
- `vim-be-good` - Only useful for practice sessions
- `wilder` - overkill for command completion

---

### M. LANGUAGE-SPECIFIC → Tier 3

| Feature | Current | Target | Status |
|---------|---------|--------|--------|
| **Treesitter** | treesitter.nix | lua/plugins/treesitter.lua | ✅ Straightforward |
| **Treesitter Context** | treesitter-context.nix | lua/plugins/treesitter-context.lua | ✅ Straightforward |
| **Treesitter Textobjects** | treesitter-textobjects.nix | lua/plugins/treesitter-textobjects.lua | ✅ Straightforward |
| **Conjure** (Fennel) | languages/fennel.nix | lua/plugins/conjure.lua | ✅ Straightforward |
| **Obsidian** | obsidian/default.nix | lua/plugins/obsidian.lua | ✅ Straightforward |

---

## Part 4: Recommended Plugin Stack (Final)

### Core Plugins (Must Keep)

1. **nvim-lspconfig** - Language servers
2. **conform.nvim** - Code formatting
3. **nvim-lint** - Code linting
4. **nvim-cmp** + copilot-cmp + luasnip - Completion (current workflow)
5. **gitsigns.nvim** - Git decorations
6. **nvim-treesitter** - Syntax highlighting
7. **mini.nvim** - Core ergonomics + UI polish

### Important Plugins (Keep)

8. **nvim-dap** + nvim-dap-ui - Debugging
9. **neotest** - Testing framework
10. **telescope.nvim** - Advanced picking (optional, use mini.pick for basics)
11. **toggleterm.nvim** - Terminal integration
12. **catppuccin** - Colorscheme
13. **dressing.nvim** - Input/select UI
14. **bufferline.nvim** - Buffer line
15. **persist.nvim** (or mini.sessions) - Session management
16. **neogit.nvim** - Git workflow
17. **diffview.nvim** - Diff viewing

### Optional Plugins (Can Keep or Remove)

18. **lualine.nvim** vs `mini.statusline` - Status line (consider simplifying to mini)
19. **noice.nvim** - Message UI (adds complexity, optional)
20. **octo.nvim** - GitHub integration (niche, consider removing)
21. **undotree.nvim** - Undo visualization
22. **todo-comments.nvim** - Todo highlighting
23. **markdown-preview.nvim** - Markdown preview
24. **nvim-colorizer.lua** - Color preview
25. **conjure** - Fennel REPL
26. **obsidian.nvim** - Note vault

### Removal Candidates (Tier 4)

- ❌ **better-escape** (not needed)
- ❌ **vim-be-good** (practice only)
- ❌ **wilder.nvim** (overkill for command line)
- ❌ **indent-blankline** (mini.indentscope covers this)
- ❌ **lspkind.nvim** (cmp provides icons)

### Final Plugin Count

- **Current**: 50+ plugins across 62 Nix modules
- **Proposed**: ~35-40 plugins in consolidated lua config
- **Reduction**: ~30% fewer plugins, same functionality

---

## Part 5: Implementation Roadmap

### Phase 1: Foundation (Week 1)
- [ ] Copy nix_neovim as base
- [ ] Migrate editor options (sets.nix → options.lua)
- [ ] Migrate keybindings (keymaps.nix → keymaps.lua)
- [ ] Test with basic navigation

### Phase 2: Core Plugins (Week 2)
- [ ] LSP configuration (already done in nix_neovim)
- [ ] Conform + nvim-lint
- [ ] Treesitter + extensions
- [ ] Verify language support works

### Phase 3: Completion & Picking (Week 3)
- [ ] Nvim-CMP + Copilot migration
- [ ] Luasnip snippet setup
- [ ] Telescope or mini.pick configuration
- [ ] Test completion workflows

### Phase 4: Advanced Features (Week 4)
- [ ] DAP configuration
- [ ] Neotest setup
- [ ] Git integrations (gitsigns, neogit, diffview)
- [ ] Test debugging workflows

### Phase 5: Polish (Week 5)
- [ ] UI enhancements (colorscheme, bufferline, lualine)
- [ ] Terminal integration (toggleterm)
- [ ] Session management
- [ ] Special tools (Obsidian, todo-comments, undotree)

### Phase 6: Testing & Documentation (Week 6)
- [ ] Full integration testing
- [ ] Create migration guide
- [ ] Document keybindings in lua
- [ ] Performance profiling vs nixvim

---

## Part 6: Appendix - Simplification Recommendations

### A. UI Consolidation

**Current State**: 5 separate UI plugins (Alpha, Noice, Notify, Dressing, Lualine)
**Recommendation**: Use builtin + mini.nvim where possible

```lua
-- BEFORE (5 plugins, complex configuration)
alpha → noice → notify → dressing → lualine

-- AFTER (simplified)
mini.starter → mini.notify → builtin input → mini.statusline
OR
mini.starter → noice (if you love it) → mini.notify → dressing → lualine
```

**Evaluation Matrix**:
| Feature | Builtin | mini.nvim | External |
|---------|---------|-----------|----------|
| Dashboard | Alpha | mini.starter | ✅ mini.starter |
| Notifications | ❌ | mini.notify | ✅ mini.notify |
| Input/Select | vim.ui.input | ❌ | ✅ dressing.nvim |
| Status Line | ❌ | mini.statusline | lualine ✅ |
| Messages | builtin | ❌ | noice ✅ |

**Recommendation**: Replace Notify with `mini.notify`, evaluate Noice (nice but not essential)

---

### B. Completion Ecosystem Simplification

**Current**: 6 completion sources (LSP, Emoji, Buffer, Copilot, Path, Snippets)
**Options**:

**Option 1: Keep CMP as-is** (recommended for now)
- Pros: Proven workflow, Copilot support
- Cons: Moderate complexity

**Option 2: Simplify to mini.completion**
- Pros: ~70% fewer lines of code
- Cons: No Copilot, less customizable

**Recommendation**: Stick with Option 1, revisit in 6 months

---

### C. Fuzzy Finding Consolidation

**Current**: Telescope (10+ pickers) + project.nvim
**Recommended**: Use mini.pick for 80% of operations, keep Telescope for advanced

```lua
-- Core operations (use mini.pick)
<leader>ff - files
<leader>/ - grep
<leader>fb - buffers

-- Advanced (use telescope if installed)
<leader>st - todos (telescope)
<leader>sd - diagnostics (telescope)
<leader>sc - colorscheme (telescope)
```

---

### D. Debugging Complexity

**Current**: DAP + DAP UI + Python adapter + Java remote (3 files, ~100 lines config)
**Recommendation**: Keep as-is, it's already well-optimized

**Why**: 
- No good builtin alternative
- Once configured, rarely touches
- Justifies complexity through value

---

### E. Git Workflow Consolidation

**Current**: Gitsigns + Neogit + Diffview + Octo (4 plugins, complementary)
**Recommendation**: 

**Essential**:
- ✅ Gitsigns (line-level diffs, staging)
- ✅ Neogit (status/commit interface)
- ✅ Diffview (side-by-side diffs)

**Optional**:
- ⚠️ Octo (GitHub-specific, niche use case)

**Recommendation**: Consider removing Octo if rarely used, use GitHub CLI instead

---

### F. Language-Specific Features

**Current**: 6 language-specific integrations
**Recommendation**: Keep all, they're modular and non-intrusive

---

### G. Recommended Removal Candidates (to reduce maintenance)

| Plugin | Reason | Impact |
|--------|--------|--------|
| better-escape | Neovim handles fine | Low (cosmetic only) |
| vim-be-good | Training wheel only | Low (not needed for daily work) |
| wilder | Overkill for cmd-line | Medium (adds complexity) |
| indent-blankline | mini.indentscope equivalent | Low (visual only, mini is simpler) |
| illuminate | Currently disabled | None (just remove) |
| octo | Niche GitHub feature | Medium (can use CLI) |

**Total Reduction**: Remove 6 plugins, save ~50 lines of config, lose minimal functionality

---

## Part 7: Quick Win - Immediate Actions

### 1. Replace Notify with mini.notify
**Effort**: 10 minutes
**Impact**: Reduces 1 dependency, uses builtin-friendly code

### 2. Remove Disabled Plugins
**Effort**: 5 minutes
**Impact**: Cleaner codebase

```
- illuminate (disabled)
- harpoon (commented out)
- flash (commented out)
```

### 3. Remove Low-Value Tools
**Effort**: 15 minutes
**Impact**: Cleaner nix config, no functional loss

```
- better-escape
- vim-be-good
- wilder
```

### 4. Consolidate LSPSaga Usage
**Effort**: 20 minutes
**Impact**: Understand if builtin LSP is sufficient

Current question: Do you need LSPSaga's advanced features (beacon, breadcrumbs, lightbulb)?
- If **YES**: Keep it, translates fine to lua
- If **NO**: Drop it, use builtin LSP instead

---

## Part 8: Feature Parity Verification Checklist

Use this checklist when migrating each feature:

- [ ] **Options**: All vim.opt calls present and correct
- [ ] **Keybindings**: All mappings registered with vim.keymap.set()
- [ ] **Language Servers**: All servers configured in vim.lsp.config() + vim.lsp.enable()
- [ ] **Formatting**: All formatters registered in conform
- [ ] **Completion**: All sources configured in nvim-cmp
- [ ] **Picking**: Mini.pick covers basic, Telescope available for advanced
- [ ] **Git**: Gitsigns, Neogit, Diffview functional
- [ ] **Debugging**: DAP adapters configured for Python/Rust/etc
- [ ] **Testing**: Neotest adapters functional
- [ ] **UI**: Colorscheme, bufferline, statusline configured
- [ ] **Utilities**: Terminal, sessions, todos working

---

## Part 9: Estimated Effort Summary

| Phase | Task | Effort | Difficulty |
|-------|------|--------|-----------|
| 1 | Copy base, options, keymaps | 1-2h | Low |
| 2 | LSP (mostly done) | 0.5h | Very Low |
| 2 | Conform + Lint | 1h | Low |
| 2 | Treesitter | 0.5h | Low |
| 3 | CMP + Copilot + Snippets | 1-2h | Medium |
| 3 | Picking (mini + telescope) | 1-2h | Medium |
| 4 | DAP | 1-2h | Medium |
| 4 | Neotest | 0.5h | Low |
| 4 | Git tools | 1.5h | Low-Medium |
| 5 | UI Polish | 1-2h | Low-Medium |
| 5 | Utilities | 1h | Low |
| 6 | Testing & Docs | 2-3h | Low |
| **Total** | | **14-20h** | **Medium Average** |

**Timeline**: ~3-4 weeks working part-time, 1 week full-time

---

## Part 10: Final Recommendation

### Summary

Your nixvim config is **well-architected but increasingly complex**. The lua-based nix_neovim approach provides:

✅ **Advantages**:
1. Direct Lua control (no Nix abstraction)
2. Smaller plugin ecosystem (consolidation via mini.nvim)
3. Faster reload cycles (no Nix rebuild)
4. Better maintainability (lua community > nixvim community)
5. Easier to share/fork (standard neovim format)

⚠️ **Trade-offs**:
1. Effort: 15-20 hours migration time
2. Needing Nix knowledge: No (just dependency management)
3. Community size: Smaller (lua-based neovim > nixvim)

### Recommended Path Forward

1. **Use nix_neovim as base** - Already 80% of what you need
2. **Migrate in phases** - Don't do everything at once
3. **Keep nixvim reference** - Compare implementation as you go
4. **Test thoroughly** - Each phase should be fully functional
5. **Document as you go** - Create lua-based keymap reference

### When to Start

**Start when:**
- You have a stable dev period (3-4 weeks)
- You've tested nix_neovim MVP thoroughly
- You're comfortable with lua basics

**Wait if:**
- Currently shipping critical features
- Recent major nixvim config changes
- Learning Lua would significantly slow you down

---

## Appendix A: Plugin Dependency Graph

```
CORE ECOSYSTEM
├── nvim-lspconfig (language servers)
├── conform.nvim (formatting)
├── nvim-lint (linting)
├── nvim-cmp (completion)
│   ├── copilot-cmp
│   └── luasnip
├── mini.nvim (multiple modules)
└── nvim-treesitter (syntax)

PICKING & NAVIGATION
├── telescope.nvim (advanced picking)
│   ├── telescope-fzf-native
│   ├── telescope-ui-select
│   └── telescope-undo
├── mini.pick (basic picking)
└── project.nvim

DEBUGGING & TESTING
├── nvim-dap
│   ├── nvim-dap-ui
│   └── nvim-dap-python
└── neotest

GIT WORKFLOW
├── gitsigns.nvim
├── neogit.nvim
│   └── diffview.nvim
└── octo.nvim

UI/VISUAL
├── catppuccin (colorscheme)
├── bufferline.nvim
├── lualine.nvim OR mini.statusline
├── dressing.nvim
├── noice.nvim
└── indent-blankline.nvim

UTILITIES & INTEGRATIONS
├── persistence.nvim OR mini.sessions
├── toggleterm.nvim
├── tmux-navigator.nvim
├── todo-comments.nvim
├── undotree.vim
├── markdown-preview.nvim
├── nvim-colorizer.lua
├── conjure (fennel)
└── obsidian.nvim

LEARNING/OPTIONAL
├── vim-be-good (optional)
├── illuminate.nvim (currently disabled)
└── lspkind.nvim (superceded by cmp icons)
```

---

## Appendix B: Nix vs Lua Configuration Comparison

| Aspect | Nixvim (Current) | Nix_Neovim (Target) |
|--------|------------------|-------------------|
| **Config Language** | Nix DSL | Lua |
| **Plugin Management** | Nix home-manager | Nix flake |
| **Options Setting** | nixvim.opts | vim.opt |
| **Keybindings** | nixvim.keymaps | vim.keymap.set() |
| **Plugin Config** | Per-plugin .nix files | Per-plugin .lua files |
| **LSP Setup** | nixvim.plugins.lsp | vim.lsp.config() + vim.lsp.enable() |
| **Completion** | nixvim.plugins.cmp | require("cmp").setup() |
| **Learning Curve** | Nix syntax + nixvim semantics | Lua + standard neovim APIs |
| **Community Size** | Smaller | Large (neovim) |
| **Documentation** | Limited (nixvim-specific) | Abundant (neovim) |
| **Reload Time** | Slow (Nix rebuild) | Fast (lua reload) |
| **Portability** | Linux/NixOS only | Cross-platform |
| **Version Sync** | Manual | Auto via lockfile |

---

## Appendix C: Mini.nvim Module Recommendations

| Mini Module | Purpose | Replace |
|-------------|---------|---------|
| `mini.hues` | Colorscheme generation | (keep catppuccin if prefer, else use this) |
| `mini.files` | File explorer | Could replace Telescope file picker |
| `mini.ai` | Smart text objects | Native text objects supplement |
| `mini.comment` | Line comments | Native alternative: keymaps |
| `mini.surround` | Surround text | vim-surround alternative |
| `mini.pairs` | Auto pair handling | nvim-autopairs alternative |
| `mini.statusline` | Status line | Lualine alternative |
| `mini.tabline` | Tab line | Builtin alternative |
| `mini.indentscope` | Indent guide | indent-blankline alternative ✅ |
| `mini.cursorword` | Highlight word | illuminate alternative |
| `mini.pick` | Fuzzy picker | Telescope alternative |
| `mini.completion` | Completion | nvim-cmp alternative |
| `mini.notify` | Notifications | nvim-notify alternative ✅ |
| `mini.sessions` | Session management | persistence.nvim alternative |
| `mini.clue` | Keymap help | which-key alternative |
| `mini.jump` | Smart jump | Native support |
| `mini.move` | Move lines/blocks | Native alternative |
| `mini.animate` | Animations | Optional polish |
| `mini.trailspace` | Trailing spaces | Native linting |

**✅ = Recommended replacements** (low-value to keep external alternative)

---

## Appendix D: Alternative Approaches Not Recommended

### Why NOT These?

1. **Jump to nvim-lazy (plugin manager)**
   - ❌ Nix handles dependencies better
   - ❌ Incompatible with NixOS philosophy
   - ✅ OK if leaving NixOS

2. **Use AstroNvim/LazyVim/NVChad (pre-built configs)**
   - ❌ Too opinionated
   - ❌ Hard to customize
   - ❌ Defeats purpose of daily driver

3. **Keep using Nixvim indefinitely**
   - ❌ Community stagnating
   - ❌ Nix complexity not needed for neovim
   - ❌ Slower to update plugins

4. **Go back to pure Nix + init.vim**
   - ❌ Ancient Neovim syntax
   - ❌ Worse plugin ecosystem
   - ❌ Harder to debug

---

## Appendix E: Post-Migration Cleanup

After completing migration to lua:

1. **Archive current nixvim**
   ```bash
   cp -r config/ config.nixvim-backup/
   ```

2. **Update flake.nix**
   - Remove all nixvim references
   - Keep only nix_neovim module
   - Update home-manager integration

3. **Remove unused nix files**
   - Delete 62 individual plugin .nix files
   - Keep only flake.nix, hm-module.nix, plugins.nix

4. **Create migration guide**
   - Document what moved where
   - Note any deprecations
   - Provide troubleshooting steps

5. **Performance benchmark**
   - Measure Nix rebuild time savings
   - Compare Neovim startup time
   - Profile plugin load time

---

## Appendix F: Knowledge Base & Resources

### Key Documentation
- [Neovim LSP](https://neovim.io/doc/user/lsp.html)
- [vim.keymap.set() API](https://neovim.io/doc/user/api_global.html#nvim_set_keymap())
- [mini.nvim comprehensive docs](https://github.com/echasnovski/mini.nvim)
- [Conform.nvim](https://github.com/stevearc/conform.nvim)
- [Nvim-CMP](https://github.com/hrsh7th/nvim-cmp)

### Helpful Commands

```lua
-- Inspect loaded plugins
:lua print(vim.inspect(vim.g.loaded_packages))

-- Check registered keymaps
:map (all), :nmap (normal), :imap (insert), etc.

-- LSP debugging
:LspInfo (server info)
:LspLog (debug log)

-- Performance profiling
:lua require('vim.profiler').start('profile.log'); vim.cmd('e your_file.lua'); require('vim.profiler').stop()
```

---

## Final Notes

This migration is **technically straightforward** but **requires dedication to detail**. The payoff is a more maintainable, faster-reloading, better-documented daily driver configuration.

**Key success factors**:
1. ✅ Use nix_neovim as a solid foundation
2. ✅ Test each phase before moving to next
3. ✅ Keep old config accessible for reference
4. ✅ Document as you go
5. ✅ Don't try to "improve" while migrating (one thing at a time)

**You've got this!** The hard part (lua-based neovim config) is already proven in nix_neovim. You're just translating known patterns.

---

**Document Generated**: 2026-03-01
**nix_neovim Version**: MVP/POC phase
**Daily Driver Version**: Feature-complete with 50+ plugins
