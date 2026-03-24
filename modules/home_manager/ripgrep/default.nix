{
  config,
  lib,
  ...
}:
let
  cfg = config.ncfg.ripgrep;
in
{
  options = {
    ncfg.ripgrep.enable = lib.mkEnableOption "Enable ripgrep";
  };

  config = lib.mkIf cfg.enable {
    programs.ripgrep = {
      enable = true;
    };
  };
}
