{
  # TODO: Implement general mappings
  plugins.which-key = {
    enable = true;
    ignoreMissing = false;
    icons = {
      breadcrumb = "»";
      group = "+";
      # separator = ""; # ➜
    };
    
    # Registrations:
    # registrations = {
    #   "<leader>t" = " Terminal";
    # };


    window = {
      border = "rounded";
      winblend = 0;
      margin = {
        bottom = 1;
        left = 10;
        right = 100;
        top = 1;
      };
      # padding = {
      #   top = 1;
      #   right = 5;
      #   bottom = 1;
      #   left = 5;
      # };
    };

    layout = {
      height = {
        min = 7;
        max = 25;
      };
      width = {
        min = 25;
        max = 50;
      };
      spacing = 6;
      align = "left";
    };
  };
}
