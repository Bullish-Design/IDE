{ pkgs, ... }:
let
  # Build mini.nvim from source (pinned release)
  mini-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "mini.nvim";
    version = "0.17.0";
    src = pkgs.fetchFromGitHub {
      owner = "echasnovski";
      repo = "mini.nvim";
      rev = "v0.17.0";
      hash = "sha256-xmNZrQDptaNcECHSGtjownFyR1qxsP7lge8OAIFe8BU=";
    };
  };

  # All plugins from shared plugin list
  allPlugins = import ./plugins.nix { inherit pkgs; };

  # Bundle nvim-treesitter with grammars (replaces ensure_installed / auto_install)
  treesitterWithGrammars = pkgs.vimPlugins.nvim-treesitter.withPlugins (p: [
    p.lua p.vim p.vimdoc p.python p.nix p.rust p.go
    p.javascript p.typescript p.tsx p.json p.yaml
    p.html p.css p.markdown p.markdown_inline
    p.bash p.c p.cpp
  ]);

  # Replace the bare nvim-treesitter in allPlugins with the grammar-bundled version
  pluginsWithGrammars = map (p:
    if (p.pname or "") == "nvim-treesitter"
    then treesitterWithGrammars
    else p
  ) allPlugins;

  # Build a properly wrapped Neovim with all plugins in packpath
  neovimConfig = pkgs.neovimUtils.makeNeovimConfig {
    plugins = map (p: { plugin = p; }) ([ mini-nvim ] ++ pluginsWithGrammars);
  };

  neovim = pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped (neovimConfig // {
    # Don't generate an init.vim/lua - we use our own
    neovimRcContent = "";
    luaRcContent = "";
  });
in
{
  # Core packages
  packages = [
    neovim
  ] ++ (with pkgs; [
    git
    ripgrep
    fd

    # LSP servers
    lua-language-server
    nil
    bash-language-server
    pyright
    rust-analyzer
    clang-tools  # includes clangd
    gopls
    nodePackages.typescript-language-server
    nodePackages.vscode-langservers-extracted

    # Formatters
    stylua
    alejandra
    ruff
    prettierd
    goimports-reviser
    nixfmt

    # Linters
    shellcheck
    statix
    yamllint
    selene
    golangci-lint

    # DAP adapters
    python3Packages.debugpy

    # Optional
    nodePackages.markdownlint-cli2
  ]);

  # Startup command: launch the wrapped neovim with our config
  scripts.nv2.exec = ''
    exec ${neovim}/bin/nvim \
      --cmd "set rtp^=$DEVENV_ROOT/nvim" \
      -u "$DEVENV_ROOT/nvim/init.lua" \
      "$@"
  '';

  # Show helpful message on shell entry
  enterShell = ''
    echo "nv2 ready - run 'nv2' to launch Neovim"
  '';
}
