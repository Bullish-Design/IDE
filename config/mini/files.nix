{
  programs.nixvim = {
    plugins.mini.modules.files = {__empty = null;};
    autoCmd = [
      {
        event = "User";
        pattern = "MiniFilesWindowOpen";
        callback = {
          __raw = ''
            function(args)
              local win_id = args.data.win_id
              vim.api.nvim_win_set_config(win_id, { border = 'rounded' })
            end
          '';
        };
      }
    ];
  };
}
