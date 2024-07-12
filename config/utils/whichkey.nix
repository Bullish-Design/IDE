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
        right = 2;
        bottom = 5;
        left = 2;
      };
      # padding = {
      #   top = 1;
      #   right = 1;
      #   bottom = 5;
      #   left = 5;
      # };
    };
  };
}
