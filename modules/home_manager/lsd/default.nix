{
  config,
  lib,
  ...
}:

{
  options = {
    ncfg.lsd.enable = lib.mkEnableOption "Enable lsd";
  };

  config = lib.mkIf config.ncfg.lsd.enable {
    programs.lsd = {
      enable = true;
      enableAliases = true;
    };
  };
}
