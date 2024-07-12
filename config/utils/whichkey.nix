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
        top = 1;
        right = 10;
        bottom = 1;
        left = 10;
      };
      padding = {
        top = 1;
        right = 1;
        bottom = 1;
        left = 5;
      };
    };

    layout = {
      height = {
        min = 5;
        max = 25;
      };
      width = {
        min = 25;
        max = 50;
      };
      spacing = 5;
      align = "center";
    };
  };
}
