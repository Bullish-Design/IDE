# nix_neovim_v2/default.nix
# Drop-in replacement for nvim system setup

{ pkgs, config, ... }:
let
  cmdName = "nv2";
  srcDir = "${config.home.homeDirectory}/.dotfiles/nix_neovim_v2";
  
  allPlugins = import ./plugins.nix { inherit pkgs; };
  
in
{
  home.packages = [
    (pkgs.writeShellScriptBin cmdName ''
      exec ${pkgs.neovim}/bin/nvim -u "${srcDir}/nvim/init.lua" \
        --cmd "set rtp^=${srcDir}/nvim" \
        ${builtins.concatStringsSep " " (map (p: "--cmd \"set rtp+=${p}\"") allPlugins)} \
        "$@"
    '')
  ];
}
