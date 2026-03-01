{
  description = "Neovim config v2 - Streamlined, mini.nvim-first";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Framework (built from source)
    mini-nvim-src = {
      url = "tarball+https://github.com/nvim-mini/mini.nvim/archive/refs/tags/v0.17.0.tar.gz";
      flake = false;
    };
  };

  outputs = inputs@{ self, nixpkgs, ... }:
    {
      homeManagerModules.default = import ./hm-module.nix { inherit inputs; };
    };

}
