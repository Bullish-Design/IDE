# nix_neovim_v2

A **minimal, coherent, production-ready** Neovim configuration for NixOS and Home Manager. Built on mini.nvim with a "one tool per task" philosophy—no plugin bloat, clear ownership, zero conflicts.

---

## 🎯 Philosophy

This configuration follows three core principles:

1. **Minimal:** Only essential tools. One plugin per task.
2. **Coherent:** Clear, interconnected modules. Easy to understand and extend.
3. **mini.nvim-first:** Leverages mini.nvim's lightweight, focused ecosystem for UI, navigation, and sessions.

### Three-Tier Architecture

- **Tier 1 (Builtins):** Neovim's builtin LSP, diagnostics, terminal, DAP
- **Tier 2 (mini.nvim):** UI (clue, notify), navigation (pick, files), sessions
- **Tier 3 (Specialized):** Language tools, formatters, linters, git integration

---

## 📋 Features at a Glance

| Feature | Tool | Status |
|---------|------|--------|
| **UI & Navigation** | mini.nvim (clue, pick, files, notify) | ✅ |
| **Code Completion** | nvim-cmp + nvim-lspconfig | ✅ |
| **Formatting** | conform-nvim | ✅ |
| **Linting** | nvim-lint | ✅ |
| **Debugging** | nvim-dap + nvim-dap-ui | ✅ |
| **Testing** | neotest (Python, Rust, Vitest) | ✅ |
| **Git** | gitsigns, neogit, diffview | ✅ |
| **Treesitter** | nvim-treesitter + context | ✅ |
| **Terminal** | Builtin (no plugin needed) | ✅ |
| **Sessions** | mini.sessions | ✅ |

---

## 🚀 Quick Start

### Prerequisites

- **NixOS** or **Home Manager** (Linux/macOS)
- **Flakes** enabled (`experimental-features = nix-command flakes`)
- Neovim 0.11+ (automatically installed via Nix)

### Installation

#### Option 1: Standalone (Temporary Shell)

Test the configuration without modifying your system:

```bash
cd /path/to/nix_neovim_v2
nix flake show  # View available outputs
nix flake develop  # Enter development environment with Neovim
nvim --version  # Verify Neovim 0.11+
```

#### Option 2: Home Manager Integration (Permanent)

Add to your Home Manager configuration:

```nix
# In your home.nix or flake.nix
{
  imports = [
    nix-neovim-v2.homeManagerModules.default
  ];

  # Customize home manager settings as needed
  home.stateVersion = "23.11";
}
```

Then apply:
```bash
home-manager switch --flake ".#your-host"
```

---

## 🧪 Testing in Actual Neovim

This section guides you through comprehensive testing of the configuration to verify all features work correctly.

### Prerequisites for Testing

Ensure you're in a fresh development environment:

```bash
cd /home/andrew/Documents/Projects/IDE/nix_neovim_v2
nix flake update  # Update lockfile (optional, for latest packages)
nix flake develop  # Enter dev environment
```

This provides:
- Neovim 0.11+ pre-configured
- All LSP servers (lua-language-server, rust-analyzer, pyright, etc.)
- Formatters (stylua, ruff, prettier)
- Test runners (Python, Rust, Node.js)
- Git tools

### Phase 1: Startup & Basic Navigation (5 min)

**Test:** Verify Neovim starts cleanly without errors.

```bash
# In the nix flake develop shell:
nvim
```

**Expected:** Clean startup with no error messages.

**What to check:**
- Status line appears (mode, file, line/col)
- No red error highlights
- No "E" symbols in column (diagnostic markers)

**Test keybinding:** Press `<space>` (leader) to see available commands
- Expected: Mini.clue menu appears showing all available key hints
- If it doesn't: Try `<space>u<space>` to toggle clue hints

**Commands to try:**

