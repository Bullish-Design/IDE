# nvim/plugins.nix

{ pkgs }:
let
  vp = pkgs.vimPlugins;
in [
  # Plugins from pkgs.vimPlugins
  vp.plenary-nvim
  vp.telescope-nvim
  vp.nvim-treesitter

  # Custom/pinned plugins
  (import ./plugins/codecompanion.nix { inherit pkgs; })
  # (import ./plugins/another-plugin.nix { inherit pkgs; })
]