{
  config,
  lib,
  ...
}:
let
  cfg = config.ncfg.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    services.dunst = {
      enable = true;
      settings = {
        global = {
          monitor = 0;
          follow = "none";

          width = 300;
          height = "(0,300)";
          origin = "top-center";
          offset = "30x30";
          scale = 0;
          notification_limit = 20;

          progress_bar = true;
          progress_bar_height = 10;
          progress_bar_frame_width = 1;
          progress_bar_min_width = 150;
          progress_bar_max_width = 300;
          progress_bar_corner_radius = 10;
          icon_corner_radius = 0;
          indicate_hidden = "yes";

          transparency = 30;
          separator_height = 2;
          padding = 8;
          horizontal_padding = 8;
          text_icon_padding = 0;
          frame_width = 1;
          frame_color = "#ffffff";
          gap_size = 0;
          # TODO: WTF?
          # separator_color = "frame";
          sort = "yes";
        };
      };
    };
  };
}
