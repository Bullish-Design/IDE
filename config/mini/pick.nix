{
  programs.nixvim = {
    extraConfigLuaPost = ''
      vim.ui.select = require('mini.pick').ui_select
    '';

    plugins.mini.modules.pick = {
      options.use_cache = true;
      window = {
        config.border = "rounded";
        prompt_prefix = ": ";
      };
    };
  };
}
