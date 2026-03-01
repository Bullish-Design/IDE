# Starter Screen Redesign Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace the oversized, generic mini.starter screen with a clean globe-header dashboard featuring configurable global actions, project-aware session restore, and auto-detected per-project actions.

**Architecture:** Three new Lua modules under `nvim/lua/ui/`: a properly-sized header, a starter config table, and project detection logic. The existing `plugins/mini.lua` starter section gets rewritten to consume these modules. No new plugins -- uses mini.starter + mini.sessions only.

**Tech Stack:** Lua, mini.starter, mini.sessions, mini.pick

---

### Task 1: Replace the header with the daily-driver globe

**Files:**
- Modify: `nix_neovim_v2/nvim/lua/ui/header.lua`

**Step 1: Replace header.lua content**

Replace the entire 104-line header with the 26-line braille globe from the daily driver config (`config/ui/alpha.nix` lines 21-46). The globe is the same art style (braille dots), properly sized for a terminal.

```lua
-- nvim/lua/ui/header.lua
-- Returns header lines for mini.starter (braille globe, 26 lines)

return {
  "⠀⠀⠐⠀⠀⠂⠀⠀⠀⠀⠀⠀⠀⠀⠂⠀⠂⠌⢀⠀⢀⠀⠠⠀⠄⡀⠄⢀⠀⠀⠀⠠⠀⠀⠀⠀⠀⠀⠀⠀⡀⠀⠂⠀⠀⠀⠀⠀⠀⠀",
  "⠄⠀⠀⠀⠀⠀⠀⠀⠠⠀⠀⠀⠄⠀⠀⡐⢀⢂⣄⣦⣤⣞⣶⣷⡶⣶⣾⣶⣮⣤⣥⣐⡠⢀⠀⠂⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⠀",
  "⠀⠀⠀⠀⠀⠀⠀⡀⠀⠀⡀⢀⠀⣄⣥⡶⣯⣻⡽⣿⡟⢫⢝⣼⣼⡿⣛⡯⣟⢻⣝⡿⣻⢷⣾⣄⡂⠐⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
  "⠀⠀⠀⠀⠀⠀⠀⠀⠠⢀⢐⡴⣾⡹⢦⡻⡱⢎⠟⡲⡬⢣⣾⣿⣶⣛⡧⣟⣼⢯⢶⣣⣏⣿⡻⣿⣿⣷⣌⡀⠀⠄⠀⠀⠀⠀⠀⠀⠀⠀",
  "⠁⠀⠠⠀⠀⠀⠄⠠⢁⣶⡿⢿⡽⡘⡦⢧⠟⡡⢎⣱⣼⡟⣯⡗⢷⡻⣹⢾⣯⣟⠳⣧⢞⣱⢏⠵⣺⠷⡯⢿⣦⡐⢀⠀⠀⠀⠂⠀⠀⠀",
  "⠀⠈⠀⢀⠀⢀⢂⣵⣟⣿⢣⡏⡮⣱⠟⣌⢣⠣⣍⣾⣿⣻⢣⡜⣣⣝⡌⠞⡧⢟⣿⣸⡟⡼⣚⣿⣥⣣⣝⣮⣼⢿⣆⠀⡀⠀⠀⠀⠀⠀",
  "⠀⠀⠀⠀⡐⢠⣾⡯⣿⣕⣣⠷⡹⢇⡞⢣⠳⣡⣢⣿⣯⢳⢿⣺⣵⣿⣻⢿⣕⣫⣜⣿⣧⢣⡱⣿⣿⣿⢿⡿⢽⣿⣿⣷⡀⠀⠀⠀⠀⠀",
  "⠐⠀⠀⠂⢤⣿⣯⢳⡏⡖⡼⢱⡝⣬⣘⠳⣩⣕⣻⣟⣞⢣⡯⣷⣿⣿⣯⣟⣞⣛⠿⣾⣿⣮⡷⢯⡿⣿⣺⣴⡍⡝⣿⣿⣷⡌⠀⠀⠂⠀",
  "⠀⠀⠀⢡⣿⣏⢾⣣⢼⠱⡱⢷⣛⠶⣹⣿⣿⣿⣟⡏⡞⣯⣟⣷⢿⡾⣿⣿⣮⣻⣗⠬⣉⢷⡯⢇⣛⢿⣷⣿⣿⣶⡰⢻⣿⣾⡀⠄⠀⠀",
  "⠀⠀⡀⣟⢶⣉⡞⣡⠣⢥⡑⠟⢇⣿⢿⢻⢿⣏⢎⠶⣝⣳⢻⢯⡾⣽⣹⣟⣿⣾⣿⣿⡔⣢⠝⣆⢯⣧⠟⣧⣿⡿⣿⣿⣻⣿⣧⠐⠀⠀",
  "⠀⠀⢰⡘⠦⡖⡹⢰⡉⢦⠱⢩⢲⢻⣛⢮⠱⣾⢬⢻⢼⣽⡾⢯⢷⣡⢟⣿⣿⣿⣿⣿⡷⣧⣺⣍⣷⣿⣿⣭⣻⣏⣿⣿⣿⣿⣿⡄⠁⠀",
  "⠀⠀⢂⡙⢦⣑⡳⢋⡜⢄⠣⣌⢻⠷⣹⠦⣓⠬⣂⠟⣾⡝⠯⣏⡷⣎⡟⡾⣹⢿⣿⣨⡷⣾⣽⣼⣛⡞⣶⢯⡻⢿⣿⣿⣿⣿⣿⡇⠈⠀",
  "⠀⠀⠠⢘⠰⣋⠴⡡⠘⣌⠒⡴⢋⡒⢝⡸⠰⣏⡹⢜⡱⣛⠶⣭⢷⡼⣋⠔⡠⠚⢤⣊⣷⣿⡼⣿⢽⣿⣐⢣⣙⣿⣿⣿⣿⣿⣿⣟⠀⠁",
  "⠀⠀⠀⠂⠱⣀⠣⡐⠩⢄⠓⢎⠽⠷⣧⡬⣱⡦⡑⢮⡝⣭⢻⣌⡷⣫⡝⢠⠡⡉⢦⠭⣿⣿⣿⣷⣾⡿⣿⣼⣿⣬⣿⣿⣿⣿⣿⢯⠐⡀",
  "⠀⠁⠀⠀⠁⠄⠱⣈⠱⡈⢎⠢⡍⢦⠭⠖⣹⢳⡍⢶⠹⣌⠷⣹⢎⡵⢈⠆⡱⢌⠊⡜⠾⣿⣟⣯⣷⢹⣜⢻⣾⣛⣷⣿⣿⢿⡽⡇⠀⠀",
  "⠀⢀⠀⠀⠀⠈⠐⠠⠑⠨⢌⠱⡈⢆⡉⢆⠡⠚⢴⢣⡙⢆⠓⣌⢣⠞⣄⠊⢴⢩⠒⡬⣗⣞⠿⣫⢿⣜⡾⣯⠛⣽⣿⣻⢾⣯⢻⠅⠀⠄",
  "⠀⠀⠀⠀⠀⠀⠀⠀⠁⠂⠌⠢⢑⠂⡜⢠⠃⡍⢢⢡⡘⠢⣍⠰⣋⠞⡬⡙⢌⣧⣮⠔⡤⢈⠞⡱⡬⠖⡹⣝⢿⣹⢾⣹⠳⣎⠳⠀⠀⠀",
  "⠀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠐⠠⢁⠘⠠⠑⡌⢂⠆⡜⡱⢌⡱⢌⡚⡔⡡⢭⡖⡾⡌⢔⠣⣜⡳⢌⠱⣐⡻⢞⡝⣎⠧⡛⠄⠃⠀⠀⠀",
  "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠄⠈⠄⠡⠐⠠⠘⠤⡑⢌⠐⢢⠑⡘⠴⣣⠞⡱⡙⢆⠱⢨⢓⠌⠢⢥⡙⢎⡜⢌⠒⠡⠈⠀⠀⠀⠀",
  "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⠀⠁⠂⠁⢂⠐⡈⠄⠡⠘⡈⠑⠌⡙⠤⠑⠌⢢⠑⡊⢌⡑⠢⠘⠠⠈⠄⠈⠀⠀⠀⠀⠀⠀",
  "⠀⠀⠀⠀⠠⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠀⠁⠀⠁⠂⠐⠠⠁⠌⠀⠂⠐⠀⠀⠁⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
  "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠁⠀⠀⠀⠀⠀⠀⠀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
  "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠂⠀⠀⠀⠀⠀⠀⠠⠀⠀⠀⠀⠀⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
  "⠀⠀⠀⠐⠀⠀⠀⠀⠀⠀⠀⠀⠄⠀⠀⠈⠀⠀⠀⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠁⠀⠀⠈⠀",
  "⠀⠀⡀⠀⠀⠀⠠⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠀⠀⠠⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
  "⠀⠀⡀⠀⠀⠀⠀⠀⡁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
}
```

