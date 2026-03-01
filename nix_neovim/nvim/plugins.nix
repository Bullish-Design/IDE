{ pkgs }:
let
  vp = pkgs.vimPlugins;
in [
  # Small, batteries-included Lua plugin suite
  vp.mini-nvim

  # Light LSP configuration helper
  vp.nvim-lspconfig
]
