{
  programs.nixvim.plugins.obsidian = {
    enable = true;
    settings = {
      dir = "~/Documents/Notes";
      disable_frontmatter = true;
    };
  };
}
