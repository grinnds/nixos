{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.ncfg.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    services.hyprpaper = {
      enable = true;
    };
  };
}