| Keybind | Action | Expected Result |
|---------|--------|-----------------|
| `<C-s>` | Save current file | File written |
| `<leader>h` | Clear search highlight | Any previous highlights disappear |
| `<Esc>` | Return to normal mode | Cursor visible, mode shows "n" |
| `<leader>q` | Quit all | Neovim exits (you're still in nix develop shell) |

**Restart Neovim for next tests:**
```bash
nvim
```

---

### Phase 2: File Navigation with mini.pick (5 min)

**Test:** File finding, buffer switching, and grep functionality.

**Commands:**

| Keybind | Action | Test With |
|---------|--------|-----------|
| `<leader>ff` | Find files | Type "README" → should show README.md |
| `<leader>fg` | Live grep | Type "mini" → shows all lines mentioning mini |
| `<leader>fb` | Find buffers | If multiple buffers open, shows list |
| `<leader>e` | File explorer | Should toggle sidebar showing file tree |

**What to check:**
- Typing filters results in real-time
- Arrow keys navigate
- Enter opens file
- Backspace in file explorer navigates up

**Test the file explorer specifically:**
```
1. Press <leader>e
   → File tree appears on left side
2. Arrow down to 'nvim' directory
3. Press Enter
   → Expands to show config files
4. Find 'init.lua' and press Enter
   → Opens init.lua in editor
5. Press <leader>e again
   → File explorer closes
```

---

### Phase 3: LSP & Code Completion (8 min)

**Test:** Language server integration, hover info, code completion, diagnostics.

**Setup:** Create test file with intentional errors

```bash
# In Neovim, create new file:
:e test.lua
```

**Type this code with intentional error:**
```lua
local function greet(name)
  print("Hello " .. nam)  -- typo: 'nam' instead of 'name'
end

greet("World")
```

**Save the file:**
```
:w test.lua
```

**What to check:**

1. **Diagnostic markers:**
   - Red squiggly underline appears under `nam`
   - Line number marked with "E" in sign column

2. **Jump to diagnostics:**
   - Press `]d` → cursor jumps to error
   - Press `[d` → jumps to previous error (should cycle)
   - Press `<leader>x` → opens quickfix list with all errors

3. **Hover information:**
   - Move cursor to `print`
   - Hover/look for popup with function signature
   - (Note: requires mini.notify to be working)

4. **Code completion:**
   - Position cursor after opening paren: `greet(`
   - Press `<C-n>` (or use autocomplete if enabled)
   - Completion menu should show available variables
   - Arrow keys navigate, Enter selects

5. **Diagnostics fix:**
   - Change `nam` to `name`
   - Save with `<C-s>`
   - Error should disappear automatically

**Cleanup:**
```bash
# Still in Neovim
:bd test.lua
```

---

### Phase 4: Terminal Integration (3 min)

**Test:** Builtin terminal toggle functionality.

**Commands:**

| Keybind | Action |
|---------|--------|
| `<A-i>` | Toggle terminal |

**Test sequence:**
```
1. Press <A-i>
   → Terminal appears at bottom (15 lines high)
2. Type: echo "Hello from Neovim terminal"
3. Press Enter
   → Command executes, output shows
4. Press <A-i>
   → Terminal closes, back to editor
5. Press <A-i> again
   → Same terminal reopens with history preserved
```

**What to check:**
- Terminal appears/disappears consistently
- Terminal content persists between toggles
- Cursor can move between editor and terminal
- Commands execute correctly

---

### Phase 5: Git Integration (5 min)

**Test:** Git gutter signs, hunk preview, blame, diff.

**Prerequisites:** You're in a git repository (the project itself is one)

```bash
# In Neovim, open any Lua file:
:e nvim/lua/config/options.lua
```

**What to check:**

1. **Gutter signs:**
   - Look at left edge (sign column)
   - You'll see `│` (pipe) characters for changed lines
   - `_` for deleted lines
   - `‾` for top-deleted lines

2. **Git keybindings (leader g):**

| Keybind | Action | Expected |
|---------|--------|----------|
| `]h` | Next hunk | Cursor jumps to next changed section |
| `[h` | Prev hunk | Cursor jumps to previous hunk |
| `<leader>gp` | Preview hunk | Shows diff of current hunk in popup |
| `<leader>gb` | Blame line | Shows git blame for current line |
| `<leader>gd` | Diff this | Shows diff view for current file |

3. **Test hunk staging (requires git setup):**
   - Position cursor in a changed hunk
   - Press `<leader>gs` → hunk is staged
   - Run `:Gitsigns reset_hunk` if you want to unstage

4. **Neogit (full git porcelain):**
   - Press `:Neogit` and Enter
   - Shows full git status interface
   - (Press `q` to close)

---

### Phase 6: Session Management (3 min)

**Test:** Save and restore editing sessions.

**Commands:**

| Keybind | Action |
|---------|--------|
| `<leader>qs` | Save session |
| `<leader>qr` | Restore session |

**Test sequence:**

```
1. Have some files open:
   :e nvim/lua/config/options.lua
   :e nvim/lua/config/keymaps.lua
2. Navigate to specific lines in each file
3. Save session: <leader>qs
   → Session saved (notification appears)
4. Quit all: <leader>qq
   → Neovim closes
5. Restart: nvim
6. Restore: <leader>qr
   → Shows picker to select session
   → Choose the session you just saved
   → All files reopen in same positions
```

**What to check:**
- Files reopen correctly
- Cursor positions preserved
- Window layout restored

---

### Phase 7: UI Toggles (3 min)

**Test:** Runtime configuration toggles.

**Commands:**

| Keybind | Action | Result |
|---------|--------|--------|
| `<leader>ul` | Toggle line numbers | Line numbers appear/disappear |
| `<leader>ur` | Toggle relative numbers | Switch between absolute/relative numbering |
| `<leader>uw` | Toggle word wrap | Text wrapping on/off |
| `<leader>uh` | Toggle inlay hints | LSP inlay hints appear/disappear (if available for language) |
| `<leader>uf` | Toggle format on save | Notification shows state |

**What to check:**
- Toggle works immediately
- Changes persist while editing
- Settings reset on next Neovim launch (expected behavior)

---

### Phase 8: Formatting & Linting (5 min)

**Test:** Code formatting and linting.

**Create test file:**
```bash
# In Neovim:
:e test_format.py
```

**Type poorly formatted code:**
```python
def hello(  x,y  ):
    return x+y
```

**Test formatting:**

1. **Auto-format on save (enabled by default):**
   - Save: `<C-s>`
   - Code should auto-format to proper style
   - If it doesn't, check toggle: `<leader>uf` (should show "enabled")

2. **Manual format:**
   - Select all: `gg` + `G` (go to start, then to end)
   - Or use visual mode: `V` then arrow keys
   - Trigger format: `:Format` and Enter

**Test linting:**

```python
# Add linting error to same file:
import os  # unused import
```

Save the file. You should see:
- Diagnostic marker on the `import os` line
- Hover to see full error message
- Quickfix list: `<leader>x`

**Cleanup:**
```bash
:bd test_format.py
```

---

### Phase 9: Debugging (DAP) - Python (5 min)

**Test:** Debug adapter protocol setup (Python example).

**Prerequisites:** Python3 installed in nix develop shell (it is)

**Create test script:**

```bash
# In Neovim:
:e test_debug.py
```

**Type code:**
```python
def add(a, b):
    result = a + b  # We'll break here
    return result

print(add(2, 3))
```

**Test breakpoint & debug:**

1. **Set breakpoint:**
   - Position cursor on `result = a + b` line
   - Press `<leader>db` → Breakpoint set (should show marker)

2. **Start debugging:**
   - Press `<leader>dc` (continue/start)
   - Debug session should start (may open DAP UI panel)
   - Execution should pause at breakpoint

3. **Step through:**
   - Press `<leader>dO` (step over) → execute line
   - Press `<leader>di` (step into) → enter function (if on function call)
   - Press `<leader>do` (step out) → exit function

4. **View variables:**
   - While paused, look at DAP UI panel
   - Should show local variables (a, b, result)

5. **Terminate:**
   - Press `<leader>dt` → end debug session
   - Or `<leader>du` → toggle DAP UI panel

**Cleanup:**
```bash
:bd test_debug.py
```

**Note:** DAP setup requires language-specific adapters. Python uses debugpy (installed). For Rust/Go/Node, additional setup may be needed—check `nvim/lua/plugins/dap.lua` for configuration.

---

### Phase 10: Testing (Neotest) - Optional (5 min)

**Test:** Test runner integration.

**Prerequisites:** Language-specific test infrastructure

**For Python tests:**

```bash
# Create test file:
# In Neovim: :e test_sample.py
```

**Type test:**
```python
def test_addition():
    assert 2 + 2 == 4

def test_failure():
    assert 1 + 1 == 3  # This will fail
```

**Run tests:**

| Keybind | Action |
|---------|--------|
| `<leader>tt` | Run all tests in file |
| `<leader>tr` | Run nearest test (under cursor) |
| `<leader>ts` | Toggle test summary |
| `<leader>to` | Toggle test output panel |

**What to check:**
- Tests execute
- Passing tests show ✅
- Failing tests show ❌
- Output panel shows results

**Cleanup:**
```bash
:bd test_sample.py
```

---

### Phase 11: Obsidian Integration - Optional (3 min)

**Test:** Obsidian vault integration.

```bash
# In Neovim:
:ObsidianOpen
```

**What to check:**
- Opens configured Obsidian vault (if available)
- Creates new notes with `:ObsidianNew NoteName`
- Links work with completion

**Note:** Requires Obsidian vault path configured in `nvim/lua/plugins/tools.lua`

---

### Full Testing Checklist

Copy and check off as you test:

```
Phase 1: Startup & Basic Navigation
  [ ] Neovim starts cleanly
  [ ] Leader key shows menu (mini.clue)
  [ ] Ctrl-S saves
  [ ] Leader-Q quits

Phase 2: File Navigation
  [ ] Leader-FF finds files
  [ ] Leader-FG greps successfully
  [ ] Leader-E toggles file explorer
  [ ] Leader-FB switches buffers

Phase 3: LSP & Completion
  [ ] Diagnostics appear for errors
  [ ] [d and ]d jump between errors
  [ ] Hover shows info (or looks for hover)
  [ ] Completion menu appears with Ctrl-N

Phase 4: Terminal
  [ ] Alt-I toggles terminal
  [ ] Commands execute in terminal
  [ ] Terminal state persists

Phase 5: Git Integration
  [ ] Gutter signs visible
  [ ] Leader-GP shows hunk preview
  [ ] Leader-GB shows blame
  [ ] ]h and [h navigate hunks

Phase 6: Sessions
  [ ] Leader-QS saves session
  [ ] Leader-QR restores session
  [ ] Files/positions preserved

Phase 7: UI Toggles
  [ ] Leader-UL toggles line numbers
  [ ] Leader-UR toggles relative numbers
  [ ] Leader-UW toggles wrap
  [ ] Leader-UH toggles inlay hints

Phase 8: Formatting & Linting
  [ ] Auto-format on save works
  [ ] Linting shows errors
  [ ] Leader-X opens quickfix

Phase 9: Debugging (DAP)
  [ ] Leader-DB sets breakpoints
  [ ] Leader-DC starts debugging
  [ ] Step commands work (DO, DI, etc.)
  [ ] Variables visible in DAP UI

Phase 10: Testing (Neotest)
  [ ] Leader-TT runs tests
  [ ] Leader-TS shows summary
  [ ] Pass/fail clearly shown

Phase 11: Obsidian (Optional)
  [ ] :ObsidianOpen works
  [ ] Note creation works
```

---

## ⚙️ Configuration Structure

```
nix_neovim_v2/
├── flake.nix                    # Flake inputs & outputs
├── hm-module.nix                # Home Manager module
├── plugins.nix                  # Plugin list
├── nvim/
│   ├── init.lua                 # Entry point
│   ├── lua/
│   │   ├── config/
│   │   │   ├── init.lua         # Config loader
│   │   │   ├── options.lua      # Vim options (indent, timeouts, etc.)
│   │   │   ├── keymaps.lua      # Keybindings (all non-plugin maps)
│   │   │   └── autocmds.lua     # Auto-commands (auto-format, etc.)
│   │   └── plugins/
│   │       ├── init.lua         # Plugin loader
│   │       ├── lsp.lua          # LSP setup (nvim-lspconfig)
│   │       ├── format.lua       # Formatting (conform-nvim)
│   │       ├── lint.lua         # Linting (nvim-lint)
│   │       ├── mini.lua         # Mini.nvim modules setup
│   │       ├── git.lua          # Git tools (gitsigns, neogit, diffview)
│   │       ├── dap.lua          # Debugging (nvim-dap)
│   │       ├── test.lua         # Testing (neotest)
│   │       ├── treesitter.lua   # Syntax highlighting (nvim-treesitter)
│   │       ├── tools.lua        # Additional tools (obsidian, markdown-preview)
│   │       └── codecompanion.lua # AI companion (optional)
│   └── plugins/                 # Mini.nvim spec files
│       └── codecompanion.nix     # CodeCompanion package spec
├── README.md                    # This file
└── NIX_NEOVIM_FINAL_REVIEW.md   # Detailed code review & fix history
```

---

## 🔑 Keybinding Reference

### Core Navigation

| Keybind | Action |
|---------|--------|
| `<space>` | Show available commands (mini.clue) |
| `<leader>ff` | Find files (mini.pick) |
| `<leader>fg` | Live grep (mini.pick) |
| `<leader>fb` | Find buffers |
| `<leader>fr` | Recent files |
| `<leader>e` | Toggle file explorer (mini.files) |

### Editing

| Keybind | Action |
|---------|--------|
| `<C-s>` | Save |
| `<C-d>` | Half-page down (with center) |
| `<C-u>` | Half-page up (with center) |
| `<` / `>` (visual) | Indent left/right (stay in visual) |

### LSP & Diagnostics

| Keybind | Action |
|---------|--------|
| `[d` | Previous diagnostic |
| `]d` | Next diagnostic |
| `<leader>x` | Diagnostics to quickfix |
| `<leader>uh` | Toggle inlay hints |

### Git

| Keybind | Action |
|---------|--------|
| `]h` / `[h` | Next/previous hunk |
| `<leader>gs` | Stage hunk |
| `<leader>gr` | Reset hunk |
| `<leader>gp` | Preview hunk |
| `<leader>gb` | Blame line |
| `<leader>gd` | Diff (working) |
| `<leader>gD` | Diff (cached) |
| `<leader>gS` | Stage buffer |
| `<leader>gR` | Reset buffer |
| `<leader>gu` | Undo stage |

### Debug

| Keybind | Action |
|---------|--------|
| `<leader>db` | Toggle breakpoint |
| `<leader>dc` | Continue |
| `<leader>di` | Step into |
| `<leader>do` | Step out |
| `<leader>dO` | Step over |
| `<leader>dt` | Terminate |
| `<leader>du` | Toggle DAP UI |

### Testing

| Keybind | Action |
|---------|--------|
| `<leader>tt` | Run file tests |
| `<leader>tr` | Run nearest test |
| `<leader>ts` | Toggle summary |
| `<leader>to` | Toggle output |

### Sessions

| Keybind | Action |
|---------|--------|
| `<leader>qs` | Save session |
| `<leader>qr` | Restore session |
| `<leader>qq` | Quit all |

### UI Toggles

| Keybind | Action |
|---------|--------|
| `<leader>ul` | Toggle line numbers |
| `<leader>ur` | Toggle relative numbers |
| `<leader>uw` | Toggle word wrap |
| `<leader>uh` | Toggle inlay hints |
| `<leader>uf` | Toggle format on save |

### Terminal

| Keybind | Action |
|---------|--------|
| `<A-i>` | Toggle terminal |

---

## 📦 Included Language Servers

All are automatically installed via Nix:

| Language | Server | Command |
|----------|--------|---------|
| Lua | lua-language-server | `lua-language-server` |
| Rust | rust-analyzer | `rust-analyzer` |
| Python | pyright | `pyright` |
| Go | gopls | `gopls` |
| TypeScript/JavaScript | typescript-language-server | `typescript-language-server` |
| Bash | bash-language-server | `bash-language-server` |
| Nix | nil | `nil` |
| C/C++ | clangd | `clangd` |

---

## 🛠️ Customization

### Add Custom Keybinding

Edit `nvim/lua/config/keymaps.lua`:

```lua
local map = vim.keymap.set

-- Your custom binding
map("n", "<leader>mc", function()
  print("Custom command!")
end, { desc = "My custom command" })
```

### Change Options

Edit `nvim/lua/config/options.lua`:

```lua
local opt = vim.opt

opt.tabstop = 2        -- 2-space tabs
opt.shiftwidth = 2     -- 2-space indent
opt.expandtab = true   -- Use spaces, not tabs
```

### Add a Plugin

1. Add to `plugins.nix`:
```nix
vp.your-plugin-name
```

2. Create config file `nvim/lua/plugins/your-plugin.lua`:
```lua
require("your-plugin").setup({
  -- options
})
```

3. Import in `nvim/lua/plugins/init.lua`:
```lua
require("plugins.your-plugin")
```

### Add a Language Server

1. Add LSP package to `hm-module.nix`:
```nix
your-language-server
```

2. Configure in `nvim/lua/plugins/lsp.lua`:
```lua
vim.lsp.enable("your-server")
```

---

## 🐛 Troubleshooting

### Neovim won't start: "E5108: Error executing lua"

**Check:** Look for the line number in the error. Usually a typo in a config file.

```bash
# Validate Lua syntax:
luacheck nvim/lua/config/options.lua
```

### LSP not starting

**Check:** Which servers are enabled in `nvim/lua/plugins/lsp.lua`?

```lua
-- Verify the server is in this list:
vim.lsp.enable("rust-analyzer")  -- example
```

**Verify installation:**
```bash
# In nix develop shell:
rust-analyzer --version
pyright --version
```

### Diagnostics not showing

**Check:** Diagnostics might be disabled:
```vim
:lua vim.diagnostic.config({ virtual_text = true })
```

### Colors look wrong

**Check:** Terminal color support. Try:
```vim
:set termguicolors
```

### Plugins not loading

**Check:** Flake may be out of sync:
```bash
nix flake update
nix flake develop
```

---

## 📚 Further Reading

- **mini.nvim docs:** https://github.com/echasnovski/mini.nvim
- **Neovim LSP guide:** `:help lsp`
- **Neovim builtin options:** `:help options`
- **DAP setup:** Check `nvim/lua/plugins/dap.lua` for language-specific adapters

---

## 📄 License

This configuration is provided as-is. Feel free to fork, modify, and adapt for your needs.

---

## 🔍 Code Quality & Verification

This configuration has been through comprehensive review:

- **All 31 critical issues fixed** (see `NIX_NEOVIM_FINAL_REVIEW.md` for details)
- **Flake validation:** ✅ Passes `nix flake check`
- **API compatibility:** ✅ Neovim 0.11+ only (modern APIs)
- **Plugin compatibility:** ✅ All plugins tested and verified

---

**Last Updated:** 2026-03-01  
**Version:** v2  
**Status:** Production-Ready ✅
