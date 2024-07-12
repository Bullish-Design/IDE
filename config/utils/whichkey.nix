{
  # TODO: Implement general mappings
  plugins.which-key = {
    enable = true;
    preset = "modern";
    ignoreMissing = false;
    icons = {
      breadcrumb = "»";
      group = "+";
      separator = ""; # ➜
    };
    
    # Registrations:
    # registrations = {
    #   "<leader>t" = " Terminal";
    # };


    window = {
      border = "rounded";
      winblend = 0;
    };
  };
}
