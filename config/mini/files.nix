{
  # programs.nixvim = {
    plugins.mini.modules.files = {
      # keys = [
      #   {
      #     mode = "n";
      #     keys = "<leader>e";
      #     command = "lua require('mini.files').open()";
      #   }
      # ];
    # autoCmd = [
    #   {
    #     event = "User";
    #     pattern = "MiniFilesWindowOpen";
    #     callback = {
    #       __raw = ''
    #         function(args)
    #           local win_id = args.data.win_id
    #           vim.api.nvim_win_set_config(win_id, { border = 'rounded' })
    #         end
    #       '';
    #     };
    #   }
    # ];
  };

  keymaps = [
      {
        action = "<cmd>lua MiniFiles.open()<cr>";
        key = "<leader>e";
        options = {
          desc = "Open File Explorer";
        };
        mode = [
          "n"
        ];
      }
  ];
}
