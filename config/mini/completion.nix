{
  programs.nixvim.plugins.mini.modules.completion = {
    lsp_completion.process_items.__raw = "require('mini.fuzzy').process_lsp_items";
    window = {
      info.border = "rounded";
      signature.border = "rounded";
    };
  };
}
