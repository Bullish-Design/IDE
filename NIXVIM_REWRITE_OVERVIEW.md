# Nixvim Rewrite: Honest Assessment & Streamlined Config Design

## Why This Document Exists

Your current nixvim daily driver has ~50 plugins spread across 62 Nix modules. On the
surface it looks well-organized. Underneath, it is a configuration that has grown by
accretion -- plugins were added to solve problems, then more plugins were added on top
when the first ones didn't quite work right, and nobody went back to remove the layers
underneath. The result is a config where the same task can be done 3-4 different ways
through different plugins, plugins silently fight each other for control of the same
Neovim subsystems, and the mental model required to use the editor is far larger than it
needs to be.

This document does three things:

1. **Honestly catalogues what's wrong** with the current config
2. **Proposes a streamlined replacement** built on a small, coherent mental model
3. **Explains every decision** so you understand the "why", not just the "what"

---

## Part 1: Critical Analysis of the Current Config

### The Core Problem: Accretion Without Pruning

The config was built by adding plugins to solve problems, without removing what they
replaced. This created layers of redundancy:

```
Layer 1: Native Neovim (LSP, diagnostics, vim.ui)
Layer 2: Foundational plugins (Telescope, CMP, Treesitter)
Layer 3: Enhancement plugins (LSPSaga, Noice, Dressing)
Layer 4: Mini.nvim modules (pick, diff, completion, files)
Layer 5: Convenience plugins (wilder, better-escape, illuminate)
```

Layers 3-5 often duplicate or conflict with Layers 1-2. Here are the specific problems.

---

### 1.1 The Notification Disaster (3 plugins fighting for vim.notify)

**Players**: nvim-notify, fidget.nvim, noice.nvim

All three attempt to own the notification pipeline:

- **nvim-notify**: Overrides `vim.notify` globally in its extraConfigLua
- **fidget.nvim**: Sets `overrideVimNotify = true`, also claiming `vim.notify`. Then
  *delegates back* to nvim-notify for certain message types
- **noice.nvim**: Takes over the command-line message display layer (even with
  `notify.enabled = false`)

The config author literally left a comment in default.nix: *"Different notification
manager. Why both?"* -- and never answered the question.

**What actually happens**: Load order determines who wins. You have a Rube Goldberg
notification chain where fidget intercepts, sometimes delegates to nvim-notify, while
noice owns the message display. Three plugins doing one job.

**What you need**: One notification system. Period.

---

### 1.2 The vim.ui.select Collision (3 plugins overriding the same function)

**Players**: dressing.nvim, telescope ui-select extension, mini.pick

- **dressing.nvim**: Overrides `vim.ui.select` with backend priority
  `["telescope", "fzf_lua", "fzf", "builtin", "nui"]`
- **telescope ui-select**: Extension that also claims `vim.ui.select`
- **mini.pick**: Has `vim.ui.select = require('mini.pick').ui_select` in
  `extraConfigLuaPost` (though currently commented out in the import)

Right now dressing and telescope ui-select are both active and fighting over who handles
code actions and other select prompts. The winner depends on load order.

**What you need**: One `vim.ui.select` handler.

---

### 1.3 Duplicate Gutter Signs (gitsigns + mini.diff doing the same thing)

**Players**: gitsigns.nvim, mini.diff

Both plugins place diff signs in the sign column:
- **gitsigns**: Standard git signs (+, ~, -)
- **mini.diff**: Configured with `view.style = "sign"` using (+, ~, _)

Two plugins racing to fill the same gutter for the same purpose. You see doubled or
flickering signs.

**What you need**: One gutter sign provider for git status.

---

### 1.4 Double Linting (LSP servers duplicating standalone linters)

**Players**: eslint LSP + eslint_d in nvim-lint, ruff-lsp + ruff in nvim-lint

- **eslint** is enabled as an LSP server AND eslint_d runs as a standalone linter via
  nvim-lint. Every eslint violation appears twice in JavaScript/TypeScript files.
- **ruff-lsp** provides linting AND formatting for Python. nvim-lint *also* runs ruff
  as a standalone linter. conform.nvim *also* runs ruff_format. Triple coverage on the
  same tool for the same language.

**What you need**: For each language, one linting path and one formatting path. Not both
LSP and standalone.

---

### 1.5 Six Ways to View Diagnostics (3 plugins, 6 keybindings)

**Players**: trouble.nvim, lspsaga, telescope

A user wanting to see diagnostics must choose between:

| Keybind | Plugin | View Type |
|---------|--------|-----------|
| `<leader>cd` | LSPSaga | Floating line diagnostic |
| `<leader>xx` | Trouble | Panel (document) |
| `<leader>xX` | Trouble | Panel (workspace) |
| `<leader>sd` | Telescope | Fuzzy list (document) |
| `<leader>sD` | Telescope | Fuzzy list (workspace) |
| `[d` / `]d` | LSPSaga | Jump next/prev (and reversed -- see bugs) |

This is not "power through choice." It is cognitive overhead. A developer should not
need to think about which of three UI paradigms they want for looking at the same data.

