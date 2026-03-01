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

  # Git
  vp.gitsigns-nvim
  vp.neogit
  vp.diffview-nvim

  # DAP
  vp.nvim-dap
  vp.nvim-dap-ui

  # Testing
  vp.neotest
  vp.neotest-python
  vp.neotest-vitest

  # AI Companion
  (import ./nvim/plugins/codecompanion.nix { inherit pkgs; })
]
