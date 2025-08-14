{
  config,
  lib,
  ...
}:
let
  cfg = config.ncfg.yazi;
in
{
  options = {
    ncfg.yazi.enable = lib.mkEnableOption "Enable yazi";
  };

  config = lib.mkIf cfg.enable {
    programs.yazi.enable = true;
  };
}