**Step 2: Verify file saved correctly**

Run: `wc -l nix_neovim_v2/nvim/lua/ui/header.lua`
Expected: ~30 lines (header table + comments)

**Step 3: Commit**

```bash
git add nix_neovim_v2/nvim/lua/ui/header.lua
git commit -m "fix(starter): replace oversized header with compact braille globe"
```

---

### Task 2: Create the starter configuration module

**Files:**
- Create: `nix_neovim_v2/nvim/lua/ui/starter_config.lua`

**Step 1: Create starter_config.lua**

This module defines the configurable global actions table and the project detection logic. It exports items that mini.starter can consume directly.

```lua
-- nvim/lua/ui/starter_config.lua
-- Configurable starter screen: global actions, project sessions, project-specific actions

local M = {}

-- ─── Global actions (user-configurable) ──────────────────────────────────────
-- Each entry: { name = "display text", action = "command or function", section = "section name" }
-- To customize: edit this table.
M.global_actions = {
  { name = "Find File",    action = [[lua MiniPick.builtin.files()]],     section = "Actions" },
  { name = "Live Grep",    action = [[lua MiniPick.builtin.grep_live()]], section = "Actions" },
  { name = "Recent Files", action = [[lua MiniPick.builtin.files({ tool = "git" })]],  section = "Actions" },
  { name = "New File",     action = "enew | startinsert",                 section = "Actions" },
  { name = "Quit",         action = "qa",                                 section = "Actions" },
}

-- ─── Project detection ───────────────────────────────────────────────────────
-- Walk up from cwd looking for root markers. Returns project root or nil.
local root_markers = { ".git", "Makefile", "package.json", "Cargo.toml", "pyproject.toml", "flake.nix", "go.mod" }

function M.find_project_root()
  local path = vim.fn.getcwd()
  for _ = 1, 20 do -- max 20 levels
    for _, marker in ipairs(root_markers) do
      if vim.fn.isdirectory(path .. "/" .. marker) == 1 or vim.fn.filereadable(path .. "/" .. marker) == 1 then
        return path
      end
    end
    local parent = vim.fn.fnamemodify(path, ":h")
    if parent == path then break end
    path = parent
  end
  return nil
end

-- ─── Project-specific actions ────────────────────────────────────────────────
-- Auto-detected from files in cwd. Returns a list of starter items.
-- Users can add their own detectors to this table.
M.project_detectors = {
  {
    marker = "pyproject.toml",
    actions = {
      { name = "Run pytest",        action = "!pytest",              section = "Project" },
      { name = "Open pyproject",    action = "edit pyproject.toml",  section = "Project" },
    },
  },
  {
    marker = "Cargo.toml",
    actions = {
      { name = "Cargo build",       action = "!cargo build",         section = "Project" },
      { name = "Cargo test",        action = "!cargo test",          section = "Project" },
      { name = "Open Cargo.toml",   action = "edit Cargo.toml",      section = "Project" },
    },
  },
  {
    marker = "package.json",
    actions = {
      { name = "npm test",          action = "!npm test",            section = "Project" },
      { name = "Open package.json", action = "edit package.json",    section = "Project" },
    },
  },
  {
    marker = "flake.nix",
    actions = {
      { name = "Nix develop",       action = "!nix develop",         section = "Project" },
      { name = "Open flake.nix",    action = "edit flake.nix",       section = "Project" },
    },
  },
  {
    marker = "go.mod",
    actions = {
      { name = "Go test",           action = "!go test ./...",       section = "Project" },
      { name = "Open go.mod",       action = "edit go.mod",          section = "Project" },
    },
  },
  {
    marker = "Makefile",
    actions = {
      { name = "Make",              action = "!make",                section = "Project" },
      { name = "Open Makefile",     action = "edit Makefile",        section = "Project" },
    },
  },
}

function M.detect_project_actions()
  local actions = {}
  local cwd = vim.fn.getcwd()
  for _, detector in ipairs(M.project_detectors) do
    local path = cwd .. "/" .. detector.marker
    if vim.fn.filereadable(path) == 1 or vim.fn.isdirectory(path) == 1 then
      for _, action in ipairs(detector.actions) do
        table.insert(actions, action)
      end
    end
  end
  return actions
end

-- ─── Session items ───────────────────────────────────────────────────────────
-- Build starter items from mini.sessions detected sessions.
function M.session_items()
  local ok, sessions = pcall(function() return require("mini.sessions").detected end)
  if not ok or not sessions then return {} end

  local items = {}
  -- Sort by modify time (most recent first), take top 5
  local sorted = {}
  for name, info in pairs(sessions) do
    table.insert(sorted, { name = name, modify_time = info.modify_time or 0 })
  end
  table.sort(sorted, function(a, b) return a.modify_time > b.modify_time end)

  for i, session in ipairs(sorted) do
    if i > 5 then break end
    table.insert(items, {
      name = session.name,
      action = string.format([[lua MiniSessions.read("%s")]], session.name),
      section = "Sessions",
    })
  end
  return items
end

-- ─── Build all items ─────────────────────────────────────────────────────────
-- Combines sessions + global actions + project-specific actions
function M.build_items()
  local items = {}

  -- Sessions first (if any exist)
  vim.list_extend(items, M.session_items())

  -- Global actions
  vim.list_extend(items, M.global_actions)

  -- Project-specific actions
  vim.list_extend(items, M.detect_project_actions())

  return items
end

return M
```

