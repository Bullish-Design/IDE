{
  description = "Neovim config v2 - Streamlined, mini.nvim-first";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Framework
    mini-nvim-src = {
      url = "tarball+https://github.com/nvim-mini/mini.nvim/archive/refs/tags/v0.17.0.tar.gz";
      flake = false;
    };

    # LSP
    nvim-lspconfig.url = "github:neovim/nvim-lspconfig";
    nvim-lspconfig.flake = false;

    # Formatting
    conform-nvim.url = "github:stevearc/conform.nvim";
    conform-nvim.flake = false;

    # Linting
    nvim-lint.url = "github:mfussenegger/nvim-lint";
    nvim-lint.flake = false;

    # Treesitter
    nvim-treesitter.url = "github:nvim-treesitter/nvim-treesitter";
    nvim-treesitter.flake = false;

    # Treesitter context
    treesitter-context = {
      url = "github:nvim-treesitter/nvim-treesitter-context";
      flake = false;
    };

    # Git
    gitsigns-nvim = {
      url = "github:lewis6991/gitsigns.nvim";
      flake = false;
    };

    neogit = {
      url = "github:NeogitOrg/neogit";
      flake = false;
    };

    diffview-nvim = {
      url = "github:sindrets/diffview.nvim";
      flake = false;
    };

    # DAP
    nvim-dap = {
      url = "github:mfussenegger/nvim-dap";
      flake = false;
    };

    nvim-dap-ui = {
      url = "github:rcarriga/nvim-dap-ui";
      flake = false;
    };

    # DAP adapters
    dap-python = {
      url = "github:mfussenegger/nvim-dap-python";
      flake = false;
    };

    # Testing
    neotest = {
      url = "github:nvim-neotest/neotest";
      flake = false;
    };

    neotest-python = {
      url = "github:nvim-neotest/neotest-python";
      flake = false;
    };

    neotest-vitest = {
      url = "github:nvim-neotest/neotest-vitest";
      flake = false;
    };

    neotest-rust = {
      url = "github:rouge8/neotest-rust";
      flake = false;
    };

    # Optional tools
    obsidian-nvim = {
      url = "github:epwalsh/obsidian.nvim";
      flake = false;
    };

    markdown-preview-nvim = {
      url = "github:iamcco/markdown-preview.nvim";
      flake = false;
    };
  };

  outputs = inputs@{ self, ... }: {
    homeManagerModules.default = import ./hm-module.nix { inherit inputs; };
  };
}
