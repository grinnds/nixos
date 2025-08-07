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
  imports = [
    ./config.nix
    ./keybindings.nix
    ./hypridle.nix
    ./hyprlock.nix
    ./hyprpaper.nix
    ./pyprland.nix
    ./waybar.nix
    ./wlogout.nix
    ./dunst.nix
  ];

  options = {
    ncfg.hyprland.enable = lib.mkEnableOption "Enable hyprland";
    ncfg.hyprland.monitors =
      with lib;
      with types;
      mkOption {
        description = "List of monitors in hyprland format";
        type = listOf str;
        example = [ "eDP-1, 1920x1080@240, 0x0, 1" ];
        default = [ ];
      };
  };

  config = lib.mkIf cfg.enable {
    services = {
      hypridle = {
        enable = true;
        settings = {
          general = {
            after_sleep_cmd = "hyprctl dispatch dpms on";
            ignore_dbus_inhibit = false;
            lock_cmd = "hyprlock";
          };
          listener = [
            {
              timeout = 900;
              on-timeout = "hyprlock";
            }
            {
              timeout = 1200;
              on-timeout = "hyprctl dispatch dpms off";
              on-resume = "hyprctl dispatch dpms on";
            }
          ];
        };
      };
    };
  };
}