**Step 2: Verify file created**

Run: `wc -l nix_neovim_v2/nvim/lua/ui/starter_config.lua`
Expected: ~115 lines

**Step 3: Commit**

```bash
git add nix_neovim_v2/nvim/lua/ui/starter_config.lua
git commit -m "feat(starter): add configurable actions, project detection, session items"
```

---

### Task 3: Rewrite the mini.starter setup in plugins/mini.lua

**Files:**
- Modify: `nix_neovim_v2/nvim/lua/plugins/mini.lua` (lines 36-52, the starter section)

**Step 1: Replace the starter section**

Replace lines 36-52 (the current starter setup) with the new configuration that uses the header and starter_config modules.

Old code (lines 36-52):
```lua
-- Starter (dashboard)
local starter = require("mini.starter")
local recent = starter.sections.recent_files(8, true)
local builtin = starter.sections.builtin_actions()

-- Ensure both are tables
recent = (type(recent) == "table") and recent or {}
builtin = (type(builtin) == "table") and builtin or {}

starter.setup({
  header = table.concat(require("ui.header"), "\n"),
  items = vim.list_extend(recent, builtin),
  content_hooks = {
    starter.gen_hook.adding_bullet("• "),
    starter.gen_hook.aligning("center", "center"),
  },
})
```

