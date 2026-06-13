{
  config,
  lib,
  ...
}:
let
  cfg = config.ncfg.wallpaper;
in
{
  options = {
    ncfg.wallpaper.enable = lib.mkEnableOption "Enable wallpaper";
  };

  config = lib.mkIf cfg.enable {
    home.file."Pictures/Wallpapers/hololive.jpg".source = ./hololive.jpg;
    home.file.".face".source = ./face.jpg;
  };
}
