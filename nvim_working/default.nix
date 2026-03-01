# nvim/default.nix

{ pkgs, config, ... }:
let
  cmdName = "nv";
  srcDir = "${config.home.homeDirectory}/.dotfiles/nvim";
  
  allPlugins = import ./plugins.nix { inherit pkgs; };
  
in {
  home.packages = [
    (pkgs.writeShellScriptBin cmdName ''
      exec ${pkgs.neovim}/bin/nvim -u "${srcDir}/init.lua" \
        --cmd "set rtp^=${srcDir}" \
        ${builtins.concatStringsSep " " (map (p: "--cmd \"set rtp+=${p}\"") allPlugins)} \
        "$@"
    '')
  ];
}