**What you need**: One primary diagnostic workflow. Jump between them with `[d`/`]d`,
view them all with one keybind.

---

### 1.6 Three Ways to Find a File

**Players**: telescope (find_files AND git_files), mini.files, project.nvim, alpha dashboard

| Keybind | Plugin | What it does |
|---------|--------|-------------|
| `<leader><space>` | Telescope | find_files |
| `<leader>ff` | Telescope | find_files (same as above) |
| `<C-p>` | Telescope | git_files |
| `<leader>e` | mini.files | File explorer |
| `<leader>fp` | Telescope + project.nvim | Project switch |
| Alpha `f` key | Telescope | find_files again |

`<leader><space>` and `<leader>ff` are *literally the same action* with two keybinds.
`<C-p>` is almost the same as `<leader>ff` but limited to git-tracked files. The user
has to decide: "do I want project files, git files, or browse a tree?" for what is
conceptually one task: "open a file."

**What you need**: One fuzzy finder. One file browser. Clear when to use which.

---

### 1.7 Three Ways to See Diffs

**Players**: gitsigns, diffview.nvim, mini.diff

- `<leader>ghd` -- gitsigns diffthis (inline)
- `:DiffviewOpen` -- diffview (full tab, no keybind configured)
- mini.diff -- always-on gutter signs (duplicating gitsigns)

**What you need**: Gitsigns for inline hunks. Drop mini.diff (it duplicates gitsigns).
Diffview if you need full-file comparison, but wire it to a keybind.

---

### 1.8 The LSPSaga Layer Problem

LSPSaga is an entire parallel LSP UI that shadows native Neovim LSP features. Your
lsp.nix configures custom borders for `vim.lsp.handlers["textDocument/hover"]` -- but
LSPSaga's `K` mapping intercepts hover before the native handler ever fires. That border
config is dead code.

The native LSP keymaps in lsp.nix are entirely commented out because LSPSaga replaced
them. LSPSaga adds:
- Custom hover (K)
- Custom definition finder (gd)
- Custom references (gr)
- Custom rename (leader cr)
- Custom code actions (leader ca)
- Custom diagnostics (leader cd)
- Beacon effects
- Breadcrumbs in winbar
- Lightbulb virtual text

**The question**: Neovim 0.11+ now has native `vim.lsp.buf.hover()` with configurable
borders, `vim.diagnostic.jump()`, improved code action UI, and inlay hints. Most of what
LSPSaga provides is now built into Neovim. The beacon and breadcrumbs are nice polish,
but they come at the cost of an entire plugin that overrides your entire LSP interaction
model.

**What you need**: Decide if LSPSaga's chrome is worth owning a separate LSP
interaction layer. For a streamlined config, native LSP + a few keybindings replaces
90% of what LSPSaga does.

---

### 1.9 The Command-Line Triple Layer

**Players**: wilder.nvim, noice.nvim, cmp-cmdline

- **wilder**: Takes over `:`, `/`, `?` modes with fuzzy matching
- **noice**: Provides its own popupmenu replacement via NUI
- **cmp-cmdline**: Disabled in Nix (`enable = false`) but the Lua code in cmp.nix still
  calls `cmp.setup.cmdline()` for both `:` and `/`/`?` modes

Three plugins attempting to enhance the same command-line. The cmp-cmdline setup is
ghost code -- the plugin isn't installed, so the Lua silently fails.

**What you need**: Native command-line is fine. Or wilder. Not three layers.

---

### 1.10 Dead Weight

These are either disabled, never activated, or provide near-zero value:

| Plugin | Status | Issue |
|--------|--------|-------|
| **illuminate** | `enable = false` | Imported but disabled |
| **treesitter-textobjects** | `enable = false` | Imported but disabled |
| **neotest** | Uses `mkEnableOption` | No `enable = true` anywhere -- never activates |
| **cmp-cmdline** | `enable = false` + Lua calls it | Ghost code |
| **vim-be-good** | Active | A practice game in an IDE config |
| **better-escape** | Active | Neovim handles escape fine |
| **nui-components** | Extra plugin | Nothing references it |
| **lsp-format** | `enable = false` | Declared, disabled |
| **3 colorschemes** | All imported | Only one can be active |
| **kind_icons in cmp** | Lua table | Duplicates lspkind.nvim |

---

### 1.11 Keybinding Bugs

**`[d`/`]d` are backwards**: LSPSaga maps `[d` to `diagnostic_jump_next` and `]d` to
`diagnostic_jump_prev`. Standard vim convention: `[` = previous, `]` = next. These are
swapped.

**`<leader><Tab><Space>d` for buffer delete**: Four sequential keypresses to close a
buffer. This is ergonomically hostile.

**`<Tab>` is overloaded**: In normal mode it cycles buffers (bufferline). In insert mode
it confirms completion (cmp). In visual mode it stores selection (luasnip). Tab is doing
three unrelated things.

---

## Part 2: The Mental Model (What the New Config Should Feel Like)

