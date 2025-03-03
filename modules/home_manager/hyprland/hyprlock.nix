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
    programs.hyprlock = {
      enable = true;
      settings = {

        general = {
          ignore_empty_input = true;
        };

        background = [
          {
            path = "${config.home.homeDirectory}/Pictures/Wallpapers/hololive.jpg";
            blur_passes = 3;
            blur_size = 8;
          }
        ];

        image = [
          {
            path = "/${config.home.homeDirectory}/.config/face.jpg";
            size = 200;
            border_size = 4;
            border_color = "rgb(0C96F9)";
            rounding = -1; # Negative means circle
            position = "0, 200";
            halign = "center";
            valign = "center";
          }
        ];

        input-field = [
          {
            monitor = "";
            size = "200, 50";
            position = "0, -80";
            dots_center = true;
            fade_on_empty = false;
            font_color = "rgb(CFE6F4)";
            inner_color = "rgb(657DC2)";
            outer_color = "rgb(0D0E15)";
            outline_thickness = 5;
            placeholder_text = "Password...";
            shadow_passes = 2;
          }
        ];

        label = [
          {
            monitor = "";
            text = "$USER";
            color = "rgb(CFE6F4)";
            font_size = 20;
            font_family = "Noto Semibold";
            position = "0, 0";
            halign = "center";
            valign = "center";
            shadow_passes = 5;
            shadow_size = 10;
          }
        ];
      };
    };
  };
}
