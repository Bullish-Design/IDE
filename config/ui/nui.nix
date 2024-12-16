{ pkgs, inputs, ... }:
{
  extraPlugins = [
    (pkgs.vimUtils.buildVimPlugin {
      name = "nui";
      src = inputs.plugin-nui;
    })
    (pkgs.vimUtils.buildVimPlugin {
      name = "nui-components";
      src = inputs.plugin-nui-components;
    })
  ];
}
