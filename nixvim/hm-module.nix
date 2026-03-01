{ inputs }:
{ pkgs, ... }:
let
  # mini.nvim pinned via flake input (flake = false)
  mini-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "mini.nvim";
    # optional: keep in sync with your flake.nix ref/tag
    version = "pinned";
    src = inputs.mini-nvim-src;
  };

  # Your existing plugin list (derivations)
  pluginsFromRepo = import ./nvim/plugins.nix { inherit pkgs; };

  # Replace nixpkgs' mini-nvim with the pinned one (avoid duplicates)
  plugins =
    [ mini-nvim ]
    ++ builtins.filter
      (p:
        let n = (p.pname or p.name or "");
        in !(builtins.match "mini.*" n != null))
      pluginsFromRepo;
in
{
  programs.neovim = {
    enable = true;
    vimAlias = true;
    viAlias = true;

    plugins = plugins;
  };

  # Deploy your whole config tree to ~/.config/nvim
  xdg.configFile."nvim" = {
    source = ./nvim;
    recursive = true;
  };

  # Minimal helpers and LSP servers (optional but practical)
  home.packages = with pkgs; [
    ripgrep
    fd

    # LSP servers
    lua-language-server
    nil
    bash-language-server
  ];
}
