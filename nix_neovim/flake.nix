{
  description = "Neovim config as a Home Manager module";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Pin mini.nvim source to a tag (or a commit/branch)
    mini-nvim-src = {
      url = "tarball+https://github.com/nvim-mini/mini.nvim/archive/refs/tags/v0.17.0.tar.gz";
      flake = false;
    };
  };

  outputs = inputs@{ self, ... }: {
    homeManagerModules.default = import ./hm-module.nix { inherit inputs; };
  };
}
