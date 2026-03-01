{ inputs }:
{ pkgs, config, ... }:
let
  # mini.nvim from flake input
  mini-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "mini.nvim";
    version = "pinned";
    src = inputs.mini-nvim-src;
  };

  # All plugins from imports
  allPlugins = import ./plugins.nix { inherit pkgs; };

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
    ruff
    jsonlint
    yamllint

    # DAP adapters
    python3.pkgs.debugpy

    # Optional
    nodePackages.markdownlint-cli2
  ];
}
