# Importing nv2 Into Your devenv.sh Projects

This guide explains how to import the `nix_neovim_v2` Neovim configuration
into any project managed by [devenv.sh](https://devenv.sh), giving you a
fully configured editor (LSPs, formatters, linters, treesitter, DAP, AI
companion) that activates automatically when you enter the project directory.

It covers local filesystem imports, git repository imports, per-project
overrides, and Neovim plugin development workflows.

---

## Table of Contents

- [Quick Start](#quick-start)
- [How It Works](#how-it-works)
  - [Architecture Overview](#architecture-overview)
  - [What You Get](#what-you-get)
  - [The Module Option System](#the-module-option-system)
- [Import Methods](#import-methods)
  - [Local Filesystem (git+file)](#local-filesystem-gitfile)
  - [Local Filesystem (path)](#local-filesystem-path)
  - [Git Repository](#git-repository)
  - [Updating the Import](#updating-the-import)
- [Per-Project Overrides](#per-project-overrides)
  - [Available Options](#available-options)
  - [Extra Lua Init Code](#extra-lua-init-code)
  - [Environment Variables](#environment-variables)
  - [Extra Packages (LSPs, Formatters, Linters)](#extra-packages-lsps-formatters-linters)
  - [Extra Plugins](#extra-plugins)
  - [Treesitter Grammars](#treesitter-grammars)
  - [Combining Multiple Overrides](#combining-multiple-overrides)
- [Neovim Plugin Development](#neovim-plugin-development)
  - [Basic Plugin Development Setup](#basic-plugin-development-setup)
  - [Adding a Project-Level init.lua](#adding-a-project-level-initlua)
  - [Testing Against Multiple Configurations](#testing-against-multiple-configurations)
- [Reference](#reference)
  - [Full Option Reference](#full-option-reference)
  - [Troubleshooting](#troubleshooting)

---

## Quick Start

This section gets nv2 running in your project in under two minutes.

### 1. Add the input to your project's devenv.yaml

**From your local filesystem** (recommended during development):

```yaml
# my-project/devenv.yaml
inputs:
  nixpkgs:
    url: github:NixOS/nixpkgs/nixos-unstable
  nix-neovim:
    url: git+file:///home/andrew/Documents/Projects/IDE/nix_neovim_v2
    flake: false
imports:
  - nix-neovim
```

**From a git repository** (for sharing across machines):

```yaml
# my-project/devenv.yaml
inputs:
  nixpkgs:
    url: github:NixOS/nixpkgs/nixos-unstable
  nix-neovim:
    url: github:yourusername/nix_neovim_v2
    flake: false
imports:
  - nix-neovim
```

### 2. Create or update your project's devenv.nix

If your project already has a `devenv.nix`, the nv2 module merges into it.
If you don't have one yet, create a minimal one:

```nix
# my-project/devenv.nix
{ pkgs, ... }:
{
  # Your project's own devenv config goes here.
  # The nv2 editor is already available via the import.
}
```

### 3. Enter the environment

```sh
cd my-project
devenv shell
```

The first run downloads and builds the Nix derivations (this takes a few
minutes). Subsequent runs are instant.

### 4. Launch the editor

```sh
nv2
```

You now have the full nv2 editor with all plugins, LSPs, formatters, and
linters available. When you leave the devenv shell (or cd out with direnv),
`nv2` is no longer on your PATH -- it's scoped to the project.

---

## How It Works

### Architecture Overview

The `nix_neovim_v2` repository exposes a **devenv module** -- a Nix function
that declares options, packages, and scripts. When you import it into your
project, devenv merges its configuration with your project's own `devenv.nix`.

```
┌─────────────────────────────────────────────┐
│  Your project's devenv.yaml                 │
│                                             │
│  inputs:                                    │
│    nix-neovim: git+file:///path/to/repo     │
│  imports:                                   │
│    - nix-neovim                             │
└───────────────┬─────────────────────────────┘
                │ imports devenv.nix from nix_neovim_v2
                ▼
┌─────────────────────────────────────────────┐
│  nix_neovim_v2/devenv.nix (the module)      │
│                                             │
│  Declares: options.nv2.{extraPlugins,       │
│    extraRuntimePaths, extraInitLua, env,    │
│    extraPackages, treesitterGrammars}       │
│                                             │
│  Provides: wrapped neovim binary + nv2      │
│    script + LSPs + formatters + linters     │
└───────────────┬─────────────────────────────┘
                │ merged with
                ▼
┌─────────────────────────────────────────────┐
│  Your project's devenv.nix                  │
│                                             │
│  Can set: nv2.extraPlugins, nv2.env,        │
│    nv2.extraInitLua, etc.                   │
│  Plus your own: packages, languages,        │
│    services, scripts, processes, etc.       │
└─────────────────────────────────────────────┘
```

The merged result is a single devenv environment containing both your
project's tooling and the nv2 editor.

### What You Get

The import adds the following to your devenv environment:

| Category       | What's Included                                                              |
|----------------|------------------------------------------------------------------------------|
| **Editor**     | Neovim (unstable) wrapped with all plugins via `wrapNeovimUnstable`          |
| **Script**     | `nv2` command on PATH that launches the configured editor                    |
| **Plugins**    | mini.nvim, nvim-lspconfig, conform, nvim-lint, nvim-treesitter (+context),   |
|                | gitsigns, neogit, diffview, nvim-dap (+ui, +python), neotest (+adapters),    |
|                | obsidian.nvim, markdown-preview, codecompanion                               |
| **LSP**        | lua_ls, nil_ls, bashls, pyright, rust-analyzer, clangd, gopls, ts_ls,        |
|                | eslint, html, cssls, jsonls, yamlls                                          |
| **Formatters** | stylua, alejandra, ruff, prettierd, goimports-reviser, nixfmt                |
| **Linters**    | shellcheck, statix, yamllint, selene, golangci-lint, markdownlint-cli2       |
| **DAP**        | debugpy                                                                      |
| **Treesitter** | 17 grammars: lua, vim, vimdoc, python, nix, rust, go, js, ts, tsx, json,     |
|                | yaml, html, css, markdown, markdown_inline, bash, c, cpp                     |
| **Utilities**  | git, ripgrep, fd                                                             |

All of these are added to your PATH inside the devenv shell. They don't
pollute your system -- they only exist within the project environment.

### The Module Option System

The nv2 module exposes a set of options under the `nv2` namespace that let
consumer projects customize the editor without modifying the nix_neovim_v2
repository. These options are evaluated at Nix build time and produce a
tailored `nv2` wrapper script.

When you write `nv2.extraPlugins = [ ... ]` in your project's `devenv.nix`,
Nix rebuilds the wrapped Neovim binary with those plugins included in the
packpath. When you write `nv2.extraInitLua = "..."`, Nix writes that Lua
code to a file in the store and adds a `-c "luafile ..."` flag to the `nv2`
script so it runs after the base `init.lua`.

This means all customization is declarative, reproducible, and tracked by
your project's `devenv.lock`.

---

## Import Methods

### Local Filesystem (git+file)

```yaml
inputs:
  nix-neovim:
    url: git+file:///home/andrew/Documents/Projects/IDE/nix_neovim_v2
    flake: false
imports:
  - nix-neovim
```

**How it works:** Nix clones the git repository at the given path and copies
the git-tracked files into the Nix store. The store path is recorded in
`devenv.lock` with the exact commit hash.

**Key behaviors:**
- Only **git-tracked, committed** files are visible. Uncommitted changes
  are not picked up.
- Uses the currently checked-out branch (typically `v2-lua`).
- Fast: no network access required, copies from local disk.
- Reproducible: locked to a specific commit in `devenv.lock`.

**When to use:** Day-to-day development on your local machine. This is the
recommended method when the nix_neovim_v2 repo lives on the same filesystem.

### Local Filesystem (path)

```yaml
inputs:
  nix-neovim:
    url: path:/home/andrew/Documents/Projects/IDE/nix_neovim_v2
    flake: false
imports:
  - nix-neovim
```

**How it works:** Nix copies the **entire directory** (not just git-tracked
files) into the Nix store on every evaluation.

**Key behaviors:**
- Picks up uncommitted changes immediately -- no need to commit first.
- Ignores `.gitignore` -- copies everything including `.devenv/`, build
  artifacts, etc.
- Slower: re-copies the entire directory on every `devenv shell` invocation
  if anything changed.
- Not reproducible: no commit hash to lock to.

**When to use:** Only during active development of the nix_neovim_v2 config
itself, when you need to test changes without committing. Switch back to
`git+file://` once you're done iterating.

### Git Repository

```yaml
inputs:
  nix-neovim:
    url: github:yourusername/nix_neovim_v2
    flake: false
imports:
  - nix-neovim
```

Or for a self-hosted git server:

```yaml
inputs:
  nix-neovim:
    url: git+https://git.example.com/user/nix_neovim_v2
    flake: false
```

Or pinned to a specific branch or tag:

```yaml
inputs:
  nix-neovim:
    url: github:yourusername/nix_neovim_v2?ref=v2-lua
    flake: false
```

**How it works:** Nix fetches the repository from the remote, caches it
locally, and locks the exact commit in `devenv.lock`.

**When to use:** When sharing the editor config across multiple machines,
with teammates, or in CI. This is the production-grade method.

### Updating the Import

When you make changes to the nix_neovim_v2 repo (and commit them), consumer
projects don't automatically pick them up. The commit hash is locked in
`devenv.lock`.

To update:

```sh
# Update just the nix-neovim input
devenv update nix-neovim

# Or update all inputs
devenv update
```

This fetches the latest commit, updates `devenv.lock`, and the next
`devenv shell` invocation will use the new version.

---

## Per-Project Overrides

All overrides go in your project's `devenv.nix` under the `nv2` attribute
set. These are NixOS-style module options -- they compose cleanly with the
base configuration.

### Available Options

| Option                     | Type                      | Default     | Purpose                                       |
|----------------------------|---------------------------|-------------|-----------------------------------------------|
| `nv2.extraPlugins`         | list of packages          | `[]`        | Additional Vim plugins for the packpath        |
| `nv2.extraRuntimePaths`    | list of strings           | `[]`        | Extra dirs prepended to runtimepath            |
| `nv2.extraInitLua`         | multiline string          | `""`        | Lua code sourced after init.lua                |
| `nv2.treesitterGrammars`   | function (grammarSet -> list) | (17 grammars) | Override which treesitter grammars to bundle |
| `nv2.env`                  | attribute set of strings  | `{}`        | Environment variables exported before launch   |
| `nv2.extraPackages`        | list of packages          | `[]`        | Additional packages added to devenv PATH       |

### Extra Lua Init Code

`nv2.extraInitLua` is the most flexible override. The Lua code you provide
runs **after** the base `init.lua` has finished loading all plugins and
configuration. This means all base modules (`mini.*`, `lspconfig`, `conform`,
etc.) are already available.

#### Override the color scheme

```nix
# my-project/devenv.nix
{ pkgs, ... }:
{
  nv2.extraInitLua = ''
    -- Tokyo Night-inspired palette for this project
    require("mini.hues").setup({
      background = "#1a1b26",
      foreground = "#c0caf5",
      saturation = "high",
      accent = "cyan",
    })
  '';
}
```

#### Add project-specific keymaps

```nix
{
  nv2.extraInitLua = ''
    -- Quick access to project test runner
    vim.keymap.set("n", "<leader>pt", function()
      vim.cmd("!make test")
    end, { desc = "Run project tests" })
  '';
}
```

#### Configure an additional LSP server

```nix
{ pkgs, ... }:
{
  nv2.extraPackages = [ pkgs.haskell-language-server ];

  nv2.extraInitLua = ''
    vim.lsp.config("hls", {
      settings = {
        haskell = {
          formattingProvider = "ormolu",
        },
      },
    })
    vim.lsp.enable("hls")
  '';
}
```

#### Override existing LSP settings

Since `extraInitLua` runs after the base config, you can call
`vim.lsp.config()` again to merge additional settings into an existing
server:

```nix
{
  nv2.extraInitLua = ''
    -- Use stricter type checking for this Python project
    vim.lsp.config("pyright", {
      settings = {
        python = {
          analysis = {
            typeCheckingMode = "strict",
          },
        },
      },
    })
  '';
}
```

### Environment Variables

`nv2.env` exports variables before launching Neovim. These are visible to
both Neovim and any child processes it spawns.

#### LLM API keys

```nix
{
  nv2.env = {
    ANTHROPIC_API_KEY = "sk-ant-api03-...";
    OPENAI_API_KEY = "sk-...";
  };
}
```

> **Security note:** Hardcoding API keys in `devenv.nix` means they end up
> in the Nix store (world-readable on your machine) and in version control
> if you commit `devenv.nix`. For sensitive keys, prefer one of these
> alternatives:
>
> - Set them in your shell's environment (`.bashrc`, `.zshenv`, etc.) --
>   Neovim inherits the parent shell's environment automatically.
> - Use a `devenv.local.nix` file (add it to `.gitignore`):
>   ```nix
>   # my-project/devenv.local.nix
>   {
>     nv2.env.ANTHROPIC_API_KEY = "sk-ant-api03-...";
>   }
>   ```
>   devenv automatically loads `devenv.local.nix` if it exists and merges
>   it with `devenv.nix`.
> - Use `nv2.extraInitLua` with a secret manager:
>   ```nix
>   {
>     nv2.extraInitLua = ''
>       vim.env.ANTHROPIC_API_KEY = vim.fn.system("pass show api/anthropic"):gsub("%s+$", "")
>     '';
>   }
>   ```

#### Tool-specific configuration

```nix
{
  nv2.env = {
    # Tell rust-analyzer to use a specific toolchain
    RUSTUP_TOOLCHAIN = "nightly-2026-01-15";
    # Configure ruff for this project
    RUFF_CONFIG = "./pyproject.toml";
  };
}
```

### Extra Packages (LSPs, Formatters, Linters)

`nv2.extraPackages` adds packages to the devenv environment alongside the
base set. Use this when your project needs tooling that the base config
doesn't include.

```nix
{ pkgs, ... }:
{
  nv2.extraPackages = with pkgs; [
    # Haskell tooling
    haskell-language-server
    ormolu
    hlint

    # Elixir tooling
    elixir-ls
    mix2nix

    # Zig
    zls
  ];
}
```

These packages are on PATH inside the devenv shell, so Neovim's LSP client,
conform, nvim-lint, and other tools can find them automatically.

### Extra Plugins

`nv2.extraPlugins` adds Vim plugins to the wrapped Neovim's packpath. This
triggers a rebuild of the Neovim wrapper derivation.

```nix
{ pkgs, ... }:
{
  nv2.extraPlugins = [
    pkgs.vimPlugins.vim-fugitive
    pkgs.vimPlugins.vim-sleuth
    pkgs.vimPlugins.nvim-surround
  ];
}
```

You can also build plugins from source:

```nix
{ pkgs, ... }:
{
  nv2.extraPlugins = [
    (pkgs.vimUtils.buildVimPlugin {
      pname = "some-new-plugin";
      version = "unstable-2026-02-15";
      src = pkgs.fetchFromGitHub {
        owner = "author";
        repo = "some-new-plugin.nvim";
        rev = "abc123...";
        hash = "sha256-...";
      };
    })
  ];
}
```

To set up newly added plugins, combine `extraPlugins` with `extraInitLua`:

```nix
{ pkgs, ... }:
{
  nv2.extraPlugins = [ pkgs.vimPlugins.trouble-nvim ];

  nv2.extraInitLua = ''
    require("trouble").setup({
      mode = "workspace_diagnostics",
    })
    vim.keymap.set("n", "<leader>xx", "<cmd>Trouble<cr>", { desc = "Trouble" })
  '';
}
```

### Treesitter Grammars

`nv2.treesitterGrammars` replaces the default grammar list entirely. This
is a function that receives the grammar package set and returns a list.

```nix
{
  # Only include grammars relevant to a Haskell project
  nv2.treesitterGrammars = p: [
    p.haskell p.cabal
    p.lua p.vim p.vimdoc
    p.nix p.json p.yaml p.markdown p.markdown_inline p.bash
  ];
}
```

If you want to **add** grammars to the defaults rather than replacing them,
define a helper:

```nix
{ pkgs, lib, ... }:
let
  defaultGrammars = p: [
    p.lua p.vim p.vimdoc p.python p.nix p.rust p.go
    p.javascript p.typescript p.tsx p.json p.yaml
    p.html p.css p.markdown p.markdown_inline
    p.bash p.c p.cpp
  ];
in
{
  nv2.treesitterGrammars = p: (defaultGrammars p) ++ [
    p.haskell
    p.elixir
    p.zig
  ];
}
```

### Combining Multiple Overrides

All options compose. Here's a full example for a Rust project:

```nix
{ pkgs, ... }:
{
  # Add rust-specific packages not in the base set
  nv2.extraPackages = with pkgs; [
    cargo-watch
    cargo-nextest
    bacon
  ];

  # Add extra treesitter grammars for TOML (common in Rust projects)
  nv2.treesitterGrammars = p: [
    p.lua p.vim p.vimdoc p.python p.nix p.rust p.go
    p.javascript p.typescript p.tsx p.json p.yaml
    p.html p.css p.markdown p.markdown_inline
    p.bash p.c p.cpp
    p.toml  # added for Cargo.toml
  ];

  # Warm color scheme for Rust work
  nv2.extraInitLua = ''
    require("mini.hues").setup({
      background = "#1c1210",
      foreground = "#d4be98",
      saturation = "medium",
      accent = "orange",
    })

    -- Bacon integration keymap
    vim.keymap.set("n", "<leader>rb", function()
      vim.cmd("terminal bacon")
    end, { desc = "Run bacon (Rust watcher)" })
  '';

  # Rust-specific env
  nv2.env = {
    RUST_BACKTRACE = "1";
  };

  # Your project's own devenv config (not nv2-related)
  languages.rust.enable = true;
}
```

---

## Neovim Plugin Development

This section covers using nv2 as a development environment for building
Neovim plugins.

### Basic Plugin Development Setup

When developing a Neovim plugin, you want the plugin's source directory on
Neovim's runtimepath so changes are picked up immediately without rebuilding
any Nix derivation.

Given a plugin project at `~/Projects/my-plugin.nvim/`:

```
my-plugin.nvim/
├── lua/
│   └── my-plugin/
│       └── init.lua
├── plugin/
│   └── my-plugin.lua
├── devenv.nix
└── devenv.yaml
```

```yaml
# my-plugin.nvim/devenv.yaml
inputs:
  nixpkgs:
    url: github:NixOS/nixpkgs/nixos-unstable
  nix-neovim:
    url: git+file:///home/andrew/Documents/Projects/IDE/nix_neovim_v2
    flake: false
imports:
  - nix-neovim
```

```nix
# my-plugin.nvim/devenv.nix
{ pkgs, ... }:
{
  # Add the current project root to Neovim's runtimepath.
  # builtins.toString ./. resolves to the project directory.
  nv2.extraRuntimePaths = [ (builtins.toString ./.) ];
}
```

Now when you run `nv2`, Neovim loads your plugin from the project directory.
Edit `lua/my-plugin/init.lua`, restart Neovim (or use `:luafile %`), and
your changes are live.

**How `extraRuntimePaths` works:** Each path is prepended to Neovim's
`runtimepath` via `--cmd "set rtp^=/path/to/dir"` before `init.lua` runs.
This means Neovim's plugin loader will find your `plugin/` directory and
Lua's `require()` will find your `lua/` directory.

### Adding a Project-Level init.lua

For more complex plugin development, you often want project-specific
configuration: setting up your plugin with specific options, loading test
dependencies, enabling debug logging, etc.

Use `nv2.extraInitLua` to run Lua code after the base editor config loads:

```nix
# my-plugin.nvim/devenv.nix
{ pkgs, ... }:
{
  nv2.extraRuntimePaths = [ (builtins.toString ./.) ];

  nv2.extraPlugins = [
    pkgs.vimPlugins.plenary-nvim  # if your plugin depends on plenary
  ];

  nv2.extraInitLua = ''
    -- Configure the plugin being developed with debug options
    require("my-plugin").setup({
      debug = true,
      log_level = "trace",
    })

    -- Convenience keymaps for development
    vim.keymap.set("n", "<leader>pr", function()
      -- Reload the plugin module (clear cached require)
      package.loaded["my-plugin"] = nil
      package.loaded["my-plugin.core"] = nil
      require("my-plugin").setup({ debug = true, log_level = "trace" })
      vim.notify("my-plugin reloaded", vim.log.levels.INFO)
    end, { desc = "Reload my-plugin" })

    vim.keymap.set("n", "<leader>ps", function()
      vim.cmd("source plugin/my-plugin.lua")
      vim.notify("plugin/my-plugin.lua sourced", vim.log.levels.INFO)
    end, { desc = "Source plugin script" })
  '';
}
```

#### Alternative: keep the project init in a separate file

If your project-level init is large or you want to edit it without
triggering a Nix rebuild, you can keep it as a standalone Lua file and
reference it:

```
my-plugin.nvim/
├── lua/
│   └── my-plugin/
│       └── init.lua
├── .nvim/
│   └── init.lua          <-- project-level init
├── devenv.nix
└── devenv.yaml
```

```nix
# my-plugin.nvim/devenv.nix
{ pkgs, ... }:
{
  nv2.extraRuntimePaths = [ (builtins.toString ./.) ];

  nv2.extraInitLua = ''
    -- Source project-local init if it exists
    local project_init = vim.fn.getcwd() .. "/.nvim/init.lua"
    if vim.fn.filereadable(project_init) == 1 then
      dofile(project_init)
    end
  '';
}
```

Now you can freely edit `.nvim/init.lua` without any Nix rebuilds. The
`nv2.extraInitLua` snippet is tiny and rarely changes, while the actual
project configuration lives in a plain Lua file.

```lua
-- my-plugin.nvim/.nvim/init.lua

-- Set up the plugin with dev options
require("my-plugin").setup({
  debug = true,
  log_level = "trace",
})

-- Hot-reload keymap
vim.keymap.set("n", "<leader>pr", function()
  for name, _ in pairs(package.loaded) do
    if name:match("^my%-plugin") then
      package.loaded[name] = nil
    end
  end
  require("my-plugin").setup({ debug = true, log_level = "trace" })
  vim.notify("my-plugin reloaded")
end, { desc = "Reload my-plugin" })
```

### Testing Against Multiple Configurations

When building a plugin for distribution, you may want to test it with
minimal configuration (no other plugins loaded). You can create a separate
script for that:

```nix
# my-plugin.nvim/devenv.nix
{ pkgs, ... }:
let
  # Minimal neovim with only your plugin and its dependencies
  minimalConfig = pkgs.neovimUtils.makeNeovimConfig {
    plugins = map (p: { plugin = p; }) [
      pkgs.vimPlugins.plenary-nvim
    ];
  };
  minimalNeovim = pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped (minimalConfig // {
    neovimRcContent = "";
    luaRcContent = "";
  });
in
{
  # Full nv2 for development
  nv2.extraRuntimePaths = [ (builtins.toString ./.) ];

  # Minimal neovim for isolated testing
  scripts.nv2-minimal.exec = ''
    exec ${minimalNeovim}/bin/nvim \
      --cmd "set rtp^=${builtins.toString ./.}" \
      -u NONE \
      -c "lua require('my-plugin').setup()" \
      "$@"
  '';

  # Test runner
  scripts.nv2-test.exec = ''
    exec ${minimalNeovim}/bin/nvim \
      --cmd "set rtp^=${builtins.toString ./.}" \
      --headless \
      -c "lua require('plenary.test_harness').test_directory('tests/', { minimal_init = 'tests/init.lua' })" \
      "$@"
  '';
}
```

This gives you three commands:
- `nv2` -- full editor with your plugin loaded
- `nv2-minimal` -- bare Neovim with only your plugin (for manual testing)
- `nv2-test` -- headless test runner for CI/automated tests

---

## Reference

### Full Option Reference

#### `nv2.extraPlugins`

- **Type:** `list of package`
- **Default:** `[]`
- **Description:** Additional Vim plugin packages included in the wrapped
  Neovim's packpath. Triggers a rebuild of the Neovim wrapper.

#### `nv2.extraRuntimePaths`

- **Type:** `list of string`
- **Default:** `[]`
- **Description:** Paths prepended to `runtimepath` via `--cmd` flags. These
  are injected before `init.lua` runs, so `plugin/` and `lua/` directories
  at these paths are available immediately. Use `builtins.toString ./.` to
  reference the consumer project's root.

#### `nv2.extraInitLua`

- **Type:** `lines` (multiline string)
- **Default:** `""`
- **Description:** Lua code written to a file in the Nix store and sourced
  after `init.lua` via `-c "luafile ..."`. Runs after all base plugins and
  configuration are loaded.

#### `nv2.treesitterGrammars`

- **Type:** `function` (grammar set -> list of packages)
- **Default:** 17 grammars (lua, vim, vimdoc, python, nix, rust, go, js, ts,
  tsx, json, yaml, html, css, markdown, markdown_inline, bash, c, cpp)
- **Description:** Replaces the treesitter grammar list entirely. Receives
  the grammar package set as argument.

#### `nv2.env`

- **Type:** `attribute set of string`
- **Default:** `{}`
- **Description:** Environment variables exported in the `nv2` wrapper
  script before Neovim launches. Visible to Neovim and child processes.

#### `nv2.extraPackages`

- **Type:** `list of package`
- **Default:** `[]`
- **Description:** Additional packages added to the devenv environment.
  These are on PATH alongside the base LSPs, formatters, and linters.

### Troubleshooting

#### "module 'X' not found" when using extraRuntimePaths

Ensure the path you're adding contains the expected directory structure.
For a Lua module `require("foo")` to resolve, there must be a `lua/foo.lua`
or `lua/foo/init.lua` at one of the runtimepath entries.

Verify your runtimepath inside Neovim:
```vim
:echo &runtimepath
```

#### Changes to nix_neovim_v2 aren't showing up

If you use `git+file://`, only committed files are visible. Commit your
changes in the nix_neovim_v2 repo, then run `devenv update nix-neovim` in
the consumer project.

If you use `path:`, changes should be immediate, but Nix may cache the
evaluation. Try `devenv shell` again or remove `.devenv/` and retry.

#### nv2.extraInitLua changes require devenv rebuild

This is expected. `extraInitLua` content is written to a file in the Nix
store at build time. Any change to the string triggers a new store path and
a new `nv2` wrapper script. If you want to iterate without rebuilds, use
the [separate file approach](#alternative-keep-the-project-init-in-a-separate-file)
described in the plugin development section.

#### Conflicting scripts.nv2

If your project's `devenv.nix` also defines `scripts.nv2.exec`, it will
conflict with the one from the nv2 module. The module system will raise an
error about duplicate definitions. Don't redefine `nv2` -- use the module
options instead. If you need a completely custom launch script, define it
under a different name (e.g., `scripts.nv2-custom.exec`).

#### Extra plugins aren't loading

Confirm the plugin appears in the packpath:
```vim
:echo &packpath
```

Plugins added via `nv2.extraPlugins` should appear under a
`/nix/store/...-vim-pack-dir/pack/myNeovimPackages/start/` path. If they
don't, check that the package you're passing is a valid Vim plugin
derivation (built with `buildVimPlugin` or from `pkgs.vimPlugins`).

#### devenv.local.nix for machine-specific overrides

devenv automatically loads `devenv.local.nix` if present. Add it to
`.gitignore` and use it for secrets or machine-specific config:

```nix
# devenv.local.nix (not committed)
{
  nv2.env = {
    ANTHROPIC_API_KEY = "sk-ant-...";
    OPENAI_API_KEY = "sk-...";
  };
}
```
