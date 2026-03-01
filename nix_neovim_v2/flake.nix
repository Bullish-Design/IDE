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
    let
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f {
        pkgs = import nixpkgs { inherit system; };
        inherit system;
      });
    in
    {
      homeManagerModules.default = import ./hm-module.nix { inherit inputs; };

      devShells = forAllSystems ({ pkgs, system }:
        let
          # Build mini.nvim from source
          mini-nvim = pkgs.vimUtils.buildVimPlugin {
            pname = "mini.nvim";
            version = "pinned";
            src = inputs.mini-nvim-src;
          };
          
          # Get all plugins
          allPlugins = import ./plugins.nix { inherit pkgs; };
        in
        {
          default = pkgs.mkShell {
            name = "nix_neovim_v2";

            buildInputs = with pkgs; [
              neovim
              git
              ripgrep
              fd
            ];

            shellHook = ''
              # Create init files at runtime to avoid nix caching issues
              mkdir -p "''${PWD}/.devenv"
              
              # Write the init.lua that will be used as the user init
              # Set runtimepath FIRST, then source the actual config
              cat > "''${PWD}/.devenv/init.lua" << INIT_EOF
              -- Auto-generated init.lua wrapper
              -- Set runtimepath before loading plugins
              vim.opt.runtimepath:prepend("${builtins.toString ./.}/nvim")
              INIT_EOF
              
              # Add all plugins to runtimepath
              ${builtins.concatStringsSep "\n" (
                map (p: "echo \"vim.opt.runtimepath:append('${p}')\" >> \"\${PWD}/.devenv/init.lua\"") ([mini-nvim] ++ allPlugins)
              )}
              
              # Now source the real init.lua
              echo "dofile('${builtins.toString ./.}/nvim/init.lua')" >> "''${PWD}/.devenv/init.lua"
              
              # Create nv2 wrapper script
              cat > "''${PWD}/.devenv/nv2" << NV2_EOF
              #!/bin/sh
              exec ${pkgs.neovim}/bin/nvim -u "''${PWD}/.devenv/init.lua" -N "\$@"
              NV2_EOF
              chmod +x "''${PWD}/.devenv/nv2"
              export PATH="''${PWD}/.devenv:$PATH"
            '';
          };
        }
      );
    };

}
