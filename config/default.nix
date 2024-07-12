{
  # Import all your configuration modules here
  imports = [
    ./sets.nix
    ./keymaps.nix

    ./bufferlines/bufferline.nix

    ./colorschemes/base16.nix
    ./colorschemes/catppuccin.nix
    ./colorschemes/rose-pine.nix

    ./completion/cmp.nix
    ./completion/copilot.nix
    ./completion/lspkind.nix

    ./dap/dap.nix

    ./filetrees/neo-tree.nix
    ./git/gitsigns.nix
    ./git/diffview.nix
    # ./git/lazygit.nix
    ./git/neogit.nix

    #./languages/nvim-jdtls.nix
    ./languages/nvim-lint.nix
    #./languages/typescript-tools-nvim.nix
    ./languages/treesitter/treesitter.nix
    ./languages/treesitter/treesitter-context.nix
    ./languages/treesitter/treesitter-textobjects.nix
    #./languages/treesitter/ts-autotag.nix
    #./languages/treesitter/ts-context-commentstring.nix

    ./lsp/conform.nix
    ./lsp/fidget.nix
    ./lsp/lsp.nix
    ./lsp/lspsaga.nix
    ./lsp/trouble.nix

    ./none-ls/none-ls.nix # Currently not enabled, but keeping in

    ./snippets/luasnip.nix

    ./statusline/lualine.nix
    #./statusline/staline.nix

    ./telescope/telescope.nix

    ./ui/alpha.nix
    ./ui/dressing-nvim.nix # - UI overlay? inputs, selections, etc.
    ./ui/indent-blankline.nix
    ./ui/noice.nix # - Popup windows for ui messages/notifications **TODO: Check configuration**
    ./ui/nvim-notify.nix # - Different notification manager. Why both?
    ./ui/nui.nix # UI component library? (https://github.com/MunifTanjim/nui.nvim)

    ./utils/better-escape.nix # 
    #./utils/neocord.nix # - Discord integration of some sort
    #./utils/flash.nix # - Add on for fast search navigation? https://github.com/folke/flash.nvim
    #./utils/hardtime.nix # - neovim training tool? https://github.com/m4xshen/hardtime.nvim
    ./utils/harpoon.nix # - quicker navigation of files? Investigate if v1 or v2 is being installed https://github.com/ThePrimeagen/harpoon/tree/harpoon2
    ./utils/illuminate.nix # - auto highlighting of other uses of a word https://github.com/RRethy/vim-illuminate
    ./utils/markdown-preview.nix # - 
    ./utils/mini.nix # - a collection of lua plugins (https://github.com/echasnovski/mini.nvim)
    #./utils/neodev.nix # - full IDE style support but just for lua? Also depreciated and recommending lazydev.nvim? (https://github.com/folke/neodev.nvim)
    #./utils/neotest.nix # - **TODO: CHECK PYTHON SUPPORT** Support for running tests within neovim (https://github.com/nvim-neotest/neotest)
    #./utils/nvim-autopairs.nix # - Was disabled, due to ultimate autopair being used. 
    ./utils/nvim-colorizer.nix # - Colors
    ./utils/nvim-surround.nix # - Selecting chunks. Investigate and practice (https://github.com/kylechui/nvim-surround)
    #./utils/oil.nix # - Edit filesystem like a neovim buffer? Investigate (https://github.com/stevearc/oil.nvim)
    ./utils/persistence.nix # - Session management (https://github.com/folke/persistence.nvim)
    ./utils/plenary.nix # - A collection of Lua functions? Investigate. (https://github.com/nvim-lua/plenary.nvim)
    ./utils/project-nvim.nix # - Project management. Investigate functionality. (https://github.com/ahmedkhalf/project.nvim)
    #./utils/sidebar.nix # - 
    ./utils/tmux-navigator.nix # - 
    ./utils/todo-comments.nix # - 
    ./utils/toggleterm.nix # - 
    ./utils/ultimate-autopair.nix # - 
    ./utils/undotree.nix # - 
    ./utils/vim-be-good.nix # - Vim practice?
    #./utils/wakatime.nix # - Time tracking
    ./utils/whichkey.nix # - 
    ./utils/wilder.nix # - "A more adventurous wildmenu" - What's a wildmenu??? (https://github.com/gelguy/wilder.nvim)
  ];
}