Before listing plugins, here is the mental model a developer should carry when using
this editor. If you can't hold it in your head, the config is too complex.

### The Developer's Mental Model

```
I edit code.
  - Neovim handles: syntax (treesitter), editing (motions, text objects)
  - I extend with: mini.ai (smarter text objects), mini.surround, mini.pairs

I navigate.
  - <leader>ff : find a file by name (fuzzy)
  - <leader>fg : find text in files (grep)
  - <leader>fb : switch between open buffers
  - <leader>e  : browse the file tree
  - That's it. Four operations for all navigation.

I read and write code with language intelligence.
  - Neovim's built-in LSP handles: hover, go-to-definition, references,
    rename, code actions, diagnostics
  - conform.nvim formats on save
  - [d / ]d jumps between diagnostics
  - K shows documentation. gd goes to definition. gr shows references.
  - No extra plugins needed. It's all native.

I use git.
  - Gitsigns shows what changed in the gutter and lets me stage/reset hunks
  - <leader>gg opens Neogit for commits/branches/push/pull
  - That's the whole git workflow.

I debug and test when needed.
  - DAP keybindings under <leader>d (these are complex by nature -- that's fine)
  - Neotest keybindings under <leader>t

I manage my session.
  - Sessions auto-save and auto-restore
  - <leader>qq quits

I see what I need.
  - One colorscheme (not three)
  - One statusline
  - One notification system
  - Indent guides in the gutter
```

That's it. No "which of three diagnostic viewers do I use?" No "is this the fuzzy
finder or the other fuzzy finder?" Every task has exactly one answer.

---

## Part 3: The Streamlined Config Design

### Architecture

```
nvim/
├── lua/
│   ├── config/
│   │   ├── init.lua          -- loads options, keymaps, autocmds
│   │   ├── options.lua       -- vim.opt settings (pure builtin)
│   │   ├── keymaps.lua       -- all keybindings (pure builtin)
│   │   └── autocmds.lua      -- autocommands
│   └── plugins/
│       ├── init.lua          -- loads all plugin configs
│       ├── mini.lua          -- mini.nvim: the core framework
│       ├── lsp.lua           -- native LSP setup (vim.lsp.config)
│       ├── format.lua        -- conform.nvim
│       ├── lint.lua          -- nvim-lint
│       ├── treesitter.lua    -- treesitter + context
│       ├── git.lua           -- gitsigns + neogit
│       ├── dap.lua           -- debugging (when needed)
│       ├── test.lua          -- neotest (when needed)
│       └── tools.lua         -- obsidian, markdown-preview, etc.
├── init.lua                  -- entrypoint
└── plugins.nix               -- Nix dependency declarations
```

**10 plugin config files, not 62 Nix modules.** Each file has a clear, singular purpose.

---

### Design Principles

1. **One answer per question.** "How do I find a file?" has exactly one answer. Not three.

