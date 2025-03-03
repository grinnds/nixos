{
  config,
  lib,
  ...
}:
let
  cfg = config.ncfg.hardware.bluetooth;
in
{
  options = {
    ncfg.hardware.bluetooth.enable = lib.mkEnableOption "Enable hardware bluetooth support";
  };

  config = lib.mkIf cfg.enable {
    services.blueman.enable = true;
    hardware = {
      bluetooth = {
        enable = true;
        powerOnBoot = false;
        settings.General.Experimental = true;
      };
    };
  };
}
