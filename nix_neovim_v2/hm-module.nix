{ inputs }:
{ pkgs, config, lib, ... }:
let
  # mini.nvim from flake input
  mini-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "mini.nvim";
    version = "pinned";
    src = inputs.mini-nvim-src;
  };

  # All plugins from imports
  allPlugins = import ./plugins.nix { inherit pkgs; };

  # Create nv2 wrapper script (like your system's nv command)
  # Explicitly loads config file and adds all plugins to runtimepath
  nv2 = pkgs.writeShellScriptBin "nv2" ''
    srcDir="${config.home.homeDirectory}/.dotfiles/nix_neovim_v2"
    exec ${pkgs.neovim}/bin/nvim -u "$srcDir/nvim/init.lua" \
      --cmd "set rtp^=$srcDir/nvim" \
      ${builtins.concatStringsSep " " (map (p: "--cmd \"set rtp+=${p}\"") ([mini-nvim] ++ allPlugins))} \
      "$@"
  '';

in
{
  programs.neovim = {
    enable = true;
    vimAlias = true;
    viAlias = true;
    plugins = [ mini-nvim ] ++ allPlugins;
  };

  xdg.configFile."nvim" = {
    source = ./nvim;
    recursive = true;
  };

  home.packages = with pkgs; [
    # nv2 command alias
    nv2

    # CLI tools
    ripgrep
    fd

    # LSP servers
    lua-language-server
    nil
    bash-language-server
    pyright
    rust-analyzer
    clangd
    gopls
    nodePackages.typescript-language-server
    nodePackages.vscode-langservers-extracted

    # Formatters
    stylua
    alejandra
    ruff
    prettierd
    goimports
    gofmt
    clang-tools

    # Linters
    shellcheck
    statix
    jsonlint
    yamllint
    selene
    golangci-lint

    # DAP adapters
    python3.pkgs.debugpy

    # Optional
    nodePackages.markdownlint-cli2
  ];
}
