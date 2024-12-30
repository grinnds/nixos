{
  config,
  lib,
  ...
}:

{
  options = {
    ncfg.wezterm.enable = lib.mkEnableOption "Enable wezterm";
  };

  config = lib.mkIf config.ncfg.wezterm.enable {
    programs.wezterm = {
      enable = true;

      extraConfig = builtins.readFile ./config/wezterm.lua;
    };
  };
}
