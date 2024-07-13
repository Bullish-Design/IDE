{
  plugins.mini = {
    enable = true;
    modules = {
      comment = {
        options = {
          customCommentString = ''
            <cmd>lua require("ts_context_commentstring.internal").calculate_commentstring() or vim.bo.commentstring<cr>
          '';
        };
      };
      cursorword = {};
      clue = {
        triggers = [
          {
            mode = "n";
            keys = "<leader>";
          }
          {
            mode = "x";
            keys = "<leader>";
          }
        ];
        window = {
          config = {
            border = "rounded";
            width = "auto";
          };
          delay = 0;
        };
      };

    };
  };
}