2. **Three layers, not five.**
   - Layer 1: Neovim builtins (LSP, diagnostics, treesitter, vim.ui)
   - Layer 2: mini.nvim (fills gaps in builtins with one consistent framework)
   - Layer 3: Specialized plugins (only when mini + builtin can't do the job)

3. **If Neovim 0.11+ added it, the plugin goes away.**
   Neovim now has: native LSP config API, `vim.diagnostic` with virtual text and
   floating windows, `vim.lsp.buf.code_action()`, inlay hints, `vim.snippet`,
   configurable borders on all floating windows. LSPSaga, trouble, fidget, and others
   are no longer necessary for their core features.

4. **mini.nvim is the plugin framework, not a supplement.**
   Instead of 15 separate plugins for separate concerns, mini.nvim provides a unified
   framework: same author, same API patterns, same configuration style. This radically
   reduces cognitive load. When you need something, you ask: "does mini have a module
   for this?" Usually yes.

5. **No dead code. No disabled plugins. No phantom configs.**
   If it's not active, it's not in the config.

---

### The Plugin Stack (Explanation and Reasoning)

#### Tier 1: Neovim Builtins (0 plugins)

These features require zero plugins in Neovim 0.11+:

| Feature | Builtin API | Replaces |
|---------|------------|----------|
| LSP hover | `vim.lsp.buf.hover()` | LSPSaga hover |
| Go to definition | `vim.lsp.buf.definition()` | LSPSaga finder |
| References | `vim.lsp.buf.references()` | LSPSaga finder |
| Rename | `vim.lsp.buf.rename()` | LSPSaga rename |
| Code actions | `vim.lsp.buf.code_action()` | LSPSaga code action |
| Diagnostics | `vim.diagnostic.open_float()` | LSPSaga / Trouble |
| Diagnostic jump | `vim.diagnostic.jump()` | LSPSaga diagnostic_jump |
| Inlay hints | `vim.lsp.inlay_hint.enable()` | LSPSaga |
| Snippet expansion | `vim.snippet` | LuaSnip (partially) |
| LSP server config | `vim.lsp.config()` + `vim.lsp.enable()` | nvim-lspconfig |
| Input/select UI | `vim.ui.input()` / `vim.ui.select()` | dressing.nvim |
| Comment toggle | `gc` operator (native since 0.10) | mini.comment |

**Why this matters**: Every plugin you don't load is a plugin you don't configure,
don't debug, don't update, and don't need to hold in your head.

Note on `vim.ui.select`: The builtin is basic. mini.pick can enhance it if desired,
but start with native and only add if you actually miss the polish.

Note on `vim.snippet`: Neovim 0.11 has a native snippet engine. If you rely heavily on
friendly-snippets and LuaSnip's advanced features, keep LuaSnip. But try native first.

Note on comments: `gc`/`gcc` is built into Neovim since 0.10. mini.comment is no longer
needed unless you want specific customization.

---

#### Tier 2: mini.nvim (1 plugin, many modules)

This is the key insight: mini.nvim is *one* plugin that provides ~40 modules. You load
only what you need. Same author, same patterns, same docs site. Your brain has one
framework to understand, not 15 separate plugin APIs.

| Module | Purpose | Replaces | Why |
|--------|---------|----------|-----|
| `mini.ai` | Smart text objects (around/inside) | treesitter-textobjects | Simpler API, works without treesitter queries |
| `mini.surround` | Add/delete/change surroundings | (none active) | Essential editing enhancement |
| `mini.pairs` | Auto-close brackets | (none active) | Simple, no config needed |
| `mini.pick` | Fuzzy finder (files, grep, buffers) | Telescope + 3 extensions + project.nvim | One picker for everything. No extensions to manage |
| `mini.files` | File explorer | (already used) | Simple tree browser |
| `mini.notify` | Notifications | nvim-notify + fidget + noice notifications | One notification system. Done. |
| `mini.statusline` | Status line | lualine | Zero-config, looks good |
| `mini.tabline` | Buffer/tab line | bufferline.nvim | Zero-config, shows open buffers |
| `mini.indentscope` | Indent guides | indent-blankline | Animated scope line, lighter |
| `mini.cursorword` | Highlight word under cursor | illuminate (was disabled) | Simple, no config |
| `mini.sessions` | Session save/restore | persistence.nvim | Already proven in nix_neovim |
| `mini.starter` | Dashboard | alpha.nvim | Already proven in nix_neovim |
| `mini.clue` | Keymap hints | (which-key style) | Shows available keys after leader press |
| `mini.diff` | Git gutter signs | gitsigns (gutter only) | Wait -- see reasoning below |
| `mini.move` | Move lines/selections | Custom J/K visual maps | Cleaner implementation |
| `mini.trailspace` | Trailing whitespace | (listchars partial) | Highlight + trim |

**On mini.diff vs gitsigns**: This is a genuine choice. mini.diff provides gutter
signs. gitsigns provides gutter signs PLUS hunk staging, hunk preview, line blame, and
buffer diff. Since you actively use hunk staging (`<leader>ghs`) and blame
(`<leader>ghb`), **keep gitsigns and drop mini.diff**. Gitsigns does everything
mini.diff does plus more, and they conflict in the gutter.

**On mini.pick vs Telescope**: Telescope is powerful but brings 3 extensions, plenary
dependency, and a large API surface. mini.pick does files, grep, buffers, and can hook
into `vim.ui.select` for code actions. That covers 95% of real usage. The 5% you lose
(undo browser, colorscheme previewer) is not worth the complexity.

**On mini.completion vs nvim-cmp**: This is the hardest call. nvim-cmp has a rich
source ecosystem (LSP, buffer, path, Copilot, snippets). mini.completion is simpler but
can't do multi-source or Copilot. **Recommendation**: Start with mini.completion. If you
miss Copilot integration, add blink.cmp (a newer, simpler alternative to nvim-cmp that
supports Copilot). Do not bring back the full cmp + copilot-cmp + luasnip + lspkind
+ cmp-cmdline stack.

---

#### Tier 3: Specialized Plugins (Minimal, justified)

These plugins exist because neither builtins nor mini.nvim can replace them:

| Plugin | Purpose | Why it can't be replaced |
|--------|---------|------------------------|
| `nvim-lspconfig` | LSP server configurations | Convenience for server-specific settings. Neovim 0.11+ can work without it via `vim.lsp.config()`, but lspconfig provides sensible defaults and cmd resolution. Include it as a light dependency. |
| `conform.nvim` | Code formatting | Neovim has no built-in multi-formatter orchestration. `vim.lsp.buf.format()` works for single-LSP formatting but can't chain formatters or handle the "prettierd then eslint --fix" pattern. conform is small and well-designed. |
| `nvim-lint` | Linting beyond LSP | Some linters don't have LSP servers. nvim-lint fills that gap. **But**: eliminate double-linting. If a language has an LSP that lints (eslint, ruff-lsp), don't also run the standalone linter. |
| `nvim-treesitter` | Syntax highlighting + parsing | Treesitter is builtin, but the nvim-treesitter plugin manages grammar installation and provides the `ensure_installed` API. Still needed. |
| `treesitter-context` | Sticky scope header | Shows which function/class you're in when scrolled deep. Genuine quality-of-life with no builtin equivalent. Small, focused plugin. |
| `gitsigns.nvim` | Git hunk operations | mini.diff can't stage hunks, show blame, or preview hunks. gitsigns can. This is the one git-in-editor plugin you actually need for day-to-day work. |
| `neogit` | Git porcelain (commit/push/pull) | No builtin or mini equivalent for a Magit-style git interface. Neogit is the best option if you want to stay in the editor for git operations. Diffview integrates with it. |
| `diffview.nvim` | Full-file diff comparison | For reviewing PRs or complex merges. Keep as a neogit companion. |
| `nvim-dap` + `nvim-dap-ui` | Debugging | No builtin debugger. DAP is the standard. Only load this when you need it. |
| `neotest` | Test runner | No builtin test framework integration. Neotest is the standard. Only load when you need it. |
| `catppuccin` | Colorscheme | Personal preference. One colorscheme, not three. Alternatively, use `mini.hues` for zero-dependency theming (already demonstrated in nix_neovim). |

**Total external plugins: 11** (plus adapters for DAP/neotest per language)

Compare to current: **50+**

---

### What Gets Cut (and Why)

| Cut | Reason |
|-----|--------|
| **LSPSaga** | Neovim 0.11+ native LSP provides hover, definition, references, rename, code actions, diagnostic jump with configurable UI. LSPSaga is an entire parallel interface for what's now builtin. The beacon effect and breadcrumbs are nice but not worth the cognitive overhead of a plugin that shadows every native LSP keybind. |
| **Trouble.nvim** | `vim.diagnostic.setloclist()` or `vim.diagnostic.setqflist()` puts diagnostics in the quickfix list. Mini.pick can fuzzy-search diagnostics. Trouble is a third diagnostic UI on top of two others. |
| **Fidget.nvim** | Was used for LSP progress indicators. Neovim 0.10+ has `LspProgress` events. A 5-line autocmd can show progress in the statusline or via mini.notify. Not worth a plugin. |
| **Noice.nvim** | Replaces the native command line, message display, and popupmenu with a complex UI layer. Requires nui.nvim as a dependency. The builtin command line works fine. If you want prettier messages, mini.notify handles notifications. Drop the entire noice + nui stack. |
| **Dressing.nvim** | Overrides `vim.ui.input` and `vim.ui.select`. Neovim's builtin input is fine. mini.pick can enhance `vim.ui.select` if desired. Not worth a separate plugin. |
| **Bufferline.nvim** | mini.tabline does the same thing with zero config. Or just use `:ls` and `:b`. |
| **Lualine.nvim** | mini.statusline does the same thing with zero config. |
| **Alpha.nvim** | mini.starter does the same thing (already proven in nix_neovim). |
| **nvim-notify** | mini.notify replaces it. |
| **Indent-blankline** | mini.indentscope replaces it with a simpler, animated scope indicator. |
| **Telescope** (+ fzf-native, ui-select, undo extensions) | mini.pick replaces the core functionality. You lose some niche pickers (undo browser, colorscheme preview) but gain a radically simpler setup. One picker framework instead of Telescope + 3 extensions + plenary. |
| **project.nvim** | Mini.pick can search from project root. `vim.fn.getcwd()` + git root detection in a 3-line function handles project detection. |
| **Wilder.nvim** | Native command-line completion is fine. This was fighting with noice and cmp-cmdline anyway. |
| **Better-escape** | Neovim handles escape natively. This plugin solves a non-problem. |
| **Vim-be-good** | A practice game. Not an IDE feature. |
| **Illuminate** | Was already disabled. mini.cursorword replaces it. |
| **Plenary** | No longer needed (was a Telescope dependency). |
| **nui.nvim + nui-components** | No longer needed (were noice dependencies). |
| **lspkind.nvim** | Was only adding icons to cmp. If using mini.completion, not needed. |
| **Copilot-cmp + copilot-lua** | The two-plugin chain just to add one cmp source. If switching away from cmp, this chain dissolves. Consider standalone Copilot.vim if you want AI completion, or wait for mini.completion to potentially support it. |
| **LuaSnip + friendly-snippets** | Try Neovim's native `vim.snippet` first. If it's insufficient, bring back LuaSnip as a targeted addition. |
| **persistence.nvim** | mini.sessions replaces it. |
| **toggleterm.nvim** | Neovim has a builtin terminal (`:terminal`). A few keymaps can toggle a terminal buffer. 10 lines of Lua replaces an entire plugin. |
| **nvim-colorizer** | Nice but niche. If you actively use it, keep it. Otherwise cut. |
| **markdown-preview.nvim** | Keep if you write markdown. It's small and focused. |
| **Octo.nvim** | GitHub integration in Neovim. Niche. Use `gh` CLI instead. |
| **base16 + rose-pine** | Loading 3 colorschemes when only one is active. Pick one. |
| **mini.diff** | Conflicts with gitsigns. Gitsigns does everything mini.diff does plus hunk operations. Remove mini.diff. |

---

### The Final Plugin List

```
FRAMEWORK (1 plugin, ~15 modules loaded)
  mini.nvim
    ├── mini.ai           -- text objects
    ├── mini.surround     -- surround operations
    ├── mini.pairs        -- auto-close brackets
    ├── mini.pick         -- fuzzy finder (files, grep, buffers, ui.select)
    ├── mini.files        -- file explorer
    ├── mini.notify       -- notifications
    ├── mini.statusline   -- status line
    ├── mini.tabline      -- buffer/tab line
    ├── mini.indentscope  -- indent guides
    ├── mini.cursorword   -- highlight word under cursor
    ├── mini.sessions     -- session management
    ├── mini.starter      -- dashboard
    ├── mini.clue         -- keymap hints
    ├── mini.move         -- move lines/blocks
    └── mini.trailspace   -- trailing whitespace

LANGUAGE INTELLIGENCE (3 plugins)
  nvim-lspconfig        -- LSP server configs
  conform.nvim          -- formatting
  nvim-treesitter       -- syntax + treesitter-context

GIT (3 plugins)
  gitsigns.nvim         -- hunks, blame, staging
  neogit                -- git porcelain
  diffview.nvim         -- diff viewer

DEBUGGING & TESTING (loaded on demand, 2+adapters)
  nvim-dap + ui         -- debugging
  neotest + adapters    -- testing

OPTIONAL (0-2 plugins based on personal need)
  catppuccin            -- colorscheme (or use mini.hues)
  obsidian.nvim         -- if you use Obsidian
  markdown-preview      -- if you write markdown

TOTAL: ~12 external plugins (vs 50+ current)
```

---

### Keybinding Design (The Complete Map)

The entire keymap should fit on one screen. If it doesn't, it's too complex.

#### Core Editing (no leader, muscle memory)

| Key | Action | Source |
|-----|--------|--------|
| `K` | Hover documentation | builtin LSP |
| `gd` | Go to definition | builtin LSP |
| `gr` | References | builtin LSP |
| `gD` | Declaration | builtin LSP |
| `gi` | Implementation | builtin LSP |
| `[d` / `]d` | Previous / next diagnostic | builtin diagnostic |
| `[h` / `]h` | Previous / next git hunk | gitsigns |
| `gcc` / `gc{motion}` | Toggle comment | builtin (Neovim 0.10+) |
| `sa` / `sd` / `sr` | Surround add/delete/replace | mini.surround |
| `C-d` / `C-u` | Half-page with centering | keymaps.lua |
| `J` / `K` (visual) | Move selection up/down | mini.move |
| `<` / `>` (visual) | Indent, stay in visual | keymaps.lua |
| `C-s` | Save | keymaps.lua |

#### Leader Key Groups (Space as leader)

```
<leader>f  Find
  ff  Find files
  fg  Live grep
  fb  Buffers
  fr  Recent files

<leader>c  Code (LSP)
  ca  Code action
  cr  Rename
  cf  Format
  cd  Line diagnostic (float)

<leader>g  Git
  gs  Stage hunk
  gr  Reset hunk
  gp  Preview hunk
  gb  Blame line
  gg  Neogit (full git UI)
  gd  Diff view

<leader>d  Debug
  db  Toggle breakpoint
  dc  Continue
  di  Step into
  do  Step out
  dO  Step over
  dt  Terminate
  du  Toggle DAP UI

<leader>t  Test
  tt  Run file
  tr  Run nearest
  ts  Toggle summary
  to  Show output

<leader>u  UI toggles
  ul  Toggle line numbers
  ur  Toggle relative numbers
  uw  Toggle wrap
  uh  Toggle inlay hints
  uf  Toggle format-on-save

<leader>q  Session/Quit
  qq  Quit all
  qs  Save session
  qr  Restore session

<leader>e  File explorer (mini.files)
<leader>h  Clear search highlight
<leader>x  Diagnostics to quickfix list
```

**Total: ~40 keybindings.** Down from 80+. Every binding has exactly one purpose.
No duplicates. No ambiguity about "which tool handles this."

---

### Linting & Formatting: Clean Ownership

The rule is simple: **one tool per language per concern**. No double-linting.

| Language | Linter | Formatter | Notes |
|----------|--------|-----------|-------|
| Python | pyright (LSP, types) | ruff (conform) | Drop ruff-lsp entirely. Pyright handles type checking. Conform runs ruff for formatting. nvim-lint runs ruff for linting. No double-linting because pyright and ruff check different things. |
| Lua | lua_ls (LSP) | stylua (conform) | lua_ls provides diagnostics. stylua formats. |
| Nix | nil_ls (LSP) | alejandra (conform) | statix via nvim-lint for extra Nix linting if desired. |
| JS/TS | eslint (LSP) | prettierd (conform) | Drop eslint_d from nvim-lint. eslint LSP handles linting. Prettier handles formatting. No overlap. |
| Rust | rust-analyzer (LSP) | rustfmt (conform) | rust-analyzer does everything. rustfmt for formatting. |
| C/C++ | clangd (LSP) | clangd (LSP format) | clangd handles both. |

**Key change**: ruff-lsp is removed. It was providing linting (duplicated by nvim-lint's
ruff) AND formatting (duplicated by conform's ruff_format). Instead: nvim-lint runs ruff
for linting, conform runs ruff for formatting, pyright handles type checking. Three
tools, zero overlap. Similarly, eslint_d is removed from nvim-lint because eslint LSP
provides the same diagnostics.

---

### Terminal Strategy

Instead of toggleterm.nvim, use 10 lines of Lua:

```lua
-- Toggle a persistent terminal buffer
local term_buf = nil
vim.keymap.set("n", "<A-i>", function()
  if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
    local wins = vim.fn.win_findbuf(term_buf)
    if #wins > 0 then
      vim.api.nvim_win_close(wins[1], true)
    else
      vim.cmd("botright split | buffer " .. term_buf)
      vim.cmd("resize 15")
    end
  else
    vim.cmd("botright split | terminal")
    term_buf = vim.api.nvim_get_current_buf()
    vim.cmd("resize 15")
  end
end, { desc = "Toggle terminal" })
```

This gives you the same Alt-i toggle behavior without a plugin. The terminal is
persistent across toggles. It opens at the bottom. 15 lines high. Done.

---

### Notification Strategy

One system: mini.notify.

```lua
require("mini.notify").setup()
vim.notify = require("mini.notify").make_notify()
```

Two lines. Replaces nvim-notify + fidget + noice's notification layer. For LSP progress,
add a small autocmd:

```lua
vim.api.nvim_create_autocmd("LspProgress", {
  callback = function(ev)
    local data = ev.data
    if data and data.params then
      local val = data.params.value
      if val and val.message then
        vim.notify(val.message, vim.log.levels.INFO)
      end
    end
  end,
})
```

This replaces fidget.nvim entirely with ~10 lines of code using Neovim's native
`LspProgress` event.

---

## Part 4: Migration Path

### Phase 1: Foundation (The Base)

Start from the nix_neovim MVP. It already has the right architecture:
- `config/options.lua` -- bring over all vim.opt settings from sets.nix
- `config/keymaps.lua` -- implement the streamlined keymap table above
- `plugins/mini.lua` -- expand from current MVP to include all mini modules listed above

**Test gate**: Open Neovim. Navigate files with mini.pick. Edit code. Verify mini
modules work. This should take 1-2 hours.

### Phase 2: Language Intelligence

- `plugins/lsp.lua` -- add all language servers (expand from current 3 to full set)
- `plugins/format.lua` -- add conform.nvim with clean ownership table
- `plugins/lint.lua` -- add nvim-lint with no double-linting
- `plugins/treesitter.lua` -- treesitter + context

**Test gate**: Open a Python file. Verify: diagnostics from pyright, formatting from
ruff via conform, hover/definition/references via native LSP. No duplicate diagnostics.
This should take 2-3 hours.

### Phase 3: Git

- `plugins/git.lua` -- gitsigns + neogit + diffview

**Test gate**: Make a change. See gutter signs (from gitsigns only, not mini.diff).
Stage a hunk. Open neogit. Commit. 1 hour.

### Phase 4: Advanced (On Demand)

- `plugins/dap.lua` -- debugging configs
- `plugins/test.lua` -- neotest configs
- `plugins/tools.lua` -- obsidian, markdown-preview if desired

**Test gate**: Set a breakpoint. Run a test. These are complex but self-contained.
2-3 hours.

### Phase 5: Validate and Cut Over

- Run both configs side by side for a day
- Verify every daily workflow works in the new config
- Archive the old config directory
- Update the flake

**Total estimated effort**: 8-12 hours (not 14-20 like the previous estimate, because
we're cutting 60% of the plugins instead of migrating them)

---

## Part 5: Summary -- What Changed From the Previous Overview

The previous overview was a 1:1 inventory that proposed migrating 50+ plugins to Lua
with a 30% reduction to ~35 plugins. This revision takes a fundamentally different
approach:

| Aspect | Previous Overview | This Revision |
|--------|-------------------|--------------|
| Philosophy | "Preserve all functionality" | "Preserve all *needed* functionality, cut the rest" |
| Plugin count | ~35 (from 50+) | ~12 (from 50+) |
| Redundancy | Identified some, kept most | Identified all, eliminated all |
| Mini.nvim role | "Supplement" | "Primary framework" |
| LSPSaga | "Keep if you want polish" | "Cut -- Neovim 0.11+ does this natively" |
| Telescope | "Keep for advanced features" | "Replace with mini.pick" |
| Notification | "Replace notify with mini.notify" | "Replace ALL THREE (notify + fidget + noice) with mini.notify" |
| Completion | "Keep nvim-cmp as-is" | "Start with mini.completion, add blink.cmp if needed" |
| Terminal | "Keep toggleterm" | "10 lines of Lua" |
| Effort estimate | 14-20 hours | 8-12 hours (less migration, more deletion) |
| Mental model | 80+ keybindings, 10+ categories | ~40 keybindings, 7 categories |

The key insight: **migration is harder than starting clean**. The previous plan tried to
faithfully translate 62 Nix modules into Lua. This plan asks "what do you actually need?"
and builds only that. The nix_neovim MVP already proved the architecture works. Now we
just fill in the gaps -- and there are fewer gaps than expected, because Neovim itself
has gotten much better.

---

## Appendix A: Neovim 0.11+ Builtin Features That Replace Plugins

| Builtin Feature | API | Plugin It Replaces |
|----------------|-----|-------------------|
| LSP config | `vim.lsp.config()`, `vim.lsp.enable()` | nvim-lspconfig (partially) |
| LSP hover | `vim.lsp.buf.hover()` | LSPSaga hover |
| LSP definition | `vim.lsp.buf.definition()` | LSPSaga finder |
| LSP references | `vim.lsp.buf.references()` | LSPSaga finder |
| LSP rename | `vim.lsp.buf.rename()` | LSPSaga rename |
| LSP code action | `vim.lsp.buf.code_action()` | LSPSaga code action |
| Diagnostics float | `vim.diagnostic.open_float()` | LSPSaga / Trouble |
| Diagnostic jump | `vim.diagnostic.jump({count=1})` | LSPSaga diagnostic jump |
| Diagnostic list | `vim.diagnostic.setqflist()` | Trouble.nvim |
| Inlay hints | `vim.lsp.inlay_hint.enable()` | LSPSaga |
| Snippet engine | `vim.snippet.expand()`, `vim.snippet.jump()` | LuaSnip (basic usage) |
| Comment toggle | `gc` / `gcc` operators | mini.comment / Comment.nvim |
| Floating borders | `vim.lsp.handlers` border config | Dressing.nvim borders |
| LspProgress event | `vim.api.nvim_create_autocmd("LspProgress", ...)` | fidget.nvim |

---

## Appendix B: mini.nvim Module Reference (Only What We Use)

| Module | Config Lines | What It Does |
|--------|-------------|-------------|
| `mini.ai` | 1 | Extended text objects: `va)`, `vi"`, function args, etc. |
| `mini.surround` | 1 | `sa`/`sd`/`sr` for add/delete/replace surroundings |
| `mini.pairs` | 1 | Auto-close `(`, `[`, `{`, `"`, `'` |
| `mini.pick` | 1-5 | Fuzzy finder. `MiniPick.builtin.files()`, `.grep_live()`, `.buffers()` |
| `mini.files` | 1 | File explorer. Navigate with hjkl, create/rename/delete files. |
| `mini.notify` | 2 | `vim.notify` replacement with floating window display |
| `mini.statusline` | 1 | Mode + file + diagnostics + git + position. Zero config. |
| `mini.tabline` | 1 | Shows open buffers/tabs. Zero config. |
| `mini.indentscope` | 1 | Animated vertical line showing current scope |
| `mini.cursorword` | 1 | Auto-highlights all occurrences of word under cursor |
| `mini.sessions` | 3 | Auto-save/restore sessions by directory |
| `mini.starter` | ~30 | Dashboard with recent files, sessions, builtin actions |
| `mini.clue` | ~15 | After pressing `<leader>`, shows available continuations |
| `mini.move` | 1 | Alt+h/j/k/l to move lines or selections |
| `mini.trailspace` | 1 | Highlights trailing whitespace, `:lua MiniTrailspace.trim()` |

**Total mini.nvim config**: ~65 lines for 15 modules. Compare to 62 separate Nix files.

---

## Appendix C: Conceptual Simplification Table

For every task you do in the editor, there is now exactly one answer:

| Task | How | Tool |
|------|-----|------|
| Find a file | `<leader>ff` | mini.pick |
| Search in files | `<leader>fg` | mini.pick |
| Switch buffer | `<leader>fb` | mini.pick |
| Browse files | `<leader>e` | mini.files |
| See diagnostics | `[d`/`]d` to jump, `<leader>cd` for float, `<leader>x` for list | builtin |
| Hover docs | `K` | builtin LSP |
| Go to definition | `gd` | builtin LSP |
| See references | `gr` | builtin LSP |
| Rename symbol | `<leader>cr` | builtin LSP |
| Code action | `<leader>ca` | builtin LSP |
| Format code | Auto on save, `<leader>cf` manual | conform.nvim |
| Stage git hunk | `<leader>gs` | gitsigns |
| Git commit/push | `<leader>gg` | neogit |
| Toggle terminal | `<A-i>` | 10 lines of Lua |
| Session restore | Automatic on open | mini.sessions |
| See available keys | Press `<leader>` and wait | mini.clue |

No ambiguity. No "was that Telescope or mini.pick?" No "do I use Trouble or the
diagnostic float?" One tool per job.

---

*Document revised: 2026-03-01*
*Approach: Honest assessment, minimal viable config, builtin-first*
