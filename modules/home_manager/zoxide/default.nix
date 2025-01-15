{
  config,
  lib,
  ...
}:

{
  options = {
    ncfg.zoxide.enable = lib.mkEnableOption "Enable zoxide";
  };

  config = lib.mkIf config.ncfg.zoxide.enable {

    programs.zoxide = {
      enable = true;
    };
  };
}
