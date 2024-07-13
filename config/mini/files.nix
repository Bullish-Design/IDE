{
  plugins.mini.modules.files = {};

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