New code:
```lua
-- Starter (dashboard)
local starter = require("mini.starter")
local starter_config = require("ui.starter_config")

starter.setup({
  header = table.concat(require("ui.header"), "\n"),
  items = starter_config.build_items(),
  content_hooks = {
    starter.gen_hook.adding_bullet("  "),
    starter.gen_hook.indexing("all", { "Sessions", "Actions", "Project" }),
    starter.gen_hook.aligning("center", "center"),
  },
  footer = function()
    local root = starter_config.find_project_root()
    if root then
      return "  " .. vim.fn.fnamemodify(root, ":~")
    end
    return ""
  end,
})
```

Key changes:
- Items now come from `starter_config.build_items()` (sessions + global + project)
- `indexing` hook adds keyboard shortcuts to each item automatically
- `footer` shows current project root if detected
- Bullet changed from "• " to "  " (icon-friendly spacing)

**Step 2: Also update the VimEnter autocmd** (lines 86-93)

The current autocmd at the bottom of mini.lua opens the starter. Update the condition to not open if a session was auto-read.

Old code:
```lua
-- Open starter on empty launch
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- Only show starter if no file is being edited and no session is being restored
    if vim.fn.argc() == 0 then
      require("mini.starter").open()
    end
  end,
})
```

New code:
```lua
-- Open starter on empty launch
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- Only show starter if no file is being edited and no session was auto-loaded
    if vim.fn.argc() == 0 and vim.v.this_session == "" then
      require("mini.starter").open()
    end
  end,
})
```

