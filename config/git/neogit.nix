{
  plugins.neogit = {
    enable = true;
    settings = {
      # commit_popup = {
      #   kind = "floating";
      # };
      integrations.diffview = true;
    };
  };
  keymaps = [
    {
      mode = "n";
      key = "<leader>gg";
      action = "<cmd>Neogit<CR>";
      options.desc = "Neogit";
    }
  ];
}
