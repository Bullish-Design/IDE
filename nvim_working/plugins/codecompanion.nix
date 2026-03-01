# nvim/plugins/codecompanion.nix

{ pkgs }:

pkgs.vimUtils.buildVimPlugin {
  name = "codecompanion-nvim";
  src = pkgs.fetchFromGitHub {
    owner = "olimorris";
    repo = "codecompanion.nvim";
    rev = "v17.30.0";
    hash = "sha256-mtw7RlP/VbVf2JwjWDDxsgTIBWt+gbTsJWjGS4RCSrI=";
  };
  doCheck = false;
}