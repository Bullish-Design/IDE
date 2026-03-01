{ pkgs }:
let
  vp = pkgs.vimPlugins;
in
[
  # Framework (mini.nvim is built from source in hm-module.nix)

  # LSP
  vp.nvim-lspconfig

  # Formatting
  vp.conform-nvim

  # Linting
  vp.nvim-lint

  # Treesitter
  vp.nvim-treesitter
  vp.nvim-treesitter-context

  # Git
  vp.gitsigns-nvim
  vp.neogit
  vp.diffview-nvim
  vp.plenary-nvim

  # DAP
  vp.nvim-dap
  vp.nvim-dap-ui
  vp.nvim-dap-python
  vp.nvim-nio

  # Testing
  vp.neotest
  vp.neotest-python
  vp.neotest-vitest
  vp.neotest-rust

  # Tools
  vp.obsidian-nvim
  vp.markdown-preview-nvim

  # AI Companion
  (import ./nvim/plugins/codecompanion.nix { inherit pkgs; })
]
