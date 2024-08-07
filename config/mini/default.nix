{
  imports = [
    ./clue.nix
    # ./completion.nix
    ./files.nix
    #./pick.nix
    #./starter.nix
  ];

  plugins.mini = {
    enable = true;
    modules = {
      ai = {};
      # animate = {
      #   cursor.timing.__raw = "require('mini.animate').gen_timing.cubic({ easing = 'out', duration = 10 })";
      #   scroll.timing.__raw = "require('mini.animate').gen_timing.cubic({ easing = 'out', duration = 10 })";
      #   resize.timing.__raw = "require('mini.animate').gen_timing.cubic({ easing = 'out', duration = 10 })";
      #   open.enable = false;
      #   close.enable = false;
      # };
      basics = {
        options = {
          extra_ui = true;
          winborders = "dot";
        };
        mappings = {
          windows = true;
          move_with_alt = true;
        };
        silent = true;
      };
      # bracketed.__empty = null;
      bufremove = {};
      comment = { 
        mappings = {
          comment_line = "gcc";
          textobject = "gc";
        };
      };
      # cursorword.__empty = null;
      diff.view = {
        signs = {
          add = "+";
          change = "~";
          delete = "_";
        };
        style = "sign";
      };
      # extra.__empty = null;
      # fuzzy.__empty = null;
      # git.__empty = null;
      # indentscope.__empty = null;
      # jump.__empty = null;
      # jump2d.__empty = null;
      # move.__empty = null;
      # notify = {
      #   lsp_progress.enable = false;
      #   window.config.border = "rounded";
      # };
      # operators.__empty = null;
      pairs = {};
      #pick.__empty = null;
      # sessions.__empty = null;
      # statusline = { # TODO
      #   content = {
      #     active = "";
      #     inactive = "";
      #   };
      # };
      # splitjoin.__empty = null;
      # surround.__empty = null;
      # tabline.format = {__raw = "";}; # TODO
      # trailspace.__empty = null;
      # visits.__empty = null;
    };
  };
}