**Step 3: Update mini.sessions config** (lines 30-34)

Change `autoread = true` to `autoread = false` so sessions don't auto-restore (the user should pick from the starter screen instead).

Old:
```lua
require("mini.sessions").setup({
  directory = vim.fn.stdpath("data") .. "/sessions",
  autoread = true,
  autowrite = true,
})
```

New:
```lua
require("mini.sessions").setup({
  directory = vim.fn.stdpath("data") .. "/sessions",
  autoread = false,
  autowrite = true,
})
```

**Step 4: Commit**

```bash
git add nix_neovim_v2/nvim/lua/plugins/mini.lua
git commit -m "feat(starter): integrate configurable items, project detection, session picker"
```

---

### Task 4: Update the session autocmd to use project-aware naming

**Files:**
- Modify: `nix_neovim_v2/nvim/lua/config/autocmds.lua` (lines 25-31)

**Step 1: Replace the VimLeavePre session autocmd**

The current autocmd saves sessions with a generic name. Change it to name sessions after the project directory so they show up meaningfully on the start screen.

Old code:
```lua
-- Auto-save sessions
vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    if vim.fn.exists("b:miniSessionsActive") == 0 then
      pcall(function() require("mini.sessions").write() end)
    end
  end,
})
```

New code:
```lua
-- Auto-save sessions (named by project directory)
vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    -- Name session after the current directory (e.g. "nix_neovim_v2")
    local session_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
    if session_name and session_name ~= "" then
      pcall(function() require("mini.sessions").write(session_name) end)
    end
  end,
})
```

**Step 2: Commit**

```bash
git add nix_neovim_v2/nvim/lua/config/autocmds.lua
git commit -m "feat(sessions): name sessions by project directory for starter display"
```

---

### Task 5: Add session keymaps for starter integration

**Files:**
- Modify: `nix_neovim_v2/nvim/lua/config/keymaps.lua` (lines 58-61)

**Step 1: Add a "return to starter" keymap**

Add a keymap to return to the starter screen from anywhere.

After the existing session keymaps (line 61), add:

```lua
map("n", "<leader>qd", function() require("mini.starter").open() end, { desc = "Dashboard" })
```

**Step 2: Commit**

```bash
git add nix_neovim_v2/nvim/lua/config/keymaps.lua
git commit -m "feat(keymaps): add leader-qd to return to dashboard"
```

---

### Task 6: Verify the full integration works

**Step 1: Check all Lua files parse correctly**

Run from the nix_neovim_v2 directory:
```bash
for f in nvim/lua/ui/header.lua nvim/lua/ui/starter_config.lua nvim/lua/plugins/mini.lua nvim/lua/config/autocmds.lua nvim/lua/config/keymaps.lua; do
  echo "Checking $f..."
  luajit -e "loadfile('$f')()" 2>&1 || echo "PARSE ERROR in $f"
done
```

Expected: No syntax errors.

**Step 2: Verify starter_config module is self-consistent**

Run:
```bash
luajit -e "
  package.path = 'nvim/lua/?.lua;' .. package.path
  local sc = dofile('nvim/lua/ui/starter_config.lua')
  assert(type(sc.global_actions) == 'table', 'global_actions missing')
  assert(type(sc.detect_project_actions) == 'function', 'detect_project_actions missing')
  assert(type(sc.session_items) == 'function', 'session_items missing')
  assert(type(sc.build_items) == 'function', 'build_items missing')
  assert(type(sc.find_project_root) == 'function', 'find_project_root missing')
  print('All exports OK')
"
```

Expected: "All exports OK"

**Step 3: Final commit**

```bash
git add -A
git commit -m "chore(starter): verify all modules integrate correctly"
```
